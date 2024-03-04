Shader "Unlit/Dispersion"
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

            float3 spectral_colour(float l)
            {
                float r = 0., g = 0., b = 0.;
                if (l>=400.&&l<410.)
                {
                    float t = (l-400.)/(410.-400.);
                    r = +(0.33*t)-0.2*t*t;
                }
                else if (l>=410.&&l<475.)
                {
                    float t = (l-410.)/(475.-410.);
                    r = 0.14-0.13*t*t;
                }
                else if (l>=545.&&l<595.)
                {
                    float t = (l-545.)/(595.-545.);
                    r = +(1.98*t)-t*t;
                }
                else if (l>=595.&&l<650.)
                {
                    float t = (l-595.)/(650.-595.);
                    r = 0.98+0.06*t-0.4*t*t;
                }
                else if (l>=650.&&l<700.)
                {
                    float t = (l-650.)/(700.-650.);
                    r = 0.65-0.84*t+0.2*t*t;
                }
                
                if (l>=415.&&l<475.)
                {
                    float t = (l-415.)/(475.-415.);
                    g = +(0.8*t*t);
                }
                else if (l>=475.&&l<590.)
                {
                    float t = (l-475.)/(590.-475.);
                    g = 0.8+0.76*t-0.8*t*t;
                }
                else if (l>=585.&&l<639.)
                {
                    float t = (l-585.)/(639.-585.);
                    g = 0.82-0.8*t;
                }
                
                if (l>=400.&&l<475.)
                {
                    float t = (l-400.)/(475.-400.);
                    b = +(2.2*t)-1.5*t*t;
                }
                else if (l>=475.&&l<560.)
                {
                    float t = (l-475.)/(560.-475.);
                    b = 0.7-t+0.3*t*t;
                }
                
                return float3(r, g, b);
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 p = (2.*fragCoord.xy-iResolution.xy)/min(iResolution.x, iResolution.y);
                p *= 2.;
                for (int i = 0;i<8; i++)
                {
                    float2 newp = float2(p.y+cos(p.x+_Time.y)-sin(p.y*cos(_Time.y*0.2)), p.x-sin(p.y-_Time.y)-cos(p.x*sin(_Time.y*0.3)));
                    p = newp;
                }
                fragColor = float4(spectral_colour(p.y*50.+500.+sin(_Time.y*0.6)), 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
