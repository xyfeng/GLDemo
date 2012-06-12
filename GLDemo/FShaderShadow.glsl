precision highp float;

float Gaussian (float x, float deviation)
{
    return (1.0 / sqrt(2.0 * 3.141592 * deviation)) * exp(-((x * x) / (2.0 * deviation)));  
}

void main()
{
    int BlurAmount = 6;
    float halfBlur = float(BlurAmount) * 0.5;
    float deviation = halfBlur * 0.5;
    highp vec4 colour = vec4(0.1, 0.1, 0.1, 0.8);
    
    for (int i = 0; i < 10; ++i)
    {
        if ( i >= BlurAmount )
            break;
        
        float offset = float(i) - halfBlur;
        colour += Gaussian(offset, deviation);
    }
    
    colour = colour / float(BlurAmount);
    
    gl_FragColor = colour;
}