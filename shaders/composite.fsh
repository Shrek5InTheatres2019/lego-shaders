#version 120

varying vec4 texcoord;
varying vec3 N;
varying vec3 v;

uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D gdepthtex;

#include "/lib/orenNayarDiffuse.glsl"

vec3 getNormal(){
  return (texture2D(colortex1 , texcoord.st) * 2.0 - 1.0).rgb;
}
float getEmission(){
  return texture2D(gdepthtex, texcoord.st).r;
}
/* DRAWBUFFERS:0 */
void main(){
  vec3 color = texture2D(colortex0, texcoord.st).rgb;
  float emission = getEmission();
  vec3 lightDirection = normalize(shadowLightPosition - v);
  vec3 eyeDirection = normalize(cameraPosition - v);
  float ambient = 0.3;
  float power = orenNayarDiffuse(lightDirection, eyeDirection, getNormal(), 0.3, 0.7);
  vec3 color1 = (color * (power + ambient));
  vec3 final = mix(color, color1, emission);
  gl_FragData[0] = vec4(final, 1.0);
}
