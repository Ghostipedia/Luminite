#version 330 compatibility
#include "/lib/distort.glsl"
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform int worldTime;

uniform float viewHeight;
uniform float viewWidth;

uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
in vec2 texcoord;


/* DRAWBUFFERS: 0 */
layout(location = 0) out vec4 color;

//Sunrise - 23215
//Sunset - 12785

float normalizedTime = float(worldTime) / 24000;
vec3 nightlightColor = vec3(0.173,0.718,0.859);
vec3 dayLightColor = vec3(1,0.906,0.663);
float timeFactor = sin(normalizedTime * 2.0 * 3.14159);
float dayNightScaleFactor = (timeFactor + 1.0) / 2.0;

vec3 mixTimeColor =mix(nightlightColor,dayLightColor,dayNightScaleFactor);

vec3 dawnDuskColor = vec3(0.929,0.49,0.0);


//This handles the day color and night color, but does not blend in colors for sunrise/set
vec3 sunlightColor1 = mix(nightlightColor.rgb,dayLightColor.rgb,mixTimeColor).rgb;
vec3 sunlightColor2 = mix(sunlightColor1.rgb, dawnDuskColor.rgb,timeFactor).rgb;
vec3 sunlightColor = nightlightColor.rgb ;
// const vec3 sunlightColor = vec3(0.941,0.69,0.137);




const vec3 torchColor = vec3(1.0, 0.5, 0.08);
const vec3 skyColor = vec3(0.05, 0.15, 0.3);
const vec3 ambientColor = vec3(0.1);

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}
vec3 getShadow(vec3 shadowScreenPos){
  float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
  if(transparentShadow == 1.0){
    return vec3(1.0);
  }

  float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);

  if(opaqueShadow == 0.0){
    return vec3(0.0);
  }

  vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);

  return shadowColor.rgb * (1.0 - shadowColor.a);
}
vec4 getNoise(vec2 coord){
  ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight)); 
  ivec2 noiseCoord = screenCoord % 64; 
  return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 shadowClipPos){
  const float range = SHADOW_SOFTNESS / 2; 
  const float increment = range / SHADOW_QUALITY; 

  float noise = getNoise(texcoord).r;
  float theta = noise * radians(360.0);
  float cosTheta = cos(theta);
  float sinTheta = sin(theta);

  mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
  vec3 shadowAccum = vec3(0.0);
  int samples = 0;

  for(float x = -range; x <= range; x += increment){
    for (float y = -range; y <= range; y+= increment){
      vec2 offset = rotation * vec2(x, y) / shadowMapResolution;
      vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
      offsetShadowClipPos.z -= 0.001; //needed otherwise stuff will flip out
      offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
      vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      shadowAccum += getShadow(shadowScreenPos);
      samples++;
    }
  }

  return shadowAccum / float(samples);
}



void main() {
	float depth = texture(depthtex0, texcoord).r;

	
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 blocklight = lightmap.r * torchColor;
	vec3 skylight = lightmap.g * skyColor;
	vec3 ambient = ambientColor;


	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	
	vec3 shadow = getSoftShadow(shadowClipPos);
	vec3 sunlight = sunlightColor.rgb * clamp(dot(normal, worldLightVector),0.0,1.0) * shadow;	
	color = texture(colortex0, texcoord);
	if(depth == 1.0){
 	 return;
	}
	color.rgb *= blocklight + skylight + ambient + sunlight;
	
	

}