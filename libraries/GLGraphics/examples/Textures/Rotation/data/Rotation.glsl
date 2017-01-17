uniform sampler2D src_tex_unit0;
uniform mat2 rot_matrix;
void main(void) {
    vec2 tex_coords = gl_TexCoord[0].st;
    vec2 center_point = vec2(0.5, 0.5);
    vec2 rot_tex_coords = center_point + rot_matrix * (tex_coords - center_point);
    gl_FragColor = texture2D(src_tex_unit0, rot_tex_coords);
}
