#version 120

//#include "/lib/SSR.glsl"

const bool watershadow = false;

varying vec4 texcoord;
varying vec4 color;
varying vec3 normal;
uniform sampler2D texture;
void main(){
    vec4 final = texture2D(texture, texcoord.st) * color;
    gl_FragData[0] = final;
    gl_FragData[2] = vec4(normal, 1.0) * 0.5 + 0.5;
}