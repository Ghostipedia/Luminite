
const int shadowMapResolution = 2048;
const int noiseTextureResolution = 256;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;
#define SHADOW_QUALITY 3
#define SHADOW_SOFTNESS 2

vec3 distortShadowClipPos(vec3 shadowClipPos){
  float distortionFactor = length(shadowClipPos.xy); 
  distortionFactor += 0.1; 

  shadowClipPos.xy /= distortionFactor;
  shadowClipPos.z *= 0.5;
  return shadowClipPos;
}