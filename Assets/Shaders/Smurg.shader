Shader "Unlit/Smurg"
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

#define MOD int(glsl_mod(_Time.y/3., 4.))
#define hash(p) frac(sin(dot(p, float3(127.1, 311.7, 74.7)))*43758.547)
            float noise(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f*f*(3.-2.*f);
                float v = lerp(lerp(lerp(hash(i+float3(0, 0, 0)), hash(i+float3(1, 0, 0)), f.x), lerp(hash(i+float3(0, 1, 0)), hash(i+float3(1, 1, 0)), f.x), f.y), lerp(lerp(hash(i+float3(0, 0, 1)), hash(i+float3(1, 0, 1)), f.x), lerp(hash(i+float3(0, 1, 1)), hash(i+float3(1, 1, 1)), f.x), f.y), f.z);
                return MOD==0 ? v : MOD==1 ? 2.*v-1. : MOD==2 ? abs(2.*v-1.) : 1.-abs(2.*v-1.);
            }

#define rot(a) transpose(float2x2(cos(a), -sin(a), sin(a), cos(a)))
            float fbm(float3 p)
            {
                float v = 0., a = 0.5;
                float2x2 R = rot(0.37+_Time.y/10000.);
                for (int i = 0;i<9; i++, (p *= 2., a /= 2.))
                p.xy = mul(p.xy,R), (p.yz = mul(p.yz,R), v += a*noise(p));
                return v;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 O = 0;
                float2 U = vertex_output.uv * _Resolution;
                U /= iResolution.y;
                O = 0.5+0.55*cos(9.*fbm(float3(U, _Time.y/3.))+float4(0, 23, 21, 0));
                if (length(U*4.-float2(0.1, 0.2*float(MOD+1)))<0.1)
                    O--;
                    
                if (_GammaCorrect) O.rgb = pow(O.rgb, 2.2);
                return O;
            }
            ENDCG
        }
    }
}
