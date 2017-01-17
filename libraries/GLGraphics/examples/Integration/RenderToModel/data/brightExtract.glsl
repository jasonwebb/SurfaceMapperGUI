uniform sampler2D src_tex_unit0;
uniform vec2 src_tex_offset0;

void main(void)
{
    vec3 color = texture2D(src_tex_unit0, gl_TexCoord[0].st).rgb;
    float z = 50.0 * dot(color, vec3(0.299, 0.587, 0.114));

    vec2 xy = 0.5 * (gl_TexCoord[0].st - vec2(0.5, 0.5)) / src_tex_offset0;

    gl_FragColor = vec4(xy, z, 1.0);
}
