#version 120

const int RGBA16                = 1;
const int gcolorformat          = RGBA16;
const int shadowMapResolution   = 4096;
const int noiseTextureResolution= 64;

const float sunPathRotation    = 25.0;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

uniform sampler2D gdepthtex;
uniform sampler2D shadow;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D noisetex;
uniform sampler2D shadowcolor0;
uniform sampler2D lightmap;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;
uniform float viewHeight;
uniform float viewWidth;

uniform vec3 sunPosition;

uniform int worldTime;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec4 texcoord;

/* DRAWBUFFERS:012 */

float getDepth(in vec2 coord){
  return texture2D(gdepthtex, coord).r;
}

vec4 getCameraSpacePosition(in vec2 coord) {
  float depth = getDepth(coord);
  vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
  vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;
  return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePosition(in vec2 coord){
  vec4 positionCameraSpace = getCameraSpacePosition(coord);
  vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
  positionWorldSpace.xyz += cameraPosition.xyz;

  return positionWorldSpace;
}

vec3 getShadowSpacePosition(in vec2 coord){
  vec4 positionWorldSpace = getWorldSpacePosition(coord);

  positionWorldSpace.xyz -= cameraPosition.xyz;
  vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
  positionShadowSpace = shadowProjection * positionShadowSpace;
  positionShadowSpace /= positionShadowSpace.w;

  return positionShadowSpace.xyz * 0.5 +  0.5;
}

mat2 getRotationMatrix(in vec2 coord){
  float rotationAmount = texture2D(
    noisetex,
    coord * vec2(
        viewWidth / noiseTextureResolution,
        viewHeight / noiseTextureResolution
      )
    ).r;

    return mat2(
      cos(rotationAmount), -sin(rotationAmount),
      sin(rotationAmount), cos(rotationAmount)
      );
}

vec3 getShadowColor(in vec2 coord){
  if(getDepth(coord) == 1.0){
    return vec3(1.0);
  }
  vec3 shadowCoord = getShadowSpacePosition(coord);

  vec3 shadowColor = vec3(0.0);
  mat2 rotationMatrix = getRotationMatrix(coord);
  for(int y = -1; y < 2; y++){
    for(int x = -1; x < 2; x++){
      vec2 offset = vec2(x, y) / shadowMapResolution;
      offset = rotationMatrix * offset;
      float shadowMapSample = texture2D(shadowtex1, shadowCoord.st + offset).r;
      float visibility = step(shadowCoord.z - shadowMapSample, 0.003);
      vec4 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset);
      shadowColor += mix(vec3(1.0), colorSample.rgb, colorSample.a)*visibility;
      
    }
  }
  return shadowColor * 0.111;
}

vec3 calculateLitSurface(in vec3 color){
  vec3 sunLightAmount = getShadowColor(texcoord.st);
  vec3 ambientLighting = vec3(0.3);
  float night = 1.0;
  if(worldTime >= 13000 && worldTime < 1000){
    night = 0.02;
  }

  return color * (sunLightAmount + ambientLighting) * night;
}



void main(){
  vec3 finalComposite = texture2D(gcolor, texcoord.st).rgb;
  vec3 finalCompositeNormal = texture2D(gnormal, texcoord.st).rgb;
  vec3 finalCompositeDepth = texture2D(gdepth, texcoord.st).rgb;

  finalComposite *= calculateLitSurface(finalComposite);

  gl_FragData[0] = vec4(finalComposite, 1.0);
  gl_FragData[1] = vec4(finalCompositeNormal, 1.0);
  gl_FragData[2] = vec4(finalCompositeDepth, 1.0);
}
