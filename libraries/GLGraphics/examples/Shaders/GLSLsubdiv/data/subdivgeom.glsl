#version 120
#extension GL_EXT_geometry_shader4: enable

uniform float FpLevel;
uniform float Radius;
varying float LightIntensity;
vec3 V0, V01, V02;

void ProduceVertex( float s, float t ) {
  const vec3 lightPos = vec3( 0., 10., 0. );
  vec3 v = V0 + s*V01 + t*V02;
  v = normalize(v);
  vec3 n = v;
  vec3 tnorm = normalize( gl_NormalMatrix * n ); // the transformed normal
  vec4 ECposition = gl_ModelViewMatrix * vec4( (Radius*v), 1. );
  LightIntensity = dot( normalize(lightPos - ECposition.xyz), tnorm );
  LightIntensity = abs( LightIntensity );
  LightIntensity *= 1.5;
  gl_Position = gl_ProjectionMatrix * ECposition;
  EmitVertex();
}

void main() {
  V01 = ( gl_PositionIn[1] - gl_PositionIn[0] ).xyz;
  V02 = ( gl_PositionIn[2] - gl_PositionIn[0] ).xyz;
  V0 = gl_PositionIn[0].xyz;
  int level = int( FpLevel );
  //int numLayers = 1 << level;
  int numLayers = int(pow(2, level));
  //int numLayers = 2;
  float dt = 1. / float( numLayers );
  float t_top = 1.;

  for( int it = 0; it < numLayers; it++ ) {
    float t_bot = t_top - dt;
    float smax_top = 1. - t_top;
    float smax_bot = 1. - t_bot;
    int nums = it + 1;
    float ds_top = smax_top / float( nums - 1 );
    float ds_bot = smax_bot / float( nums );
    float s_top = 0.;
    float s_bot = 0.;
    for( int is = 0; is < nums; is++ ) {
      ProduceVertex( s_bot, t_bot );
      ProduceVertex( s_top, t_top );
      s_top += ds_top;
      s_bot += ds_bot;
    }
    ProduceVertex( s_bot, t_bot );
    EndPrimitive();
    t_top = t_bot;
    t_bot -= dt;
  }
}