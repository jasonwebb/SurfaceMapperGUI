//
// BlendLuminance.glsl
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
    vec4 lumCoeff = vec4(0.25,0.65,0.1,0.0);
	float tv = dot(topColor,lumCoeff);
	vec4 newColor = tv*normalize(botColor);
	vec4 comp = final_mix(newColor,botColor,topColor);
    gl_FragColor = comp;
}
