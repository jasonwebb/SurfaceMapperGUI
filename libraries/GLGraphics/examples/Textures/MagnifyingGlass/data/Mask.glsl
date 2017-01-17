uniform sampler2D src_tex_unit0;
uniform vec2 dest_tex_size;
uniform vec2 center;
uniform float radius;

void main(void) {
    vec2 tex_coord = gl_TexCoord[0].st;
    
    // Screen coordinates of texel.
    //vec2 xy = tex_coords * dest_tex_size.xy;
    
    if (distance(tex_coord, center) < radius)  
        // Texel is inside ellipse. Writing its color to screen.
        gl_FragColor =  texture2D(src_tex_unit0, tex_coord).rgba;
    else
        // Texel is outside ellipse. Outputting transparent pixel.
        gl_FragColor = vec4(0, 0, 0, 0);
    
} 
