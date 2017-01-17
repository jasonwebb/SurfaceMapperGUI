#define PI 3.141592653589793

#define KERNEL_SIZE 9

// Emboss kernel
// +2  0  0
//  0 -1  0
//  0  0 -1
float kernel[KERNEL_SIZE];

uniform sampler2D src_tex_unit0;
uniform vec2 src_tex_offset0;
uniform vec2 clock_data;
uniform vec4 dest_color;

vec2 offset[KERNEL_SIZE];

void main(void)
{
    int i = 0;
    vec4 sum = vec4(0.0);

    offset[0] = vec2(-src_tex_offset0.s, -src_tex_offset0.t);
    offset[1] = vec2(0.0, -src_tex_offset0.t);
    offset[2] = vec2(src_tex_offset0.s, -src_tex_offset0.t);

    offset[3] = vec2(-src_tex_offset0.s, 0.0);
    offset[4] = vec2(0.0, 0.0);
    offset[5] = vec2(src_tex_offset0.s, 0.0);

    offset[6] = vec2(-src_tex_offset0.s, src_tex_offset0.t);
    offset[7] = vec2(0.0, src_tex_offset0.t);
    offset[8] = vec2(src_tex_offset0.s, src_tex_offset0.t);

    float f = 2.0 + 0.5 * cos(2.0 * PI * (0.001 * clock_data.y));
    kernel[0] =   f;   kernel[1] =  0.0;   kernel[2] =  0.0;
    kernel[3] = 0.0;   kernel[4] = -1.0;   kernel[5] =  0.0;
    kernel[6] = 0.0;   kernel[7] =  0.0;   kernel[8] = -1.0;

    for (i = 0; i < 4; i++)
    {
        vec4 tmp = texture2D(src_tex_unit0, gl_TexCoord[0].st + offset[i]);
        sum += tmp * kernel[i];
    }

    for (i = 5; i < KERNEL_SIZE; i++)
    {
        vec4 tmp = texture2D(src_tex_unit0, gl_TexCoord[0].st + offset[i]);
        sum += tmp * kernel[i];
    }
	
	vec4 color0 = texture2D(src_tex_unit0, gl_TexCoord[0].st + offset[4]);
    sum += color0 * kernel[4];	
	
    vec4 color1 = vec4(dest_color.rgb * (sum.rgb + vec3(0.5, 0.5, 0.5)), 1.0);
    gl_FragColor = mix(color0, color1, dest_color.a);    
}
