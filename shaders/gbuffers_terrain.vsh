#version 120


varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;
varying vec3 tangent;
varying vec3 binormal;
attribute vec4 at_tangent;



void main(){
  texcoord = gl_MultiTexCoord0;
  blockColor = gl_Color;
  normal        = normalize(gl_NormalMatrix*gl_Normal);
  tangent       = normalize(gl_NormalMatrix * at_tangent.xyz);
  binormal     = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
  vec4 position = gl_Vertex;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
}
