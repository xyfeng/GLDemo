varying lowp vec4 fragmentColor;
uniform sampler2D texture;
varying mediump vec2 fragmentTextureCoordinates;
void main()
{
   gl_FragColor = fragmentColor * texture2D(texture, fragmentTextureCoordinates);
}
