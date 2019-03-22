#version 120

varying vec4 texcoord;
varying vec4 color;
varying vec3 normal;
uniform sampler2D texture;

void main(){
    vec4 col = texture2D(texture, texcoord.st);
    col *= color;
    gl_FragData[0] = col;
    gl_FragData[2] = vec4(normal, 1.0) * 0.5 + 0.5;
}