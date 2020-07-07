Shader "Hidden/NoiseDiff"
{
	Properties
	{
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


			sampler2D _CoherentNoise;
			sampler2D _CoherentNoisePrev;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv; 
				return o;
			}
			float4 frag (v2f i) : SV_Target
			{
				// return float4(1,1,0,1);
				return 5*abs((tex2D(_CoherentNoise,i.uv) - tex2D(_CoherentNoisePrev,i.uv)));
			}
			ENDCG
		}
	}
}
