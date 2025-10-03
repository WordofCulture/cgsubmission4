Shader "Unlit/Lambert"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"
               "Queue"="Geometry"
               "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

           
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
               
                float3 N = SafeNormalize(IN.normalWS);

               // Getting the main directional light
                Light mainLight = GetMainLight();       
                float  NdotL    = saturate(dot(N, mainLight.direction));  //dot product of normal & main light direction
                half3  diffuse  = _Color.rgb * mainLight.color.rgb * NdotL;  //diffuse via multiplying color by light color by dot product.

                // Ambient from spherical harmonics (scene ambient)
                half3 ambient = SampleSH(N) * _Color.rgb;

                return half4(diffuse + ambient, 1);
            }
            ENDHLSL
        }
    }

    FallBack Off
}

                // unlit to lit
                //use of cosine to determine light brightness 1 = max, 0.5 = half, 0 = none
                //This is the built-in render-pipeline Lambert shader
                //Dark areas are black/unaffected by surrounding/ambient light = dark areas stay black all round.