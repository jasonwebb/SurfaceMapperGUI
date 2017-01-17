uniform sampler2D src_tex_unit0;
uniform sampler2D src_tex_unit1;
uniform int band_size;
uniform vec2 dest_tex_size;
void main(void) {
    vec2 tex_coords = gl_TexCoord[0].st;

    int n = int(tex_coords.t * dest_tex_size.y);
    int r = n / band_size;
    int q1 = int(r / 2);
    float q2 = float(r) / 2.0;
    float d = float(q1) - q2;
    if (d == 0.0) {
        gl_FragColor = texture2D(src_tex_unit0, tex_coords.st).rgba;
    } else {
        gl_FragColor = texture2D(src_tex_unit1, tex_coords.st).rgba;
    }
} 
