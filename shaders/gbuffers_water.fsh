#version 120

const bool watershadow = false;

varying vec4 texcoord;
varying vec4 color;
uniform sampler2D texture;
void main(){
    vec4 final = texture2D(texture, texcoord.st) * color;
    gl_FragData[0] = final;
    gl_FragData[6] = vec4(1);
}