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

     //get our base color...
     half4 col = tex2D(tex, uv);
     //total width/height of our blur "grid":
     const int mSize = 8;
     //this gives the number of times we'll iterate our blur on each side 
     //(up,down,left,right) of our uv coordinate;
     //NOTE that this needs to be a const or you'll get errors about unrolling for loops
     const int iter = (mSize - 1) / 2;
     //run loops to do the equivalent of what's written out line by line above
     //(number of blur iterations can be easily sized up and down this way)
     for (int i = -iter; i <= iter; ++i) {
         for (int j = -iter; j <= iter; ++j) {
             col += tex2D(tex, uv + px2uv(float2(i,j)*blurAmount));
            }
     }
     //return blurred color
     return col/mSize;
 }