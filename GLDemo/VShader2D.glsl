attribute vec4 position;
attribute vec4 color; 
attribute vec2 textureCoordinates;
uniform mat4 matrix;
varying vec2 fragmentTextureCoordinates; 
varying vec4 fragmentColor; 
void main()
{
    gl_Position = matrix * position;
    fragmentColor = color; 
    fragmentTextureCoordinates = textureCoordinates;
}