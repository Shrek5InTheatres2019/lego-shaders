#version 120

varying vec4 texcoord;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
varying vec3 lightVector;
uniform int worldTime;

void main(){
  gl_Position =  ftransform();
  texcoord = gl_MultiTexCoord0;
  if(worldTime >= 12700 && worldTime <= 23200){
    lightVector = moonPosition;
  }else{
    lightVector = sunPosition;
  }
}
