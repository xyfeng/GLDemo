varying highp float lightIntensity;

void main()
{
    lowp vec4 minWhite = vec4(0.6, 0.6, 0.6, 1.0);
	gl_FragColor = vec4((lightIntensity*0.4 + minWhite).rgb, 1.0);
}