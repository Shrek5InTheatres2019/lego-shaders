#version 120

varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;
varying vec3 tangent;
varying vec3 binormal;

uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;
/* DRAWBUFFERS:012 */

mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal .x,
                tangent.y, binormal.y, normal .y,
                tangent.z, binormal.z, normal .z);

vec3 getLabNormal() {

    vec3 texnormal      = texture2D(normals, texcoord.st).rgb;
        texnormal       = texnormal*2.0-(254.0/255.0);

        float ao          = pow(length(texnormal), 2.0);

        texnormal       = normalize(texnormal);
        //texnormal       = flattenNormal(texnormal);

    vec3 n  = normalize(texnormal*tbnMatrix);
    return n;
}

void main(){
  float ambientStrength = 0.1;
  vec4 color1 = vec4(blockColor.rgb, 1.0);

  vec4 color = texture2D(texture, texcoord.st);
  vec4 spec = texture2D(specular, texcoord.st);
  vec4 final = color * color1;
  gl_FragData[0] = vec4(final.r, final.g, final.b, color.a);
  gl_FragData[1] = vec4(getLabNormal() * 0.5 + 0.5, 1.0);
  gl_FragData[2] = spec;
}
