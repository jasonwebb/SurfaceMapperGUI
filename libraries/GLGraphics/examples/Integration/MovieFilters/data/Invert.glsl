uniform sampler2D src_tex_unit0;
uniform vec2 src_tex_offset0;

uniform vec4 dest_color;

uniform vec2 mpos;
uniform float mdist;

void main(void)
{
    vec2 tex_coord = gl_TexCoord[0].st;
    vec4 color0 = texture2D(src_tex_unit0, tex_coord);

    float dist = distance(mpos, tex_coord / src_tex_offset0);
 
    float distFactor = 0.0;
    if (dist < mdist) distFactor = (mdist - dist) / mdist;
    
    vec3 inverted_color0 = 1.0 - color0.rgb;
    vec3 color1 = distFactor * inverted_color0 + (1.0 - distFactor) * color0.rgb;

    gl_FragColor =  mix(color0, vec4(dest_color.rgb * color1, 1.0), dest_color.a);
}
