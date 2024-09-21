#version 150
#ifdef GL_ES 
precision mediump float;
#endif

in vec3 v_position;
in vec3 v_position_adjusted;
in vec3 v_normal;
out vec4 outColor;
uniform vec3 u_sunDirection;
uniform vec3 cameraPosition;
//Cosmic Illumination
uniform int isUnderwater;
//Cosmic Illumination End

void main() 
{
    vec3 pos_normal = normalize(v_position);
    vec3 pos_adj_normal = normalize(v_position);
    float sunRadius = 0.005;
    float sun_dot = dot(u_sunDirection, pos_normal);
    float noon_dot = dot(u_sunDirection, vec3(0, 1, 0));
    float sunFactor = (sun_dot - (1 - sunRadius)) / sunRadius;
    float horizonFactor = 1-abs(pos_adj_normal.y);
    
    vec3 upperColor = vec3(0.1, 0.4, 0.7);
    float upperHalfFactor = sqrt(max(0, dot(vec3(0,1,0), pos_adj_normal)));
    float upperColorFactor = upperHalfFactor * clamp(1 - (pow(1 - noon_dot, 3)), 0, 1);
    vec3 lowerColor = vec3(0.2, 0.4, 0.7) * 3;
    float lowerColorFactor = (1 - max(0, upperHalfFactor)) * max(0, (noon_dot +0.75)/1.75);
    vec3 skyColor = (upperColor * upperColorFactor) + (lowerColor * lowerColorFactor);

    float sunsetOrSunRiseFactor = pow(1-abs(noon_dot), 2);
    vec3 redHorizonColor = vec3(3, 0, 0) * pow(horizonFactor,4) * sunsetOrSunRiseFactor;
    skyColor = max(skyColor, redHorizonColor);

    vec3 crossDir = cross(u_sunDirection, vec3(0,1,0));
    float sunHorizonFlareFactor = pow(1 - pow(dot(cross(u_sunDirection, crossDir), pos_normal), 2), 8) * pow(1 - abs(noon_dot), 4) * sun_dot;// * max(0, (noon_dot+0.25)/1.25);
    vec3 sunFlareHorizonColor = vec3(1,1,0) * sunHorizonFlareFactor;
    skyColor = max(skyColor, sunFlareHorizonColor);


    vec3 sunColor = vec3(1, 0.9, 0.6) * sunFactor;

    skyColor = max(skyColor, sunColor);

    float alpha = max(0.1, max(min(length(skyColor), (sun_dot+2)/3), min(1, round(sunFactor*2)))) + max(0, noon_dot);
    alpha = max(0, min(alpha, 1));
   
    outColor = vec4(skyColor / alpha, alpha);
    //Cosmic Illumination
    if (isUnderwater == 1) {
        outColor.rgb = (vec3(0.1, 0.1, 0.3)*max(0.1, dot(u_sunDirection, vec3(0, 1, 0))))+vec3(0.1, 0.1, 0.4); //Make sky very blue when underwater, with brightness reduced based on the time of day.
    }
    //Cosmic Illumination End
}