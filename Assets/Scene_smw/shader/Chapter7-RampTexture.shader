// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter7-RampTexture"
{
    Properties
    {
		_Color("Color Tint",Color) = (1,1,1,1)
		_RampTex("Ramp Tex",2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
    }
    
	SubShader {
		Pass {
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#include "Lighting.cginc"

			float4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			float4 _Specular;
			float _Gloss;

			struct a2f {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;

			};


			v2f vert(a2f v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;
				return o;
			}

			float4 frag(v2f i):SV_TARGET {
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
				fixed3 diffuceColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;
				fixed diffuce = _LightColor0.rgb * diffuceColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(dot(worldNormal,halfDir) * 0.5 + 0.5,_Gloss);
				//fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuce + specular,1.0);
			}


			ENDCG
		}
	}

	FallBack "Specular"
}
