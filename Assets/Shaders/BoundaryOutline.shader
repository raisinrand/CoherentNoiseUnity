Shader "Hidden/BoundaryOutline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _Screen;
			sampler2D _MotionVectorsDepth;
			sampler2D _CoherentNoise;

			float4 frag (v2f i) : SV_Target
			{
                // TODO: SHOULD BE IN PIXEL SPACE, NOT UV SPACE
                float dist = 0.001f;

                float2 uv1 = float2(i.uv.x,1-i.uv.y);
                float2 uv2 = uv1 + float2(-dist,0);
                float2 uv3 = uv1 + float2(dist,0);
                float2 uv4 = uv1 + float2(0,dist);
                float2 uv5 = uv1 + float2(0,-dist);
            
                float d1 = tex2D(_MotionVectorsDepth,uv1);
                float d2 = tex2D(_MotionVectorsDepth,uv2);
                float d3 = tex2D(_MotionVectorsDepth,uv3);
                float d4 = tex2D(_MotionVectorsDepth,uv4);
                float d5 = tex2D(_MotionVectorsDepth,uv5);

                // pick nearest for depth
                float2 noiseUV = uv1;
                float d = min(d1,min(d2,min(d3,min(d4,d5))));
                if( d == d2) {
                    noiseUV = uv2;
                }
                if( d == d3) {
                    noiseUV = uv3;
                }
                if( d == d4) {
                    noiseUV = uv4;
                }
                if( d == d5) {
                    noiseUV = uv5;
                }

                float3 n1 = tex2D(_CoherentNoise,noiseUV);
                float2 delta = n1*dist*100;
                uv1 += delta;
                uv2 += delta;
                uv3 += delta;
                uv4 += delta;
                uv5 += delta;
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
     const int mSize = 11;
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
                float3 s1 = tex2D(_Screen,uv1);
                float3 s2 = tex2D(_Screen,uv2);
                float3 s3 = tex2D(_Screen,uv3);
                float3 s4 = tex2D(_Screen,uv4);
                float3 s5 = tex2D(_Screen,uv5);


                // return float4(1,0,0,0);
                // return float4(s1,1);
                // return float4(,1);

                float3 res = 0.6;
                if( length((s2+s3+s4+s5)*0.25 - s1) > 0) {
                    res = 0;
                }
				return float4(res,1);
			}
			ENDCG
		}
	}
}
