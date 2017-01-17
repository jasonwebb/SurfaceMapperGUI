uniform sampler2D bilTex;
uniform int textured;

void main() {	
  if (textured == 1) gl_FragColor = gl_Color * texture2D(bilTex, gl_TexCoord[0].st).rgba;
  else gl_FragColor = gl_Color;
}

