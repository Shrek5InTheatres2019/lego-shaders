#version 120

#define BRIGHTNESS 1.0 //make things brighter, or darker, if you're into that [0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define Vignette //Vignette, makes the outsides of the screen darker, and the inside normal coloured
#define MotionBlur //Motion blur, blurs things in motion
#define DepthOfField //Depth of field, things not where you're looking go out of focus

const bool gaux1Clear = false;

const float PI = 3.14159265;

varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D gdepthtex;
uniform float centerDepthSmooth;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform sampler2D gaux4;
float bokehBias = 0.8;
float bokehFringe = 0.7;
float highlightThreshold = 0.7;
float highlightGain = 0.8;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;

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
			float offset = ((clamp(rand(coord), 0.0, 1.0) * CoC) );
			col += texture2D(gcolor, coord + offset).rgb;
		}
	}

	return col / (depthSamples * depthRings);
}

vec3 motionBlur(in vec3 color,in vec2 coord){
   float zOverW = texture2D(gdepthtex, coord).r;
   vec4 H = vec4(coord.s * 2 - 1, (1 - coord.t) * 2 - 1,
zOverW, 1);
   vec4 D = H * gbufferProjectionInverse;
   vec4 worldPos = D / D.w;
   vec4 currentPos = H;
   vec4 previousPos = worldPos * gbufferPreviousProjection;
	 previousPos /= previousPos.w;
   vec2 velocity = ((currentPos - previousPos)/2.f).st;
coord += velocity;
for(int i = 1; i < 4; ++i, coord += velocity)
{
   vec4 currentColor = texture2D(gcolor, coord);
   color.rgb += currentColor.rgb;
}
    return color / 4;
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
	vec4 color = texture2D(gcolor, texcoord.st);
	#ifdef Vignette
		color.rgb = doVignette(color.rgb);
	#endif
	#ifdef DepthOfField
		color.rgb = depthOfField(color.rgb, texcoord.st);
	#endif
	//color.rgb = motionBlur(color.rgb, texcoord.st);
	//color = tonemapUncharted2(color);
	gl_FragData[0] = vec4(color.rgb, 1.0);
	gl_FragData[7] = vec4(color.rgb, 1.0);
}
