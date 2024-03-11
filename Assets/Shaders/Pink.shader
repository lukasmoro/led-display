Shader "Unlit/Pink"
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

            float colormap_red(float x)
            {
                if (x<0.)
                {
                    return 54./255.;
                }
                else if (x<20049./82979.)
                {
                    return (829.79*x+54.51)/255.;
                }
                else 
                {
                    return 1.;
                }
            }

            float colormap_green(float x)
            {
                if (x<20049./82979.)
                {
                    return 0.;
                }
                else if (x<327013./810990.)
                {
                    return (8546482700000./10875674000.*x-2064961400000./10875674000.)/255.;
                }
                else if (x<=1.)
                {
                    return (103806720./483977.*x+19607416./483977.)/255.;
                }
                else 
                {
                    return 1.;
                }
            }

            float colormap_blue(float x)
            {
                if (x<0.)
                {
                    return 54./255.;
                }
                else if (x<7249./82979.)
                {
                    return (829.79*x+54.51)/255.;
                }
                else if (x<20049./82979.)
                {
                    return 127./255.;
                }
                else if (x<327013./810990.)
                {
                    return (792.0225*x-64.36479)/255.;
                }
                else 
                {
                    return 1.;
                }
            }

            float4 colormap(float x)
            {
                return float4(colormap_red(x), colormap_green(x), colormap_blue(x), 1.);
            }

            float rand(float2 n)
            {
                return frac(sin(dot(n, float2(12.9898, 4.1414)))*43758.547);
            }

            float noise(float2 p)
            {
                float2 ip = floor(p);
                float2 u = frac(p);
                u = u*u*(3.-2.*u);
                float res = lerp(lerp(rand(ip), rand(ip+float2(1., 0.)), u.x), lerp(rand(ip+float2(0., 1.)), rand(ip+float2(1., 1.)), u.x), u.y);
                return res*res;
            }

            static const float2x2 mtx = transpose(float2x2(0.8, 0.6, -0.6, 0.8));
            float fbm(float2 p)
            {
                float f = 0.;
                f += 0.5*noise(p+_Time.y);
                p = mul(mtx,p)*2.02;
                f += 0.03125*noise(p);
                p = mul(mtx,p)*2.01;
                f += 0.25*noise(p);
                p = mul(mtx,p)*2.03;
                f += 0.125*noise(p);
                p = mul(mtx,p)*2.01;
                f += 0.0625*noise(p);
                p = mul(mtx,p)*2.04;
                f += 0.015625*noise(p+sin(_Time.y));
                return f/0.96875;
            }

            float pattern(in float2 p)
            {
                return fbm(p+fbm(p+fbm(p)));
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = fragCoord/iResolution.x;
                float shade = pattern(uv);
                fragColor = float4(colormap(shade).rgb, shade);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
