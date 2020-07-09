Shader "Hidden/GaussianBlur"
{
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

			// TODO: using coherent noise global bc maintex issue
			sampler2D _CoherentNoise;
			
			float4 frag (v2f i) : SV_Target
			{
				// return 10*tex2D(_CoherentNoise,i.uv);
                return abs(blur(_CoherentNoise,i.uv,0.0005));
			}
			ENDCG
		}
	}
}
