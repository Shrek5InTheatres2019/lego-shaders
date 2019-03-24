#version 120

uniform sampler2D tex;
uniform sampler2D lightmap;


varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

void main(){
  vec4 fragColor = texture2D(tex, texcoord.st);
  vec4 light = texture2D(lightmap, texcoord.st);
    //fragColor.rgb *= color.rgb;
    fragColor.rgb = mix(vec3(1.0), fragColor.rgb, isTransparent);

  gl_FragData[0] = fragColor;
}
