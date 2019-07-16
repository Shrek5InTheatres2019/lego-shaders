#version 120

#define BRIGHTNESS 1.0 //make things brighter, or darker, if you're into that [0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define Vignette //Vignette, makes the outsides of the screen darker, and the inside normal coloured
#define DOF //Depth of field, makes things that should be out of focus out of focus
#define saturationFix // Desaturates the image to make it seem more natural;
#define Reinhardt //uwu

const int RGBA16                = 1;
const int gcolorformat          = RGBA16;

 const float PI = 3.14159265;

 varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D gdepthtex;
uniform float centerDepthSmooth;
float bokehBias = 0.8;
float bokehFringe = 0.7;
float highlightThreshold = 0.7;
float highlightGain = 0.8;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform sampler2D depthtex1;

 const float depthSamples = 5.0;
const float depthRings = 7.0;

 float getDepth(in vec2 coord){
  return texture2D(gdepthtex, coord).r;
}

 vec3 uncharted2Tonemap(const vec3 x) {
	const float A = 0.15;
	const float B = 0.50;
	const float C = 0.10;
	const float D = 0.20;
	const float E = 0.02;
	const float F = 0.30;
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

 vec3 doVignette(in vec3 color) {
	float dist = distance(texcoord.st, vec2(0.5f)) * 1.3f;
	dist /= 1.5142f;

 	dist = pow(dist, 1.05f);

 	return color.rgb *= 1.0f - dist;

 }

 vec3 tonemapUncharted2(in vec3 color) {
	const float W = 11.2;
	const float exposureBias = 2.5;
	vec3 curr = uncharted2Tonemap(exposureBias * color);
	vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	return curr * whiteScale;
}

vec3 Reinhard(vec3 texColor)
{
   texColor = texColor * 16;  // Hardcoded Exposure Adjustment
   texColor = texColor/(1+texColor);
   vec3 retColor = pow(texColor,vec3(1/2.2));
   return retColor;
}

vec3 doHDR(in vec3 color){
	vec3 hdrImage;

	vec3 overExposed = color * 1.2;
	vec3 underExposed = color / 1.5;

	hdrImage = mix(underExposed, overExposed, color);

	return hdrImage;
}

vec3 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return mix(color, gray, Desaturation);
}

#include "/lib/DepthOfField.glsl"

 void main() {
	vec3 color = texture2D(gcolor, texcoord.st).rgb;
	color *= BRIGHTNESS;
	#ifdef Vignette
		color = doVignette(color);
	#endif
	#ifdef DOF
		color = depthOfField(color);
	#endif
	#ifdef saturationFix
		color = Desaturate(color, 0.2);
	#endif
	#ifdef Reinhardt
		color = Reinhard(color);
	#endif
	color *= BRIGHTNESS;
	gl_FragData[0] = vec4(color, 1.0);
}
