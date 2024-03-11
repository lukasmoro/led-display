Shader "Unlit/Gyroid"
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

            float3 pal(float t)
            {
                float3 b = ((float3)0.45);
                float3 c = ((float3)0.35);
                return b+c*cos(6.28318*(t*((float3)1)+float3(0.7, 0.39, 0.2)));
            }

            float gyroid(float3 p, float scale)
            {
                p *= scale;
                float bias = lerp(1.1, 2.65, sin(_Time.y*0.4+p.x/3.+p.z/4.)*0.5+0.5);
                float g = abs(dot(sin(p*1.01), cos(p.zxy*1.61))-bias)/(scale*1.5)-0.1;
                return g;
            }

            float scene(float3 p)
            {
                float g1 = 0.7*gyroid(p, 4.);
                return g1;
            }

            float3 norm(float3 p)
            {
                float3x3 k = transpose(float3x3(p, p, p))-((float3x3)0.01);
                return normalize(scene(p)-float3(scene(k[0]), scene(k[1]), scene(k[2])));
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;
                float3 init = float3(_Time.y*0.25, 1.5, 0.3);
                float3 cam = normalize(float3(1., uv));
                float3 p = init;
                bool hit = false;
                for (int i = 0;i<100&&!hit; i++)
                {
                    if (distance(p, init)>8.)
                        break;
                        
                    float d = scene(p);
                    if (d*d<0.00001)
                        hit = true;
                        
                    p += cam*d;
                }
                float3 n = norm(p);
                float ao = 1.-smoothstep(-0.3, 0.75, scene(p+n*0.4))*smoothstep(-3., 3., scene(p+n*1.));
                float fres = -max(0., pow(0.8-abs(dot(cam, n)), 3.));
                float3 vign = smoothstep(0., 1., ((float3)1.-(length(uv*0.8)-0.1)));
                float3 col = pal(0.1-_Time.y*0.01+p.x*0.28+p.y*0.2+p.z*0.2);
                col = (((float3)fres)+col)*ao;
                col = lerp(col, ((float3)0.), !hit ? 1. : smoothstep(0., 8., distance(p, init)));
                col = lerp(((float3)0), col, vign+0.1);
                col = smoothstep(0., 1.+0.3*sin(_Time.y+p.x*4.+p.z*4.), col);
                fragColor.xyz = col;
                fragColor.xyz = sqrt(fragColor.xyz);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
