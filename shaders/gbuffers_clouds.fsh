#version 120

varying vec4 texcoord;
varying vec4 blockColor;

uniform sampler2D colortex0;

/* DRAWBUFFERS:0 */

void main(){
  float ambientStrength = 0.1;
  vec4 color1 = vec4(blockColor.rgb, 1.0);

  vec4 color = texture2D(colortex0, texcoord.st);
  vec4 final = color * color1;
  gl_FragData[0] = final;
}
