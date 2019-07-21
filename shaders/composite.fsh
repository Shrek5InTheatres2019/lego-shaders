#version 120

#define PBRTextures

const float sunPathRotation    = 25.0;

varying vec4 texcoord;
varying vec3 N;
varying vec3 v;
//varying vec3 lightPosition;


uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D gdepthtex;

#include "/lib/orenNayarDiffuse.glsl"

vec3 getNormal(){
  return (texture2D(colortex1 , texcoord.st) * 2.0 - 1.0).rgb;
}
float getEmission(){
  return texture2D(gdepthtex, texcoord.st).r;
}
vec3 colorCode(float r, float g, float b){
  vec3 back = vec3(r,g,b);
  back = back / 255;
  return back;
}
/* DRAWBUFFERS:0 */
void main(){
  float specularStrength = 0.5;
  vec4 alpha = texture2D(colortex0, texcoord.st).rgba;
  vec3 color = texture2D(colortex0, texcoord.st).rgb;
  #ifdef PBRTextures
    vec4 specular = texture2D(colortex1, texcoord.st);
    float roughness = pow2(max(1.0-specular.r, 0.04));
    float specularity = pow2(clamp(specular.g, 0.0, 229.0/255.0));
  #else
    float roughness = 0;
    float specularity = 0.7;
  #endif
  float emission = getEmission();
  vec3 lightDirection = normalize(shadowLightPosition - v);
  vec3 eyeDirection = normalize(cameraPosition - v);
  vec3 viewDir = normalize(cameraPosition - v);
  vec3 reflectDir = reflect(-lightDirection, normalize(getNormal()));

  //float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
  //vec3 specu = specularity * spec * vec3(1.0);
  float ambient = 0.3;
  float power = orenNayarDiffuse(lightDirection, eyeDirection, normalize(getNormal()), roughness, 0.7);
  vec3 color1 = (color * ((power + ambient))) * 1.5;
  vec3 final = mix(color, color1, emission);
  gl_FragData[0] = vec4(final, alpha.a);
}
