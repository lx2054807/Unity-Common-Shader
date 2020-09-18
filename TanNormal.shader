Shader "Unlit/TanNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
        _BumpScale("NormalScale", range(0,5)) = 1
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", range(0,2)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "BlingPhong_Frag"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            half _BumpScale;
            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 uv : TexCoord0;
                fixed3 lightDir : TexCoord1;
                fixed3 viewDir : TexCoord2;
            };

            v2f vert(appdata_tan v) // 数据结构使用appdata_tan
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                TANGENT_SPACE_ROTATION; //切线空间转换

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tanLightDir = normalize(i.lightDir); //片段处切线光源
                fixed3 tanViewDir = normalize(i.viewDir);   // 切线视线
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw); // 法线贴图采样
                fixed3 tanNormal = UnpackNormal(packedNormal);  // 解压到切线空间
                tanNormal.xy *= _BumpScale;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * max(0, dot(tanNormal, tanLightDir));
                fixed3 halfDir = normalize(tanViewDir + tanLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tanNormal, halfDir)), 1 / _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
