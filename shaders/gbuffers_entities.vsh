#version 120

varying vec4 texcoord;
varying vec4 color;
varying vec3 normal;
void main(){
    texcoord = gl_MultiTexCoord0;
    gl_Position = ftransform();
    color = gl_Color;
    normal = gl_NormalMatrix * gl_Normal;
}