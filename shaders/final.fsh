#version 120

varying vec4 texcoord;

uniform sampler2D colortex0;

/* DRAWBUFFERS:0 */

void main(){
  vec3 color = texture2D(colortex0, texcoord.st).rgb;
  color = vec3((color.r + color.g + color.b) / 3);
  gl_FragData[0] = vec4(color, 1.0);
}
