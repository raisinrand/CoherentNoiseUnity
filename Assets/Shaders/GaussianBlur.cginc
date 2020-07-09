 //normpdf function gives us a Guassian distribution for each blur iteration; 
 //this is equivalent of multiplying by hard #s 0.16,0.15,0.12,0.09, etc. in code above
 float normpdf(float x, float sigma)
 {
     return 0.39894*exp(-0.5*x*x / (sigma*sigma)) / sigma;
 }
 //this is the blur function... pass in standard col derived from tex2d(_MainTex,i.uv)
 half4 blur(sampler2D tex, float2 uv,float blurAmount) {
     //get our base color...
     half4 col = tex2D(tex, uv);
     //total width/height of our blur "grid":
     const int mSize = 10;
     //this gives the number of times we'll iterate our blur on each side 
     //(up,down,left,right) of our uv coordinate;
     //NOTE that this needs to be a const or you'll get errors about unrolling for loops
     const int iter = (mSize - 1) / 2;
     //run loops to do the equivalent of what's written out line by line above
     //(number of blur iterations can be easily sized up and down this way)
     for (int i = -iter; i <= iter; ++i) {
         for (int j = -iter; j <= iter; ++j) {
             col += tex2D(tex, float2(uv.x + i * blurAmount, uv.y + j * blurAmount)) * normpdf(float(i), 7);
            }
     }
     //return blurred color
     return col/mSize;
 }