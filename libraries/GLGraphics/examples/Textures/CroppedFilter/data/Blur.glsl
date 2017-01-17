uniform sampler2D tex;
uniform vec2 offset;
uniform vec4 tint;

void main(void) {
	float dx = offset.s;
	float dy = offset.t;
	vec2 st = gl_TexCoord[0].st;

	// Apply 3x3 gaussian filter
	vec4 color0	 = texture2D(tex, st);
	vec4 color   = 4.0 * color0;
	color		+= 2.0 * texture2D(tex, st + vec2(+dx, 0.0));
	color		+= 2.0 * texture2D(tex, st + vec2(-dx, 0.0));
	color		+= 2.0 * texture2D(tex, st + vec2(0.0, +dy));
	color		+= 2.0 * texture2D(tex, st + vec2(0.0, -dy));
	color		+= texture2D(tex, st + vec2(+dx, +dy));
	color		+= texture2D(tex, st + vec2(-dx, +dy));
	color		+= texture2D(tex, st + vec2(-dx, -dy));
	color		+= texture2D(tex, st + vec2(+dx, -dy));
	color       /= 16.0;
	
	// Blending the source color with the output color, using the alpha of
	// the tint as the mix factor.
	gl_FragColor = vec4(tint.rgb, 1.0) * mix(color0, color, tint.a);
}
