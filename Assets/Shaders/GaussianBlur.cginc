 //normpdf function gives us a Guassian distribution for each blur iteration; 
 //this is equivalent of multiplying by hard #s 0.16,0.15,0.12,0.09, etc. in code above
 float normpdf(float x, float sigma)
 {
     return 0.39894*exp(-0.5*x*x / (sigma*sigma)) / sigma;
 }


float4 s2u(float4 s) {
    return (s + 1)*0.5;
}

float4 u2s(float4 u) {
    return 2*(u-0.5);
}

float2 uv2px(float2 uv) {
    return uv*_ScreenParams.xy;
}
float2 px2uv(float2 px) {
    return float2(px.x/_ScreenParams.x,px.y/_ScreenParams.y);
}

 //this is the blur function... pass in standard col derived from tex2d(_MainTex,i.uv)
 float4 blur(sampler2D tex, float2 uv,float blurAmount) {

    float Pi = 6.28318530718; // Pi*2
    
    float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
    float Quality = 6.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
   
    float2 Radius = blurAmount/_ScreenParams.xy;
    // Pixel colour
    float4 Color = tex2D(tex, uv);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
			Color += tex2D( tex, uv+float2(cos(d),sin(d))*Radius*i);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions - 15.0;
    return Color;


 }