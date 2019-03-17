#version 120

varying vec4 texcoord;
varying vec4 color;

void main(){
    texcoord = gl_MultiTexCoord0;
    gl_Position = ftransform();
    color = gl_Color;
}