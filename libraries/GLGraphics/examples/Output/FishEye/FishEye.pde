// This example applies a post-processing texture filter to the offscreen canvas
// in order to generate an angular fish-eye effect.
// Based on the following discussion thread in the Processing forum:
// http://forum.processing.org/topic/angular-fisheye
// Some other resources about fish-eye projections:
// 1) Excellent article from Paul Bourke on the math behind the angular fish-eye mapping  
// http://paulbourke.net/miscellaneous/domefisheye/fisheye/
// 2) Fish-eye effect implemented as a GLSL vertex shader:
// http://pixelsorcery.wordpress.com/2010/07/13/fisheye-vertex-shader/
// 3) Another fish-eye GLSL shader (didn't test it though):
// http://pages.cpsc.ucalgary.ca/~brosz/wiki/pmwiki.php/CSharp/08022008

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLGraphicsOffScreen canvas;
GLTextureFilter fisheye;
GLTexture tex;

void setup() {
  size(400, 400, GLConstants.GLGRAPHICS);
  canvas = new GLGraphicsOffScreen(this, width, height);    
  // Use antialiased surface if your video card supports it:
  //canvas = new GLGraphicsOffScreen(this, width, height, true, 4);  

  // Destination texture to store the fisheye image.
  tex = new GLTexture(this);
  
  fisheye = new GLTextureFilter(this, "FishEye.xml");
  // The aperture angle is specified in degrees. Values
  // greater than 180 can be specified, but the result won't
  // be consistent since the mapping is not one-to-one in
  // that case.
  fisheye.setParameterValue("aperture", 180.0);
}

void draw() {
  // Generating offscreen rendering:
  canvas.beginDraw();
  canvas.background(0);
  canvas.stroke(255, 0, 0);
  for (int i = 0; i < width; i += 10) {
    canvas.line(i, 0, i, height);
  }
  for (int i = 0; i < height; i += 10) {
    canvas.line(0, i, width, i);
  }
  canvas.lights();
  canvas.noStroke();
  canvas.translate(mouseX, mouseY, 100);
  canvas.rotateX(frameCount * 0.01);
  canvas.rotateY(frameCount * 0.01);  
  canvas.box(50);  
  canvas.endDraw(); 
  
  fisheye.apply(canvas.getTexture(), tex);
  image(tex, 0, 0, width, height);
}