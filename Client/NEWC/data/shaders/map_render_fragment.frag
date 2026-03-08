varying vec2 v_TexCoord;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;

vec3 saturateColor(vec3 color, float amount)
{
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, amount);
}

void main()
{
    vec4 color = texture2D(u_Tex0, v_TexCoord) * u_Color;
    if (color.a < 0.01)
        discard;

    color.rgb = saturateColor(color.rgb, 1.18);
    color.rgb = ((color.rgb - 0.5) * 1.10) + 0.5;
    color.rgb *= vec3(1.05, 1.02, 0.96);
    color.rgb = min(color.rgb * 1.04, vec3(1.0));

    float dist = distance(v_TexCoord, vec2(0.5, 0.5));
    float vignette = 1.0 - smoothstep(0.30, 0.85, dist);
    color.rgb *= mix(0.92, 1.06, vignette);

    gl_FragColor = vec4(color.rgb, color.a);
}
