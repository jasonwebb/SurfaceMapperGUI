//
// advanceFS.glsl
// (C)2010 Kevin Bjorke http://www.botzilla.com
// Made for SpiceOfLife
// Uses Processing & the GLGraphics library
//

uniform vec2 StepSize; // deriv... UV size of pixel

uniform sampler2D src_tex_unit0; // previous values

int is_alive(float v) {
	return (v>0.1) ? 1 : 0;
}

void main(void) // fragment
{
	// not super-efficiant but clear, and too fast for most displays already!
	vec4 cell = texture2D(src_tex_unit0,gl_TexCoord[0].st);
	vec4 up = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(0,StepSize.y));
	vec4 dn = texture2D(src_tex_unit0,gl_TexCoord[0].st-vec2(0,StepSize.y));
	vec4 rt = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(StepSize.x,0));
	vec4 lf = texture2D(src_tex_unit0,gl_TexCoord[0].st-vec2(StepSize.x,0));
	vec4 ne = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(StepSize.x,-StepSize.y));
	vec4 se = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(StepSize.x,StepSize.y));
	vec4 nw = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(-StepSize.x,-StepSize.y));
	vec4 sw = texture2D(src_tex_unit0,gl_TexCoord[0].st+vec2(-StepSize.x,StepSize.y));
	int aup = is_alive(up.r);
	int adn = is_alive(dn.r);
	int alf = is_alive(lf.r);
	int art = is_alive(rt.r);
	int ane = is_alive(ne.r);
	int ase = is_alive(se.r);
	int anw = is_alive(nw.r);
	int asw = is_alive(sw.r);
	int acell = is_alive(cell.r);
	int neighbors = aup+adn+art+alf+ane+ase+anw+asw;
	vec4 result;
	result.g = 0.0;
	result.b = 0.0;
	result.a = 1.0;
	float new = 0.0;
	if (acell != 0) {
		result.r = 1.0;
		if (neighbors<2) { result.r = 0.0; }
		if (neighbors>3) { result.r = 0.0; }
	} else {
		result.r = 0.0;
		if (neighbors==3) { result.r = 1.0; new = 1.0; }
	}
	result.r = result.r*0.4+new*0.6;
	// vec4 halo = (cell*2.0+lf+rt+up+dn+se+sw+ne+nw)/10.0;
	vec4 halo = (lf+rt+up+dn+se+sw+ne+nw)/8.0;
	result.g = new+0.9*halo.g; //  + float(neighbors)/18.0;
	// result.b = (0.99*halo.y)+halo.x+result.g;
	// result.b = (0.965*cell.b)+0.1*(halo.g+0.25*halo.b)+new;
	result.b = min(1.0,(0.94*cell.b)+0.2*(halo.g+0.25*halo.b))-(1./255.);
    gl_FragColor = result;
}
