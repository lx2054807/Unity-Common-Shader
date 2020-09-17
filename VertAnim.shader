﻿Shader "Unlit/VertAnim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Range("Range", range(-2,2)) = 1
        _Frequency("Frequency", range(0,60)) = 20
        _Speed("Speed", range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Range;
            half _Frequency;
            half _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float timer = _Time.y * _Speed;
                float wave = _Range * sin(timer + v.vertex.x * _Frequency);
                v.vertex.y += wave;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}