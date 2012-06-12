attribute vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 lightPosition;

varying float lightIntensity;

void main()
{
    vec4 newPosition = modelViewMatrix * position;
    gl_Position = projectionMatrix * newPosition;
    
    vec3 lightDirection = lightPosition - vec3(newPosition);
    vec4 normal = vec4(0.0, 0.0, 1.0, 0.0);
	vec4 newNormal = modelViewMatrix * normal;
	lightIntensity = max(0.0, dot(normalize(newNormal.xyz), normalize(lightDirection)));
}