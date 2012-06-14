precision lowp float;
uniform int direction;
uniform float blurSize;
uniform sampler2D texture;
varying lowp vec2 fragmentTextureCoordinates;

const float sigma = 3.0;
const float pi = 3.14159265;

const float numBlurPixelsPerSide = 2.0;

void main()
{
    vec4 fragmentColor = texture2D(texture, fragmentTextureCoordinates);
    vec4 fragmentColorOnEdge1;
    vec4 fragmentColorOnEdge2;
        
    vec2  blurMultiplyVec;
    if (direction == 0)
    {
        blurMultiplyVec = blurSize * vec2(1.0, 0.0);
    }
    else {
        blurMultiplyVec = blurSize * vec2(0.0, 1.0);
    }
    fragmentColorOnEdge1 = texture2D(texture, fragmentTextureCoordinates - numBlurPixelsPerSide * blurMultiplyVec);
    fragmentColorOnEdge2 = texture2D(texture, fragmentTextureCoordinates + numBlurPixelsPerSide * blurMultiplyVec);
    
    if (fragmentColor.a > 0.0 || fragmentColorOnEdge1.a > 0.0 || fragmentColorOnEdge2.a > 0.0) 
    {
        vec3 incrementalGaussian;
        incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
        incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
        incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;

        vec2  blurMultiplyVec;
        if (direction == 0)
        {
            blurMultiplyVec = blurSize * vec2(1.0, 0.0);
        }
        else {
            blurMultiplyVec = blurSize * vec2(0.0, 1.0);
        }
        vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
        float coefficientSum = 0.0;

        avgValue += fragmentColor * incrementalGaussian.x * 0.5;
        coefficientSum += incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
        for (float i = 1.0; i <= numBlurPixelsPerSide; i++) { 
            avgValue += texture2D(texture, fragmentTextureCoordinates - i * blurMultiplyVec) * incrementalGaussian.x;         
            avgValue += texture2D(texture, fragmentTextureCoordinates + i * blurMultiplyVec) * incrementalGaussian.x;         
            coefficientSum += 2.0 * incrementalGaussian.x;
            incrementalGaussian.xy *= incrementalGaussian.yz;
        }
        gl_FragColor = avgValue / coefficientSum;
    } 
    else {
        gl_FragColor = vec4(0.0);
    }
}