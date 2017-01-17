attribute vec3 tangent;
attribute vec3 binormal;

// inverse light radius ie.. 1.0/light radius;
uniform float u_invRad;

varying	vec3 g_lightVec;
varying	vec3 g_viewVec;

//vec4 lightEye = vec4(0,0,2,1);

void main()
{
	gl_Position = ftransform();
	gl_TexCoord[0] = gl_MultiTexCoord0;
	
	mat3 TBN_Matrix = gl_NormalMatrix * mat3(tangent, binormal, gl_Normal);
	vec4 mv_Vertex = gl_ModelViewMatrix * gl_Vertex;
	g_viewVec = vec3(-mv_Vertex) * TBN_Matrix ;	
	//vec4 lightEye = gl_LightSource[0].position;
	//lightEye = gl_ProjectionMatrixInverse * lightEye;
	vec4 lightEye = gl_ModelViewMatrix *  gl_LightSource[0].position;
	vec3 lightVec =0.02* (lightEye.xyz - mv_Vertex.xyz);				
	g_lightVec = lightVec * TBN_Matrix; 
}


