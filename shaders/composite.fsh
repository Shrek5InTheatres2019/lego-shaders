#version 120

#define PBRTextures

const float sunPathRotation    = 25.0;

varying vec4 texcoord;
varying vec3 N;
varying vec3 v;
//varying vec3 lightPosition;


uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;

float height_scale = 0.5;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

#include "/lib/orenNayarDiffuse.glsl"

vec4 getNormal(vec2 texcoords){
  return (texture2D(colortex1 , texcoords) * 2.0 - 1.0);
}
float getEmission(vec2 texcoords){
  return texture2D(depthtex0, texcoords).r;
}
vec3 colorCode(float r, float g, float b){
  vec3 back = vec3(r,g,b);
  back = back / 255;
  return back;
}

/* DRAWBUFFERS:0 */
void main(){

  #ifdef PBRTextures
    vec4 specular = texture2D(colortex1, texcoord.st);
    float roughness = pow(max(1.0-specular.r, 0.04), 2.0);
    float specularity = pow(clamp(specular.g, 0.0, 229.0/255.0), 2.0);
  #else
    vec4 specular = vec4(1.0);
    float roughness = 0;
    float specularity = 0.7;
  #endif
  vec4 norm = normalize(getNormal(texcoord.st));
  vec3 viewDir = normalize(cameraPosition - v);
  vec2 texturecoords = texcoord.st;
  float specularStrength = 0.5;
  vec4 alpha = texture2D(colortex0, texturecoords).rgba;
  vec4 col = texture2D(colortex0, texturecoords);
  vec3 color = col.rgb;
  float emission = getEmission(texturecoords);
  vec3 lightDirection = normalize(shadowLightPosition - v);
  vec3 eyeDirection = normalize(cameraPosition - v);
  vec3 reflectDir = reflect(-lightDirection, norm.rgb);

  //float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
  //vec3 specu = specularity * spec * vec3(1.0);
  float ambient = 0.3;
  float power = orenNayarDiffuse(lightDirection, eyeDirection, norm.rgb, roughness, 0.7);
  vec3 color1 = (color * ((power + ambient))) * 1.5;
  vec3 final = mix(color1, color, emission);
  gl_FragData[0] = vec4(color1, col.a);
}
