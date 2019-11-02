// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter9-Shadow"
{
    Properties {
		_Diffuse("Diffuse",Color) = (1,1,1,1)
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
			#include "AutoLight.cginc"

			#pragma multi_compile_fwdbase

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;				
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v) {
				v2f o; 
				o.pos = UnityObjectToClipPos(v.vertex); 
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_SHADOW(o);
				return o;
			}

			float4 frag(v2f i):SV_Target { 
				
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal,worldLightDir) * 0.5 + 0.5);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);

				fixed specular = _LightColor0.rgb * _Specular.rgb * pow(dot(worldNormal,halfDir) * 0.5 + 0.5,_Gloss);

				fixed shadow = SHADOW_ATTENUATION(i);
				fixed atten = 1.0;

				return fixed4(ambient + (diffuse + specular) * atten * shadow,1.0);

			}

			ENDCG
		}

		Pass {
			Tags {"LightMode"="ForwardAdd"}

			Blend One One 

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			#include "Lighting.cginc"

			#pragma multi_compile_fwdbase

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;				
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o; 
				o.pos = UnityObjectToClipPos(v.vertex); 
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}

			float4 frag(v2f i):SV_Target { 
				float3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal,worldLightDir) * 0.5 + 0.5);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed specular = _LightColor0.rgb * _Specular.rgb * pow(dot(worldNormal,halfDir) * 0.5 + 0.5,_Gloss);
				 
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined(POINT)
						float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1.0)).xyz;
						fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined(SPOT)
						float4 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1.0)).xyz;
						fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0,lightCoord.xy/lightCoord.w + 0.5).w * tex2D(_LightTextureB0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#else
						fixed atten = 1.0;
					#endif
				#endif

				return fixed4((diffuse + specular) * atten,1.0);

			}
			ENDCG
		}
	}

	FallBack "Specular"

}
