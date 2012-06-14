varying highp float lightIntensity;

void main()
{
    lowp vec4 minWhite = vec4(0.7, 0.7, 0.7, 1.0);
	gl_FragColor = vec4((lightIntensity*0.3+ minWhite).rgb, 1.0);
}