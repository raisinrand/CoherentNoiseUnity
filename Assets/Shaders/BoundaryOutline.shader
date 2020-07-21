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
			#include "GaussianBlur.cginc"

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
			
			sampler2D _EffectTemp;
			sampler2D _MotionVectorsDepth;
			sampler2D _CoherentNoiseSquash;
            float _CNoiseK;

            float2 flipUV(float2 uv) {
                return float2(uv.x,1-uv.y);
            }
			float4 frag (v2f i) : SV_Target
			{
                // TODO: SHOULD BE IN PIXEL SPACE, NOT UV SPACE
                float dist = 5.0;
                float noiseDist = 1;

                float2 uv1 = i.uv;
                float2 uv2 = uv1 + px2uv(float2(-dist,0));
                float2 uv3 = uv1 + px2uv(float2(dist,0));
                float2 uv4 = uv1 + px2uv(float2(0,dist));
                float2 uv5 = uv1 + px2uv(float2(0,-dist));
            
                float d1 = tex2D(_MotionVectorsDepth,uv1);
                float d2 = tex2D(_MotionVectorsDepth,uv2);
                float d3 = tex2D(_MotionVectorsDepth,uv3);
                float d4 = tex2D(_MotionVectorsDepth,uv4);
                float d5 = tex2D(_MotionVectorsDepth,uv5);

                // pick nearest for depth
                float2 noiseUV = uv1;
                float d = max(d1,max(d2,max(d3,max(d4,d5))));
                // return d;
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

                // return 10*tex2D(_CoherentNoiseSquash,noiseUV);
                float3 n = blur(_CoherentNoiseSquash,noiseUV,10);
                // // return float4(abs(50*n),1);
                // return 20*d;
                // return float4(10*n,1);
                float2 delta = n*noiseDist;
                uv1 += delta;
                uv2 += delta;
                uv3 += delta;
                uv4 += delta;
                uv5 += delta;

                // TOOD: have to flip these uvs because image is flipped during blit to _EffectTemp
                float3 s1 = tex2D(_EffectTemp,flipUV(uv1));
                float3 s2 = tex2D(_EffectTemp,flipUV(uv2));
                float3 s3 = tex2D(_EffectTemp,flipUV(uv3));
                float3 s4 = tex2D(_EffectTemp,flipUV(uv4));
                float3 s5 = tex2D(_EffectTemp,flipUV(uv5));

                float3 res = s1;
                if( length((s2+s3+s4+s5)*0.25 - s1) > 0) {
                    res = 0;
                }
				return float4(res,1);

                // return float4(lerp(s1,100*n,0.5),1);

                // return float4(s1,1);
                // return float4(max(s1,max(s2,max(s3,max(s4,s5)))),1);
			}
			ENDCG
		}
	}
}
