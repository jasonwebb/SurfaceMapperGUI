// Directional lights example ported from P3D to GLGraphics.
// Please note that the light calls between beginGL/endGL
// affect only OpenGL geometry, such as GLModels.
// Geometry generated with regular Processing calls should be
// drawn and shaded outside beginGL/endGL.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel sphere1;

void setup() {
  size(640, 360, GLConstants.GLGRAPHICS); 
 
  sphere1 = createSphere(40, 60);
  sphere1.setTint(204);
}

void draw() {      
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();  
  
  noStroke(); 
  background(0); 
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
  directionalLight(204, 204, 204, dirX, dirY, 1); 
  translate(width/2, height/2, 0); 
  renderer.model(sphere1); 
  rotateY(frameCount * 0.01);
  translate(150, 0, 0); 
  renderer.model(sphere1); 
  
  renderer.endGL();  
}
