Shader "Hidden/CoherentNoiseInit"
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


			float _CNoiseK;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv; 
				return o;
			}
			float4 frag (v2f i) : SV_Target
			{
				return float4(_CNoiseK*W(float3(i.uv.x,i.uv.y,1)),1);
			}
			ENDCG
		}
	}
}
