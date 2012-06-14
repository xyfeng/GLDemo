attribute vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 lightPosition;
uniform vec3 pagePosition;

varying float lightIntensity;

void main()
{
    gl_Position = projectionMatrix * (modelViewMatrix * position);
    
    vec4 newPosition = modelViewMatrix * vec4(pagePosition, 1.0);
    vec3 lightDirection = lightPosition - vec3(newPosition);
    vec4 normal = vec4(0.0, 0.0, 1.0, 0.0);
	vec4 newNormal = modelViewMatrix * normal;
	lightIntensity = max(0.0, dot(normalize(newNormal.xyz), normalize(lightDirection)));
}