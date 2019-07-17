#version 120


varying vec4 texcoord;
varying vec4 blockColor;


void main(){
  texcoord = gl_MultiTexCoord0;
  blockColor = gl_Color;
  vec4 position = gl_Vertex;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
}
