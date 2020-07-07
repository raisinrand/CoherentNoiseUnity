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
				float3 noise = whiteNoise(float3(i.uv.x,i.uv.y,_Time.x));
				float2 motion = tex2D(_MotionVectors, i.uv);
				float3 prev = tex2D(_CoherentNoisePrev, i.uv - motion);
				// return float4(prev,1);
				
				// return float4(i.vertex.x/1920,i.vertex.y/1080,0,1);


				// return float4(prev,1);
				// return float4(vPos,0,1);

				return float4(lerp(noise,prev,_CNoiseAlpha),1);
				// return float4(prev,1);
			}
			ENDCG
		}
	}
}
