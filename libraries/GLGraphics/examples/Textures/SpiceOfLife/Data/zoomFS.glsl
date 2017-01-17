//
// zoomFS.glsl
// 2010 Kevin Bjorke http://www.botzilla.com
// Made for JokerPaint
// Uses Processing & the GLGraphics library
//

uniform vec2 Center;
uniform float Scale;

uniform sampler2D src_tex_unit0; // previous paint result

void main(void) // fragment
{
	vec2 UVC = vec2(0.5,0.5);
	vec2 UV = Center + (gl_TexCoord[0].st-UVC)/Scale;
	vec4 prev = texture2D(src_tex_unit0,UV);
    gl_FragColor = prev;
}
