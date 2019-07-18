#version 120

varying vec4 texcoord;
varying vec3 N;
varying vec3 v;

uniform vec3 shadowLightPosition;

uniform sampler2D colortex0;
/* DRAWBUFFERS:0 */
void main(){
  vec3 color = texture2D(colortex0, texcoord.st).rgb;
  
  gl_FragData[0] = vec4(color,  1.0);
}
