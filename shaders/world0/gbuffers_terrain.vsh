#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;


uniform mat4 gbufferModelViewInverse;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
out vec4 lightmapData;
out vec4 encodedNormal;

void main() {
    
    
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    lmcoord = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);
    normal = gl_NormalMatrix * gl_Normal;
    normal = mat3(gbufferModelViewInverse) * normal;
    lightmapData = vec4(lmcoord, 0.0, 1.0);
    encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	glcolor = gl_Color;
    
}