Shader "Hidden/CoherentNoise"
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
			#include "CoherentNoiseIncl.cginc"

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
			
			float _CNoiseAlpha;
			float _CNoiseK;
			float _CNoiseEpsilon;

			sampler2D _MainTex;
			sampler2D _MotionVectors;
			sampler2D _CoherentNoisePrev;
			sampler2D _MotionVectorsDepth;
			sampler2D _MotionVectorsDepthPrev;
			
			float4 frag (v2f i) : SV_Target
			{
				float3 w = whiteNoise(float3(i.uv.x,i.uv.y,_Time.x));
				float2 motion = tex2D(_MotionVectors, i.uv);
				float2 prevUV = i.uv-motion;
				float3 prev = tex2D(_CoherentNoisePrev, prevUV);
				// return float4(w,1);

				// NAIVE ADVECTION
				// return float4(prev,1);

				// COHERENT NOISE
				float depth = tex2D(_MotionVectorsDepth,i.uv);
				float depthPrev = tex2D(_MotionVectorsDepthPrev,i.uv);
				// return 1000*abs(depth-depthPrev);
				float3 res = 0;
				bool disoccluded = depthPrev - depth > _CNoiseEpsilon;
				if(disoccluded) 
					res = _CNoiseK*w;
				else {
					res = _CNoiseAlpha*prev + (1-_CNoiseAlpha)*w;
				} 
				return float4(res,1);
			}
			ENDCG
		}
	}
}
