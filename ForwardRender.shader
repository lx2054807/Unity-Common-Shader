Shader "Unlit/Forward"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,4)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;
				fixed3 worldPos : TEXCOORD2;
				float3 vertexLight:TEXCOORD3;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
#ifdef LIGHTMAP_OFF
				float3 shLight = ShadeSH9(float4(v.normal, 1.0));
				o.vertexLight = shLight;
#ifdef VERTEXLIGHT_ON
				float3 vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
					unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
					unity_4LightAtten0, o.worldPos, o.worldNormal);
				o.vertexLight += vertexLight;
#endif
#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.worldNormal, i.worldLight));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-i.worldLight, i.worldNormal));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), 1 / _Gloss);
				return fixed4(diffuse + ambient + specular + i.vertexLight,1);
			}
			ENDCG
		}

		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;
				fixed3 worldPos : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.worldNormal, i.worldLight));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-i.worldLight, i.worldNormal));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), 1 / _Gloss);
				return fixed4(diffuse + ambient + specular,1);
			}
			ENDCG
		}
	}
}
