#version 120

varying vec4 texcoord;

varying vec4 blockColor;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float frameTime;
uniform sampler2D noisetex;
uniform mat4 gbufferModelView;
attribute vec2 mc_midTexCoord;  
attribute vec3 mc_Entity;

void main(){
    texcoord = gl_MultiTexCoord0;

    blockColor = gl_Color;

    bool isTop = false;
    if(texcoord.y < mc_midTexCoord.y){ 
        isTop = true;
    }
    float wind_scale = 0.15;
    vec3 worldPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz + cameraPosition;
    if(isTop){
        if(mc_Entity.x == 31){
            worldPos.x += wind_scale * ((sin(worldTime*0.07) + sin((worldTime + sin(texcoord.s))*0.07)  - 0.5)) + texture2D(noisetex, worldPos.xy).r;
        }
    }
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(worldPos - cameraPosition, 1.0));
}