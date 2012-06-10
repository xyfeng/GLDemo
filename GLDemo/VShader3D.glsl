attribute vec4 position;
attribute vec4 color; 
uniform mat4 matrix;
varying vec4 fragmentColor; 
void main()
{
    gl_Position = matrix * position;
    fragmentColor = color; 
}