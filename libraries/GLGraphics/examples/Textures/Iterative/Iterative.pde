// This example shows an iterative mode in the texture filters.
// It might improve performance when applying a filter iteratively.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTexturePingPong texPP;
GLTexture tex0, tex1;
GLTextureFilter blur;

int fcount, lastm;
float frate;
int fint = 3;

void setup() {
  size(400, 300, GLConstants.GLGRAPHICS);  
  
  tex0 = new GLTexture(this, "kyoto.jpg");
  tex1 = new GLTexture(this, tex0.width, tex0.height);
  texPP = new GLTexturePingPong(tex0, tex1);
  
  blur = new GLTextureFilter(this, "Blur.xml");
}

void draw() {
  blur.beginIterativeMode();
  for (int i = 0; i < 100; i++) {
    blur.apply(texPP.getReadTex(), texPP.getWriteTex());
    texPP.swap();
  }
  blur.endIterativeMode();
  
  image(texPP.getWriteTex(), 0, 0, width, height);
  
  fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m; 
  } 
  println("FPS: " + nfc(frate, 2));  
}
