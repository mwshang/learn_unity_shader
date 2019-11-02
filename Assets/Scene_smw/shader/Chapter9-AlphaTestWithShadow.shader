// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter9-AlphaTestWithShadow"
{
    Properties {
		_Color ("Main Tint",Color) = (1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_Cutoff ("Alpha Cutoff",Range(0,1)) = 0.5
	}

	SubShader {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

		Pass {
			Tags {"LightMode"="ForwardBase"}

			// 这里关闭剔除功能,这样背面就可以渲染出来了
			//Cull Off

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				TRANSFER_SHADOW(o)

				return o;
			}

			float4 frag(v2f i): SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);

				clip(texColor.a - _Cutoff);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(worldNormal,worldLightDir) * 0.5 + 0.5);

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				return fixed4(ambient + diffuse * atten,1.0);
			}
			ENDCG
		}
	}

	FallBack "Transparent/Cutout/VertexLit"
}
