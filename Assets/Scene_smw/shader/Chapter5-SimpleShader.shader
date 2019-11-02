// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter5-SimpleShader"
{
   
	SubShader{
		Pass {
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#include "UnityCG.cginc"
				#pragma enable_d3d11_debug_symbols

				struct a2v {
					float4 vertex:POSITION;//用模型空间的顶点坐标填充vertex变量
					float3 normal:NORMAL;//用模型空间中的法线方向来填充normal变量
					float texcoord:TEXCOORD0;//用模型的第一套纹理坐标填充texcoord变量
				};

				struct v2f {
					float4 pos:SV_POSITION;
					fixed3 color:COLOR0;
				};


				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);	 
					o.color = v.normal * 0.5 + 0.5;
					return o ;
				}

				fixed4 frag(v2f i):SV_Target {
					return fixed4(i.color,1.0);
				}
			ENDCG
		}
	}
	FallBack "VertexLit"
}
