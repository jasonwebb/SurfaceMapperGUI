uniform sampler2D src_tex_unit0;
uniform vec2 src_tex_offset0;
uniform vec2 dest_tex_size;

uniform float pixel_size;

void main(void)
{
    float d = 1.0 / pixel_size;
    vec2 tex_coords = gl_TexCoord[0].st;

	int fx = int(tex_coords.s * dest_tex_size.x / pixel_size);
	int fy = int(tex_coords.t * dest_tex_size.y / pixel_size);
	
    float s = pixel_size * (float(fx) + d) / dest_tex_size.x;
    float t = pixel_size * (float(fy) + d) / dest_tex_size.y;
    
    gl_FragColor = texture2D(src_tex_unit0, vec2(s, t)).rgba;
}
