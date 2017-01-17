#define PI 3.141592653589793

uniform vec2 clock_data;
uniform vec2 dest_tex_size;
uniform vec4 dest_color;

void main(void)
{
    vec4 newVertexPos;

    gl_TexCoord[0].xy = gl_MultiTexCoord0.xy;
	
	vec2 f = vec2(0.0, 0.0);
	vec2 d = gl_Vertex.xy - vec2(0.5 * dest_tex_size.x, 0.5 * dest_tex_size.y);
	float n = sqrt(d.x * d.x + d.y * d.y);
	
	float t = 0.001 * clock_data.y;
	if (0.0 < n)
	{
		f.x = cos(2.0 * PI * t) * d.x / n;
		f.y = sin(2.0 * PI * t) * d.y / n;
	}
	
    vec4 v = vec4(20.0 * f.x, 20.0 * f.y, 0.0, 0.0);
    newVertexPos = gl_Vertex + dest_color.a * v;
	
    gl_Position = gl_ModelViewProjectionMatrix * newVertexPos;
}
