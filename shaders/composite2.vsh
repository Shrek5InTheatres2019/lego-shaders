#version 120

varying vec4 texcoord;

void main(){
  texcoord = gl_MultiTexCoord0;
  gl_Position = ftransform();
}
