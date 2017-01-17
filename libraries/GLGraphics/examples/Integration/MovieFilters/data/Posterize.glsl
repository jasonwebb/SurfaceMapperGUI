uniform sampler2D src_tex_unit0;
uniform vec2 src_tex_offset0;

void main(void)
{
    vec4 color = texture2D(src_tex_unit0, gl_TexCoord[0].st);
    float luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    
    if (luminance < 0.5) gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    else gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
