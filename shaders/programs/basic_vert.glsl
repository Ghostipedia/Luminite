#version 460

//attributes - i think these are literally just java vars. Bro idfk
in vec3 vaPosition; 
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;

//Uniforms, basically the CPU and GPU gigachad handshake emoji

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat3 normalMatrix;

//This spits stuff out to the fragment shader, which is what renders the pixels of a vertex?
//I think at least.
out vec2 textureCord0;
out vec3 foliageColor;
out vec2 lightMappingCords;
out vec3 geoNormal;

void main() {

	geoNormal = normalMatrix * vaNormal;
	
	textureCord0 = vaUV0;
	foliageColor = vaColor.rgb;
	lightMappingCords = vaUV2 * (1.0/256.0) + (1.0 / 32.0);

	//World Curvature stuff
	// vec3 worldSpacePos = cameraPosition + ( gbufferModelViewInverse * modelViewMatrix * vec4(vaPosition+chunkOffset,1)).xyz;
	// float distFromCamera = distance(worldSpacePos, cameraPosition);


	
	gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition+chunkOffset,1);

}