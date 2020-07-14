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

 //this is the blur function... pass in standard col derived from tex2d(_MainTex,i.uv)
 float4 blur(sampler2D tex, float2 uv,float blurAmount) {
     //get our base color...
     float4 col = 0;
     //total width/height of our blur "grid":
    //  const int mSize = ;
     //this gives the number of times we'll iterate our blur on each side 
     //(up,down,left,right) of our uv coordinate;f
     //NOTE that this needs to be a const or you'll get errors about unrolling for loops
    //  const int iter = (mSize - 1) / 2;
     const int iter = 9;
     const int n = 1.0 + (iter*2);
     const float cnt = n*n;
     //run loops to do the equivalent of what's written out line by line above
     //(number of blur iterations can be easily sized up and down this way)
     for (int i = -iter; i <= iter; ++i) {
         for (int j = -iter; j <= iter; ++j) {
             col += tex2D(tex, float2(uv.x + i * blurAmount, uv.y + j * blurAmount));
            //  col += s2u(tex2D(tex, float2(uv.x + i * blurAmount, uv.y + j * blurAmount)));
            }
     }
     //return blurred color
     return col*(1.0/cnt);
    //  return u2s(col*(1/cnt));
 }