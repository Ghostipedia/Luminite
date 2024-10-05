#version 460
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;

/* DRAWBUFFERS: 0 */
layout(location = 0) out vec4 colorOut0;
in vec2 textureCord0;
in vec3 foliageColor;
in vec2 lightMappingCords;
in vec3 geoNormal;

void main() {

    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 worldGeoNorm = mat3(gbufferModelViewInverse) * geoNormal;

    float lightBrightness = clamp(dot(shadowLightDirection, worldGeoNorm),0.05,1.0);

    vec3 lightCol = pow(texture(lightmap,vec2(lightMappingCords)).rgb,vec3(2.2));

    vec4 outputColorData = pow(texture(gtexture,textureCord0),vec4(2.2));
    vec3 outputColor = outputColorData.rgb * pow(foliageColor,vec3(2.2)) * lightCol;
    float transparency = outputColorData.a;
    
    if(transparency < .1) {
        discard;
    }
    outputColor *= lightBrightness;
	colorOut0 = vec4(pow(outputColor, vec3(1/2.2)),transparency);
}