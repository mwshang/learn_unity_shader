// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter7-NormalMapWorldSpace"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2d) = "white" {}
		_BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				//float3 lightDir:TEXCOORD1;
				//float3 viewDir:TEXCOORD2; 
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
				//float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				//o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				//o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

				o.T2W0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.T2W1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.T2W2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
			}

			float4 frag(v2f i):SV_Target {

				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);

				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1 - saturate(dot(bump.xy,bump.xy)));
				bump = normalize(half3(dot(i.T2W0.xyz,bump),dot(i.T2W1.xyz,bump),dot(i.T2W2.xyz,bump)));

				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
				fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xy * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(bump,lightDir) * 0.5 + 0.5);
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow((dot(halfDir,bump) * 0.5 + 0.5),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}

			ENDCG
		}
		
	}

	FallBack "Specular"
}
