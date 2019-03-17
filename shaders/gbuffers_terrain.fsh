#version 120

varying vec4 texcoord;
varying vec4 blockColor;
uniform sampler2D tex;

void main(){
    vec4 color = texture2D(tex, texcoord.st);
    color *= blockColor;
    gl_FragData[0] = color;
}