#version 120

#define BRIGHTNESS 1.0 //make things brighter, or darker, if you're into that [0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define Vignette //Vignette, makes the outsides of the screen darker, and the inside normal coloured
#define MotionBlur //Motion blur, blurs things in motion
#define DepthOfField //Depth of field, things not where you're looking go out of focus

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

const float depthSamples = 5.0;
const float depthRings = 7.0;

float getDepth(in vec2 coord){
  return texture2D(gdepthtex, coord).r;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 depthOfField(in vec3 color, in vec2 coord){
	float blur = 0.0;
	float aperture = 7;
	float imageDistance = 1.0;
	float focalLength = imageDistance * centerDepthSmooth;
	float objectDistance = getDepth(coord);
	float CoC = abs(aperture * ((focalLength * (centerDepthSmooth - objectDistance)) / (objectDistance - (centerDepthSmooth - focalLength))));
	CoC = clamp(CoC, 0.0, 20.0);
	vec3 col = vec3(0);
	for(int i = 0; i < depthRings; i++){
		for(int j = 0; j < depthSamples; j++){
			float offset = ((clamp(rand(coord), 0.0, 1.0) * CoC) * 0.01);
			col += texture2D(gcolor, coord + offset).rgb;
		}
	}

	return col / (depthSamples * depthRings);
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
	const float exposureBias = 2.0;
	vec3 curr = uncharted2Tonemap(exposureBias * color);
	vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	return curr * whiteScale;
}

void main() {
	vec3 color = texture2D(gcolor, texcoord.st).rgb;
	color *= BRIGHTNESS;
	#ifdef Vignette
		color = doVignette(color);
	#endif
	#ifdef DepthOfField
		color = depthOfField(color, texcoord.st);
	#endif
	//color = tonemapUncharted2(color);
	gl_FragData[0] = vec4(color, 1.0);
}
