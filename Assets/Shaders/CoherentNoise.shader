// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/CoherentNoise"
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
			
			// src : https://www.ronja-tutorials.com/2018/09/02/white-noise.html
			float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
				//make value smaller to avoid artefacts
				float3 smallValue = sin(value);
				//get scalar value from 3d vector
				float random = dot(smallValue, dotDir);
				//make value more random by making it bigger and then taking teh factional part
				random = frac(sin(random) * 143758.5453);
				return random;
			}
			float3 rand3dTo3d(float3 value){
				return float3(
					rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
					rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
					rand3dTo1d(value, float3(73.156, 52.235, 09.151))
				);
			}
			
			float4 frag (v2f i) : SV_Target
			{
				return float4(rand3dTo3d(float3(i.uv.x,i.uv.y,_Time.x)).xyz,1);
			}
			ENDCG
		}
	}
}
