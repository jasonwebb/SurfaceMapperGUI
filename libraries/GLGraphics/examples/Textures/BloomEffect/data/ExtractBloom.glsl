uniform sampler2D tex;

// Brightness threshold.
uniform float bright_threshold;

void main()
{
    vec2 st = gl_TexCoord[0].st;
    vec4 color = texture2D(tex, st);
	
    // Calculate luminance
    float lum = dot(vec4(0.30, 0.59, 0.11, 0.0), color);
	
    // Extract very bright areas of the map.
    if (lum > bright_threshold)
        gl_FragColor = color;
    else
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
