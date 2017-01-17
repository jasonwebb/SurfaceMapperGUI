uniform sampler2D src_tex_unit0; // Position texture

uniform float brush_size;          // Brush size

void main(void)
{
	vec2 pos;
	vec4 newVertexPos;

	gl_TexCoord[0].xy = gl_MultiTexCoord0.xy;
	
	// MAC HACK: for some reason, assigning gl_MultiTexCoord1.xy to 
	// gl_TexCoord[1].xy makes the application to crash when drawing the
	// textured quads:
	// gl_TexCoord[1].xy = gl_MultiTexCoord1.xy;
	// Since the texture coordinates for the second texture unit can be calculated
	// easily from the un-displaced vertex coordiates of the quad, this workaround
	// is good:
	gl_TexCoord[1].xy = gl_Vertex.xy + vec2(0.5, 0.5);

	pos = texture2D(src_tex_unit0, gl_TexCoord[0].xy).xy;
	
	newVertexPos = vec4(pos + brush_size * gl_Vertex.xy, 0.0, gl_Vertex.w);
	
	gl_Position = gl_ModelViewProjectionMatrix * newVertexPos;
}
