attribute vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 lightPosition;
uniform float groundZPosition;

void main()
{
    vec4 newPosition = modelViewMatrix * position;
    vec3 lightDirection = vec3(newPosition) - lightPosition;
    float scale = (groundZPosition - lightPosition.z) / lightDirection.z;
    lightDirection = lightDirection * scale;
    gl_Position = projectionMatrix * vec4((lightPosition + lightDirection), 1.0);
}