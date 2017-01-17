// Off-screen rendering example using GLGraphics.
// By Andres Colubri. Multisampling support in GLGraphicsOffScreen
// implemented by Ilias Bergstrom (http://www.onar3d.com/) 
//
// Drag the mouse accross the horizontal direction to change
// the mixing of the two off-screen textures.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLGraphicsOffScreen glg1, glg2;

int mixFactor = 127;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);
    
  // Creating an off-screen drawing surfaces. The first one has
  // 4x multi-sampling enabled.
  glg1 = new GLGraphicsOffScreen(this, 320, 240, true, 4);
  glg2 = new GLGraphicsOffScreen(this, 200, 100);

  // Disabling stroke lines in the first off-screen surface.
  glg1.beginDraw();
  glg1.noStroke();
  glg1.endDraw();
}

void draw() {
  background(0);
  
  // In the off-screen surface 1, we draw random ellipses.
  glg1.beginDraw();
  glg1.fill(230, 50, 20, random(50, 200));
  glg1.ellipse(random(0, glg1.width), random(0, glg1.height), random(10, 50), random(10, 50));
  glg1.endDraw();   

  // In the off-screen surface 2, we draw random rectangles.  
  glg2.beginDraw();
  glg2.fill(20, 50, 230, random(50, 200));
  glg2.rect(random(0, glg2.width), random(0, glg2.height), random(10, 50), random(10, 50));
  glg2.endDraw();   

  // We mix the images together and scale them so the occupy the entire screen.
  tint(255, 255 - mixFactor);
  image(glg1.getTexture(), 10, 10, width - 20, height - 20); 

  tint(255, mixFactor);
  image(glg2.getTexture(), 10, 10, width - 20, height - 20);

  // Image border for reference.
  noFill();
  stroke(255);
  rect(10, 10, width - 20, height - 20);  
  fill(0); // 1.0.2/1.0.3 need this, because noFill() affects the tint used in image().
}

void mouseDragged() {
  mixFactor = int(255 * float(mouseX) / width);
}