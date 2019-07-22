#version 120

varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 v;
uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform vec3 cameraPosition;
/* DRAWBUFFERS:012 */

float height_scale = 1;

mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal .x,
                tangent.y, binormal.y, normal .y,
                tangent.z, binormal.z, normal .z);

vec4 getLabNormal(vec2 texCoords) {

    vec3 texnormal      = texture2D(normals, texCoords).rgb;
        texnormal       = texnormal*2.0-(254.0/255.0);

        float ao          = pow(length(texnormal), 2.0);

        texnormal       = normalize(texnormal);
        //texnormal       = flattenNormal(texnormal);

    vec4 n  = vec4(normalize(texnormal*tbnMatrix), ao);
    return n;
}
vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{
    float height =  getLabNormal(texCoords).r;
    vec2 p = viewDir.xy / viewDir.z * (height * height_scale);
    return texCoords - p;
}
void main(){
  float ambientStrength = 0.1;
  vec4 norm = getLabNormal(texcoord.st);
  vec4 color1 = vec4(blockColor.rgb, 1.0);
  vec3 viewDir = normalize(v - cameraPosition);
  vec2 texturecoords = ParallaxMapping(texcoord.st, viewDir);
  if(texturecoords.x > 1.0 || texturecoords.y > 1.0 || texturecoords.x < 0.0 || texturecoords.y < 0.0)
    discard;
  vec4 color = texture2D(texture, texturecoords);
  vec4 spec = texture2D(specular, texturecoords);
  vec4 final = (color * color1);
  gl_FragData[0] = vec4(final.r, final.g, final.b, color.a);
  gl_FragData[1] = norm * 0.5 + 0.5;
  gl_FragData[2] = spec;
}
