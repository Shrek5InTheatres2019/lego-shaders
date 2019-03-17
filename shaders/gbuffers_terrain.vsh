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
const float PI = 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(){
    texcoord = gl_MultiTexCoord0;

    blockColor = gl_Color;

    bool isTop = false;
    if(texcoord.y < mc_midTexCoord.y){ 
        isTop = true;
    }
    vec3 worldPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz + cameraPosition;
    if(isTop){
        if(mc_Entity.x == 31){
            float magnitude = sin(PI / 58.0) * 0.3;
            worldPos.x += sin(PI / 84) * magnitude;
            worldPos.y += sin(PI / 99) * magnitude;
        }
    }
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(worldPos - cameraPosition, 1.0));
}