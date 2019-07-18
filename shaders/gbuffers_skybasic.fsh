#version 120

uniform sampler2D colortex0;

varying vec3 color;
varying vec4 texcoord;
varying vec3 normal;
/* DRAWBUFFERS:01 */

void main(){
  vec3 final = texture2D(colortex0, texcoord.st).rgb;
  final = final * color;
  gl_FragData[0] = vec4(color, 1.0);
  gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
}
