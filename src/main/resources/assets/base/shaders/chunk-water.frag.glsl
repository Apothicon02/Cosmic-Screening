#version 150
#ifdef GL_ES 
precision mediump float;
#endif

uniform float u_time;
uniform vec3 skyAmbientColor;
uniform vec3 skyColor;
uniform vec4 tintColor;
uniform vec3 worldAmbientColor;

in vec2 v_texCoord0;
in vec4 blocklight;
in float waveStrength;
in vec3 worldPos;
in vec3 toCameraVector;

uniform sampler2D texDiffuse;
uniform sampler2D noiseTex;

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

    vec2 numTiles = floor(v_texCoord0);
    vec2 tilingTexCoords = v_texCoord0;
    
    if(numTiles.xy != vec2(0, 0))
    {
        tilingTexCoords = (v_texCoord0 - numTiles);
        vec2 flooredTexCoords = floor((v_texCoord0 - numTiles) * 16) / 16;
        numTiles = numTiles + vec2(1,1);

        tilingTexCoords = flooredTexCoords + mod(((tilingTexCoords - flooredTexCoords) * numTiles) * 16, 1) / 16;
    }

    vec4 texColor = texture(texDiffuse, tilingTexCoords);

    vec3 viewVector = normalize(toCameraVector);
    vec3 faceNormal = vec3(0.0, 1.0, 0.0);
    float fresnel = abs(dot(viewVector, faceNormal));

    vec2 noiseUV = 1*vec2(waveStrength - 0.1) + worldPos.xz / 16.0;
    noiseUV+=vec2(u_time*0.02);
    vec2 distortion = fresnel * texture(noiseTex, noiseUV).rg;
    vec3 waterColor = texColor.rgb;

    fresnel = pow(fresnel, mix(3, 1, 0.2*(waveStrength - 0.1 + distortion.r/3.0)));
    fresnel = pow(fresnel, 0.35);
    waterColor = mix(waterColor * 0.5, waterColor, 0.5 + 0.5*waveStrength*(1-fresnel));
    
    waterColor = mix(waterColor * 0.75, waterColor, fresnel);
    waterColor = mix(waterColor, skyColor, blocklight.a * (1-fresnel));


    vec3 lightTint = max(blocklight.rgb, blocklight.a * skyAmbientColor);
    float alpha = mix(texColor.a*2.0, texColor.a*0.5, fresnel);
    
    if(alpha == 0)
    {
        discard;
    }

    outColor = vec4(waterColor * lightTint, alpha);
    outColor.rgb = mix(outColor.rgb, skyColor, blocklight.a * (1-fresnel));
    outColor *= tintColor;
    outColor.rgb = max(outColor.rgb, texColor.rgb * worldAmbientColor);

    //Cosmic Illumination
    vec3 hsv = rgb2hsv(outColor.rgb);
    outColor.rgb = hsv2rgb(vec3(hsv.x, min(1, outColor.b*4), hsv.z+0.3)); //Boost brightness and adjust saturation based on blueness.
    float dist = max(0, logisticDepth(gl_FragCoord.z, 0.1, 1, 0.01, 100)-0.15)*1.15;//Base fog lighting.
    outColor.rgb = (outColor.rgb*min(1, abs(dist-1)*1.2))+(skyAmbientColor*(dist*1.3)); //Smoothly transition to normal lighting based on blocklight.
    //Cosmic Illumination End
}