#version 150
#ifdef GL_ES 
precision mediump float;
#endif

uniform vec3 skyColor;
uniform vec3 skyAmbientColor;
uniform vec4 tintColor;
uniform vec3 worldAmbientColor;

in vec2 v_texCoord0;
in vec3 worldPos;
in vec4 blocklight;
in vec3 faceNormal;

uniform sampler2D texDiffuse;
uniform vec3 u_sunDirection;
//Cosmic Illumination
uniform int isUnderwater;
//Cosmic Illumination End

out vec4 outColor;

//Cosmic Illumination
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float linearizeDepth(float depth, float near, float far) {
    return (2.0 * near * far) / (far + near - (depth * 2 - 1) * (far - near));
}

float logisticDepth(float depth, float steepness, float offset, float near, float far) {
    return 1 / (1 + exp(-steepness * (linearizeDepth(depth, near, far) - offset)));
}
//Cosmic Illumination End

void main() 
{
    vec2 tilingTexCoords = v_texCoord0;

    vec4 texColor = texture(texDiffuse, v_texCoord0);

    if(texColor.a == 0)
    {
        discard;
    }

    //Cosmic Illumination
    vec3 newSkyAmbientColor = min(skyAmbientColor*2, vec3(1.1, 1.1, 1.1)); //Increase brightness
    float dawnDot = dot(vec3(1, 0, 0), u_sunDirection);
    float duskDot = dot(vec3(-1, 0, 0), u_sunDirection);
    float brightness = 1;
    float dayNightDot = dot(vec3(0, 1, 0), u_sunDirection);
    if (dawnDot > duskDot) { //dawn
        if (faceNormal.y > 0) { //up
            brightness = dayNightDot > 0.9 ? 1.33 : 1.25;
        } else if (faceNormal.x > 0) { //east
            brightness = dayNightDot < -0.9 ? 0.75 : dayNightDot < 0.9 ? 1.33 : 1.25;
        } else if (faceNormal.x < 0) { //west
            brightness = dayNightDot < -0.9 ? dayNightDot < 0.9 ? 1.33 : 1.25 : 0.75;
        } else if (faceNormal.y < 0) { //down
            brightness = 0.5;
        } else { //north or south
            brightness = 1;
        }
    } else if (duskDot > dawnDot) { //dusk
        if (faceNormal.y > 0) { //up
            brightness = dayNightDot > 0.9 ? 1.33 : 1.25;
        } else if (faceNormal.x > 0) { //east
            brightness = dayNightDot < -0.9 ? dayNightDot < 0.9 ? 1.33 : 1.25 : 0.75;
        } else if (faceNormal.x < 0) { //west
            brightness = dayNightDot < -0.9 ? 0.75 : dayNightDot < 0.9 ? 1.33 : 1.25;
        } else if (faceNormal.y < 0) { //down
            brightness = 0.5;
        } else { //north or south
            brightness = 1;
        }
    }
    vec3 blockAmbientColor = newSkyAmbientColor * brightness;
    //Cosmic Illumination End

    // https://www.desmos.com/calculator
    // y\ =\ \frac{30}{1+e^{-15\left(\frac{x}{25}\right)^{2}}}-15
    vec3 it =  pow(15*blocklight.rgb / 25.0, vec3(2));
    vec3 t = 30.0/(1.0 + exp(-15.0 * it)) - 15;
    vec3 lightTint = max(t/15, blocklight.a * blockAmbientColor);
    //Cosmic Illumination
    lightTint = lightTint + vec3(0.06f, 0.04f, 0.11f); //Minimum light.
    //Cosmic Illumination End

    //lightTint = max(lightTint, vec3(0.1));
    //texColor = vec4(1);

    outColor = tintColor * vec4(texColor.rgb * lightTint, texColor.a);

    //Cosmic Illumination
    outColor.rgb = outColor.rgb - (texColor.rgb/10); //Ambient Occlusion.
    float redDimmer = 1+(outColor.r/10);
    vec3 hsvColor = rgb2hsv(outColor.rgb);
    outColor.rgb = hsv2rgb(hsvColor+vec3(0, ((max(max(lightTint.r, lightTint.g), lightTint.b))-0.7+max(max(newSkyAmbientColor.r, newSkyAmbientColor.g), newSkyAmbientColor.b))/10, min(1, hsvColor.z*redDimmer) - (hsvColor.z*redDimmer))); //Brightness based saturation.
    if (isUnderwater == 1) {
        float waterDist = logisticDepth(gl_FragCoord.z, 0.1, 10, 0.1, 100);
        vec3 newOutColor = (outColor.rgb/9)+(vec3(0.2, 0.2, 0.4)*max(0.2, skyColor.b)); //Base water lighting, with brightness reduced based on the skys blueness.
        vec3 underwaterMul = abs((t-15)/15)*waterDist;
        vec3 notUnderwaterMul = max((t/15), abs(waterDist-1))-0.15;
        outColor.rgb = (newOutColor*underwaterMul)+(outColor.rgb*notUnderwaterMul); //Smoothly transition to normal lighting based on blocklight.
    } else {
        float dist = max(0.3, (logisticDepth(gl_FragCoord.z, 0.1, 1, 0.01, 100)))-0.3;//Base fog.
        outColor.rgb = (outColor.rgb*min(1, abs(dist-1)*1.2))+(skyAmbientColor*(dist*1.3)); //Smoothly transition to normal lighting based on blocklight.
    }
    //Cosmic Illumination End
}