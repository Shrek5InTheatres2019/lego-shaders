#version 120

#define VintageFilter //makes your screen look all vintage and fancy like
#define DOF //Real good looking Depth Of Field Effect thanks to i believe Xenith



varying vec4 texcoord;

uniform sampler2D gdepthtex;
uniform sampler2D colortex0;
uniform sampler2D depthtex1;
uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

/* DRAWBUFFERS:0 */

float getDepth(in vec2 coord){
 return texture2D(gdepthtex, coord).r;
}

vec3 Overlay (vec3 src, vec3 dst) {
    return vec3((dst.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - dst.x) * (1.0 - src.x)), (dst.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - dst.y) * (1.0 - src.y)), (dst.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - dst.z) * (1.0 - src.z)));
}

float rand(vec2 co) {
      return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

#include "/lib/DepthOfField.glsl"

void main(){
  vec3 color = texture2D(colortex0, texcoord.st).rgb;
  #ifdef VintageFilter
    vec3 sepia = vec3(112.0 / 255.0, 66.0 / 255.0, 20.0 / 255.0);
    vec3 noiseLevel = vec3(0.07, 0.07, 0.07);
    color = vec3((color.r + color.g + color.b) / 3);
    color = Overlay(color, sepia);
    float randomDelta = (rand(texcoord.st) * 2.0) - 1.0;
    color += noiseLevel * randomDelta;
  #endif

  #ifdef DOF
    color = depthOfField(color);
  #endif
  gl_FragData[0] = vec4(color, 1.0);
}
