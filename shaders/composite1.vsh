#version 120

varying vec4 texcoord;

varying vec3 N;
varying vec3 v;
varying vec4 FragPos;

void main()
{
   v = vec3(gl_ModelViewMatrix * gl_Vertex);
   N = normalize(gl_NormalMatrix * gl_Normal);
   texcoord = gl_MultiTexCoord0;
   gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
