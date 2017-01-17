uniform sampler2D sceneTex;

void main ()
{
  vec2 uv = gl_TexCoord[0].xy;
  vec4 c = texture2D(sceneTex, uv);

  c += texture2D(sceneTex, uv+0.001);
  c += texture2D(sceneTex, uv+0.003);
  c += texture2D(sceneTex, uv+0.005);
  c += texture2D(sceneTex, uv+0.007);
  c += texture2D(sceneTex, uv+0.009);
  c += texture2D(sceneTex, uv+0.011);

  c += texture2D(sceneTex, uv-0.001);
  c += texture2D(sceneTex, uv-0.003);
  c += texture2D(sceneTex, uv-0.005);
  c += texture2D(sceneTex, uv-0.007);
  c += texture2D(sceneTex, uv-0.009);
  c += texture2D(sceneTex, uv-0.011);

  c.rgb = vec3((c.r+c.g+c.b)/3.0);
  c = c / 9.5;
  gl_FragColor = c;
}