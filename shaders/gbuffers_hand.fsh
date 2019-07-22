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

float height_scale = 300000000;

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
  // number of depth layers
  const float minLayers = 8.0;
  const float maxLayers = 128.0;
  float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));
  // calculate the size of each layer
  float layerDepth = 1.0 / numLayers;
  // depth of current layer
  float currentLayerDepth = 0.0;
  // the amount to shift the texture coordinates per layer (from vector P)
  vec2 P = viewDir.xy * height_scale;
  vec2 deltaTexCoords = P / numLayers;
  // get initial values
  vec2  currentTexCoords     = texCoords;
  float currentDepthMapValue = getLabNormal(currentTexCoords).a;

  while(currentLayerDepth < currentDepthMapValue)
  {
      // shift texture coordinates along direction of P
      currentTexCoords -= deltaTexCoords;
      // get depthmap value at current texture coordinates
      currentDepthMapValue = getLabNormal(currentTexCoords).a;
      // get depth of next layer
      currentLayerDepth += layerDepth;
  }

  vec2 prevTexCoords = currentTexCoords + deltaTexCoords;

  // get depth after and before collision for linear interpolation
  float afterDepth  = currentDepthMapValue - currentLayerDepth;
  float beforeDepth = getLabNormal(prevTexCoords).a - currentLayerDepth + layerDepth;

  // interpolation of texture coordinates
  float weight = afterDepth / (afterDepth - beforeDepth);
  vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

  return finalTexCoords;
}
void main(){
  float ambientStrength = 0.1;
  vec4 norm = getLabNormal(texcoord.st);
  vec4 color1 = vec4(blockColor.rgb, 1.0);
  vec3 viewDir = normalize(v - cameraPosition);
  vec2 texturecoords = ParallaxMapping(texcoord.st, viewDir);
  //if(texturecoords.x > 1.0 || texturecoords.y > 1.0 || texturecoords.x < 0.0 || texturecoords.y < 0.0)
    //discard;
  vec4 color = texture2D(texture, texcoord.st);
  vec4 spec = texture2D(specular, texturecoords);
  vec4 final = (color * color1);
  gl_FragData[0] = vec4(color.rgb, 1.0);
  gl_FragData[1] = norm * 0.5 + 0.5;
  gl_FragData[2] = spec;
}
