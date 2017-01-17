//
// BlendSoftLight.glsl
// 2010 Kevin Bjorke http://www.botzilla.com
// Uses Processing & the GLGraphics library
//

uniform sampler2D bottomSampler;
uniform sampler2D topSampler;
uniform float Opacity;


// utility function that assumes NON-pre-multiplied RGB...
vec4 final_mix(
	    vec4 NewColor,
	    vec4 BaseColor,
	    vec4 BlendColor
) {
    float A2 = BlendColor.a * Opacity;
    vec3 mixRGB = A2 * NewColor.rgb;
    mixRGB += ((1.0-A2) * BaseColor.rgb);
    return vec4(mixRGB,BaseColor.a+BlendColor.a);
}

void main(void) // fragment
{
	vec4 botColor = texture2D(bottomSampler,gl_TexCoord[0].st);
	vec4 topColor = texture2D(topSampler,gl_TexCoord[0].st);
	vec4 comp = final_mix(2.0*botColor*topColor+botColor*botColor-2.0*botColor*botColor*topColor,
					botColor,topColor);
    gl_FragColor = comp;
}
