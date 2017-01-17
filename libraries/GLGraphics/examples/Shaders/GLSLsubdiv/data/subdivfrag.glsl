varying float LightIntensity;
uniform vec4 Color;

void main() {
  gl_FragColor = vec4(LightIntensity * Color.rgb, 1.0);
  //gl_FragColor = vec4(1, 0, 0, 1.0);  
}

