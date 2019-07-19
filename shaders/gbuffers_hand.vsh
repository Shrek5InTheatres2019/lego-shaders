#version 120


varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;

void main(){
  texcoord = gl_MultiTexCoord0;
  blockColor = gl_Color;
  normal = gl_NormalMatrix * gl_Normal;
  vec4 position = gl_Vertex;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
}
