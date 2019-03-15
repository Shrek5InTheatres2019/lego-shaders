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
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform float resolution;

const float depthSamples = 20.0;
const float depthRings = 20.0;

float getDepth(in vec2 coord){
  return texture2D(gdepthtex, coord).r;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 depthOfField(in vec4 color, in vec2 coord){
	float aperture = 7;
	float imageDistance = 1.0;
	float focalLength = imageDistance * centerDepthSmooth;
	float objectDistance = getDepth(coord);
	float CoC = abs(aperture * ((focalLength * (centerDepthSmooth - objectDistance)) / (objectDistance - (centerDepthSmooth - focalLength))));
	CoC = clamp(CoC, 0.0, 20.0);
	vec3 col = vec3(0);
	vec4 sum = vec4(0.0);

	vec2 tc = coord;
	
	float blur = CoC*0.02; 
  
	float hstep = 1.0;
	float vstep = 0.0;
    
	sum += texture2D(gcolor, vec2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
	sum += texture2D(gcolor, vec2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
	sum += texture2D(gcolor, vec2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
	sum += texture2D(gcolor, vec2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;
	
	sum += texture2D(gcolor, vec2(tc.x, tc.y)) * 0.2270270270;
	
	sum += texture2D(gcolor, vec2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
	sum += texture2D(gcolor, vec2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
	sum += texture2D(gcolor, vec2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
	sum += texture2D(gcolor, vec2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

	color *= vec4(sum.rgb, 1.0);

	sum = vec4(0.0);

	hstep = 0.0;
	vstep = 1.0;

	sum += texture2D(gcolor, vec2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
	sum += texture2D(gcolor, vec2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
	sum += texture2D(gcolor, vec2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
	sum += texture2D(gcolor, vec2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;
	
	sum += texture2D(gcolor, vec2(tc.x, tc.y)) * 0.2270270270;
	
	sum += texture2D(gcolor, vec2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
	sum += texture2D(gcolor, vec2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
	sum += texture2D(gcolor, vec2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
	sum += texture2D(gcolor, vec2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

	color *= vec4(sum.rgb, 1.0);

	return color.rgb;
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
		color.rgb = depthOfField(color, texcoord.st);
	#endif
	//color = tonemapUncharted2(color);
	color *= BRIGHTNESS;
	gl_FragData[0] = color;
	gl_FragData[7] = vec4(color.rgb, 1.0);
}
