attribute vec4 position;

uniform mat4 matrix;
uniform vec3 lightDirection;

varying float lightIntensity;

void main()
{
    gl_Position = matrix * position;
    
    vec4 normal = vec4(0.0, 0.0, 1.0, 0.0);
	vec4 newNormal = matrix * normal;
	lightIntensity = max(0.0, dot(normalize(newNormal.xyz), normalize(lightDirection)));
}