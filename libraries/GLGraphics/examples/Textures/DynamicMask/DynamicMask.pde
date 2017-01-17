// Creating a dynamic texture mask using an offscreen surface.
 
import processing.opengl.*;
import codeanticode.glgraphics.*;

GLGraphicsOffScreen offscreen;
GLTexture imgTex;
GLTexture maskedTex;
GLTexture maskTex;
GLTextureFilter maskFilter;

// PGraphics pg;

void setup() {
  size(256, 256, GLConstants.GLGRAPHICS);
  
  maskFilter = new GLTextureFilter(this, "Mask.xml");
  imgTex = new GLTexture(this, "beach.jpg");
  maskedTex = new GLTexture(this, 256, 256);
  
  offscreen = new GLGraphicsOffScreen(this, 256, 256);
  
  // A JAVA2D surface can also be used instead, in some
  // situations it has better quality for 2D graphics:
  //pg = createGraphics(256, 256, JAVA2D);
  //maskTex = new GLTexture(this, 256, 256);    
}

void draw() {
  // Draw mask.
  offscreen.beginDraw();
  offscreen.clear(0, 0);
  offscreen.fill(0, 255);
  offscreen.ellipse(mouseX, mouseY, 50, 50);
  offscreen.endDraw();
  maskTex = offscreen.getTexture();
  
  /*  
  pg.beginDraw();
  pg.background(0, 0);
  pg.fill(0, 255);
  pg.ellipse(mouseX, mouseY, 50, 50);
  pg.endDraw();  
  maskTex.putImage(pg);  
  */  
  
  // Apply mask filter using the mask texture just generated.
  maskFilter.setParameterValue("mask_factor", 0.0f);
  maskFilter.apply(new GLTexture[]{imgTex, maskTex}, maskedTex);

  // Draw background pattern.
  background(0);
  stroke(255);
  for (int x = 0; x < width; x += 10) line(x, 0, x, height);
  for (int y = 0; y < width; y += 10) line(0, y, width, y);

  // Draw masked texture.
  image(maskedTex, 0, 0);
}
