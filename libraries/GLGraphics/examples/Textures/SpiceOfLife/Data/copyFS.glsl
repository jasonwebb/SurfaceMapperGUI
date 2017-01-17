//
// copyFS.glsl
// 2010 Kevin Bjorke http://www.botzilla.com
// Made for JokerPaint
// Uses Processing & the GLGraphics library
//

uniform sampler2D src_tex_unit0; // previous paint result

void main(void) // fragment
{
	vec4 prev = texture2D(src_tex_unit0,gl_TexCoord[0].st);
    gl_FragColor = prev;
}
