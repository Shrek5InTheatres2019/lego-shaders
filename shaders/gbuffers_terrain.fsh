#version 120

varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;
uniform sampler2D tex;
uniform sampler2D lightmap;

void main(){
    vec4 color = texture2D(tex, texcoord.st);
    color *= blockColor;
    gl_FragData[0] = color;
    gl_FragData[2] = vec4(normal, 1.0) * 0.5 + 0.5;
}