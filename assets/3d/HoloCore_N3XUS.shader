// HoloCore_N3XUS Unity Shader Graph Documentation
// Target: URP/HDRP Lit Graph, Transparent Surface, Emission Enabled
// 
// This shader creates a holographic effect with:
// - Gradient coloring (cyan to violet)
// - Pulsing emission
// - Noise flicker
// - Rim/Fresnel glow
//
// Properties:
// _BaseColorA (Color) — default #00F0FF (neon cyan)
// _BaseColorB (Color) — default #7A00FF (violet plasma)
// _EmissionStrength (Float) — default 1.0, range [0, 5]
// _PulseSpeed (Float) — default 0.8
// _NoiseScale (Float) — default 150.0
// _NoiseIntensity (Float) — default 0.1
// _RimPower (Float) — default 1.5
// _RimIntensity (Float) — default 0.25
// _Alpha (Float) — default 0.9
//
// Node Layout Instructions:
//
// 1. UV & Gradient
//    - UV → Split (X, Y)
//    - Lerp: A=_BaseColorA, B=_BaseColorB, T=UV.X → Output: GradientColor
//
// 2. Time & Pulse
//    - Time → Multiply by _PulseSpeed
//    - Sine of above
//    - Remap [-1,1] to [0.5,1.5]: Sine * 0.5 + 1.0
//    - Multiply by _EmissionStrength → Output: PulseFactor
//
// 3. Noise Flicker
//    - UV → Multiply by _NoiseScale
//    - Simple Noise or Gradient Noise
//    - Noise * _NoiseIntensity
//    - Add 1.0 → Output: NoiseFactor
//
// 4. Rim (Fresnel)
//    - Fresnel Effect: Power=_RimPower
//    - Multiply by _RimIntensity
//    - Multiply by cyan color (#00F0FF) → Output: RimColor
//
// 5. Final Emission
//    - GradientColor * PulseFactor
//    - Result * NoiseFactor
//    - Add RimColor → Connect to Emission output
//
// 6. Master Outputs
//    - Base Color: GradientColor
//    - Emission Color: Final Emission (from step 5)
//    - Alpha: _Alpha
//    - Surface: Set to Transparent
//    - Enable Emission in Graph Inspector

Shader "N3XUS/HoloCore_N3XUS"
{
    Properties
    {
        _BaseColorA ("Base Color A", Color) = (0, 0.94, 1, 1)
        _BaseColorB ("Base Color B", Color) = (0.48, 0, 1, 1)
        _EmissionStrength ("Emission Strength", Range(0, 5)) = 1.0
        _PulseSpeed ("Pulse Speed", Float) = 0.8
        _NoiseScale ("Noise Scale", Float) = 150.0
        _NoiseIntensity ("Noise Intensity", Float) = 0.1
        _RimPower ("Rim Power", Float) = 1.5
        _RimIntensity ("Rim Intensity", Float) = 0.25
        _Alpha ("Alpha", Range(0, 1)) = 0.9
    }
    
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float4 _BaseColorA;
            float4 _BaseColorB;
            float _EmissionStrength;
            float _PulseSpeed;
            float _NoiseScale;
            float _NoiseIntensity;
            float _RimPower;
            float _RimIntensity;
            float _Alpha;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };
            
            float hash(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                // Gradient Color
                float3 gradientColor = lerp(_BaseColorA.rgb, _BaseColorB.rgb, i.uv.x);
                
                // Pulse
                float pulse = 0.5 + 0.5 * sin(_Time.y * _PulseSpeed);
                pulse = pulse * 0.5 + 1.0;
                float pulseFactor = pulse * _EmissionStrength;
                
                // Noise Flicker
                float n = hash(i.uv * _NoiseScale + _Time.y * 5.0);
                float noiseFactor = 1.0 + n * _NoiseIntensity;
                
                // Rim (Fresnel)
                float fresnel = 1.0 - saturate(dot(i.worldNormal, i.viewDir));
                fresnel = pow(fresnel, _RimPower);
                float3 rimColor = fresnel * _RimIntensity * float3(0, 0.94, 1);
                
                // Final Emission
                float3 color = gradientColor;
                color *= pulseFactor;
                color *= noiseFactor;
                color += rimColor;
                
                return float4(color, _Alpha);
            }
            ENDCG
        }
    }
}
