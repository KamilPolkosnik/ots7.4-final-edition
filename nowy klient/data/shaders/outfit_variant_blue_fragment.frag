varying vec2 v_TexCoord;
uniform sampler2D u_Tex0;

void main()
{
    vec4 color = texture2D(u_Tex0, v_TexCoord);
    if (color.a < 0.01) discard;
    color.rgb = color.rgb * vec3(0.5, 0.6, 1.3);
    gl_FragColor = color;
}
