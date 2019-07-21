#version 120

varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;


uniform sampler2D texture;

/* DRAWBUFFERS:01 */



void main(){
  float ambientStrength = 0.1;
  vec4 color1 = vec4(blockColor.rgb, 1.0);

  vec4 color = texture2D(texture, texcoord.st);
  vec4 final = color * color1;
  gl_FragData[0] = final;
  gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
}
