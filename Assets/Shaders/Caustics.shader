Shader "Unlit/Caustics"
{
    Properties
    {
        _MainTex ("iChannel0", 2D) = "white" {}
        _SecondTex ("iChannel1", 2D) = "white" {}
        _ThirdTex ("iChannel2", 2D) = "white" {}
        _FourthTex ("iChannel3", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0.5, 0.5, 0.5, 0.5)
        [ToggleUI] _GammaCorrect ("Gamma Correction", Float) = 1
        _Resolution ("Resolution (Change if AA is bad)", Range(1, 1024)) = 1
    }
    SubShader
    {
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

            // Built-in properties
            sampler2D _MainTex;   float4 _MainTex_TexelSize;
            sampler2D _SecondTex; float4 _SecondTex_TexelSize;
            sampler2D _ThirdTex;  float4 _ThirdTex_TexelSize;
            sampler2D _FourthTex; float4 _FourthTex_TexelSize;
            float4 _Mouse;
            float _GammaCorrect;
            float _Resolution;

            // GLSL Compatability macros
            #define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))
            #define texelFetch(ch, uv, lod) tex2Dlod(ch, float4((uv).xy * ch##_TexelSize.xy + ch##_TexelSize.xy * 0.5, 0, lod))
            #define textureLod(ch, uv, lod) tex2Dlod(ch, float4(uv, 0, lod))
            #define iResolution float3(_Resolution, _Resolution, _Resolution)
            #define iFrame (floor(_Time.y / 60))
            #define iChannelTime float4(_Time.y, _Time.y, _Time.y, _Time.y)
            #define iDate float4(2020, 6, 18, 30)
            #define iSampleRate (44100)
            #define iChannelResolution float4x4(                      \
                _MainTex_TexelSize.z,   _MainTex_TexelSize.w,   0, 0, \
                _SecondTex_TexelSize.z, _SecondTex_TexelSize.w, 0, 0, \
                _ThirdTex_TexelSize.z,  _ThirdTex_TexelSize.w,  0, 0, \
                _FourthTex_TexelSize.z, _FourthTex_TexelSize.w, 0, 0)

            // Global access to uv data
            static v2f vertex_output;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =  v.uv;
                return o;
            }

#define TAU 6.2831855
#define MAX_ITER 5
            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float time = _Time.y*0.5+23.;
                float2 uv = fragCoord.xy/iResolution.xy;
#ifdef SHOW_TILING
                float2 p = glsl_mod(uv*TAU*2., TAU)-250.;
#else
                float2 p = glsl_mod(uv*TAU, TAU)-250.;
#endif
                float2 i = ((float2)p);
                float c = 1.;
                float inten = 0.005;
                for (int n = 0;n<MAX_ITER; n++)
                {
                    float t = time*(1.-3.5/float(n+1));
                    i = p+float2(cos(t-i.x)+sin(t+i.y), sin(t-i.y)+cos(t+i.x));
                    c += 1./length(float2(p.x/(sin(i.x+t)/inten), p.y/(cos(i.y+t)/inten)));
                }
                c /= float(MAX_ITER);
                c = 1.17-pow(c, 1.4);
                float3 colour = ((float3)pow(abs(c), 8.));
                colour = clamp(colour+float3(0., 0.35, 0.5), 0., 1.);
#ifdef SHOW_TILING
                float2 pixel = 2./iResolution.xy;
                uv *= 2.;
                float f = floor(glsl_mod(_Time.y*0.5, 2.));
                float2 first = step(pixel, uv)*f;
                uv = step(frac(uv), pixel);
                colour = lerp(colour, float3(1., 1., 0.), (uv.x+uv.y)*first.x*first.y);
#endif
                fragColor = float4(colour, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
