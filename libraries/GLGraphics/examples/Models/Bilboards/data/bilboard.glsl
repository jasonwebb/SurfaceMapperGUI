// GLSL bilboarding code adapted from 
// http://www.opengl.org/discussion_boards/ubbthreads.php?ubb=showflat&topic=51511
attribute vec3 objCorn;

void main() {
  vec4 pos = gl_ModelViewMatrix * gl_Vertex;
  pos.xy += objCorn.xy; 

  gl_Position = gl_ProjectionMatrix * pos;
  gl_TexCoord[0] = gl_MultiTexCoord0;
  gl_FrontColor = gl_Color;
}
