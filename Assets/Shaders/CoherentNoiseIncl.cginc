float3 hash33(float3 p3)
{
	p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return frac((p3.xxy + p3.yxx)*p3.zyx);

}

float3 whiteNoise(float3 seed) {
    return 2*(hash33(seed*9999)-0.5);
}

 float3 blurNoise(float3 seed,float blurAmount) {

    float Pi = 6.28318530718; // Pi*2
    
    float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
    float Quality = 6.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
   
    float2 Radius = blurAmount/_ScreenParams.xy;
    // Pixel colour
    float3 Color = whiteNoise(seed);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
            float3 x = seed;
            x.xy += float2(cos(d),sin(d))*Radius*i;
			Color += whiteNoise(x);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions - 15.0;
    return Color;


 }

float3 W(float3 seed) {

    return whiteNoise(seed);
}