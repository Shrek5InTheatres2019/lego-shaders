#version 120

varying vec4 texcoord;
varying vec4 color;
uniform sampler2D texture;

void main(){
    vec4 col = texture2D(texture, texcoord.st);
    col *= color;
    gl_FragData[0] = col;
}