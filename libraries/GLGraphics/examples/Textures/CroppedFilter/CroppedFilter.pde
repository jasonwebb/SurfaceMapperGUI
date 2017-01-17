// Example showing the cropping and tinting 
// methods available in GLTextureFilter.
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTextureFilter gauss;
GLTexture src, dest;
  
void setup() {
  size(256, 256, GLConstants.GLGRAPHICS);

  src = new GLTexture(this, "beach.jpg");
  dest = new GLTexture(this, 100, 100);
  gauss = new GLTextureFilter(this, "Blur.xml");
  
  // Setting a crop region. Disable cropping calling
  // noCrop().
  gauss.setCrop(50, 50, 100, 100);
}

void draw() {
  // The tint color might be used by the filter to
  // mix the colors of the source and destination
  // textures
  gauss.setTint(255, map(mouseX, 0, width, 0, 255));
  
  gauss.apply(src, dest);
  image(dest, 0, 0, width, height);
}
