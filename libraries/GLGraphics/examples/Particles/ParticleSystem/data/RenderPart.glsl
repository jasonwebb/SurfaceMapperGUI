uniform sampler2D src_tex_unit1; // Brush texture

void main(void)
{
    vec4 color = texture2D(src_tex_unit1, gl_TexCoord[1].st);
    gl_FragColor = vec4(color.rgb, color.a);
}
