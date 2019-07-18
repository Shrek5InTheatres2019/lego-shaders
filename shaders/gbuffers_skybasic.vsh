#version 120

varying vec4 texcoord;
varying vec3 color;
varying vec3 normal;


void main(){
  texcoord = gl_MultiTexCoord0;
  color = gl_Color.rgb;
  normal = (gl_NormalMatrix * gl_Normal).rgb;
  vec4 position = gl_Vertex;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
}
