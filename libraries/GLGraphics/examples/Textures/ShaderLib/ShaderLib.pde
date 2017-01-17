// Texture filters from Geeks3D GLSL Shader Library:
// http://www.geeks3d.com/geexlab/shader_library.php
// Press any key to cycle through the available filters. 
// Move mouse to show/hide the filtered texture.
// FreiChen and Sobel filters require OpenGL 3.3, so
// they won't work on machines with older versions of
// OpenGL.
//
// Portrait image by David Blackwell (http://www.flickr.com/photos/mobilestreetlife/).
// Car picture from http://coding-experiments.blogspot.com/2011/01/toon-pixel-shader.html

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTexture[] sources; 
GLTexture dest;
GLTextureFilter[] filters;
int selFilter = 0;
int selImage = 0;

void setup() {
  size(512, 384, GLConstants.GLGRAPHICS);
  frameRate(120);
  
  PFont font = loadFont("Tahoma-18.vlw");
  textFont(font, 18);

  sources = new GLTexture[2];
  sources[0] = new GLTexture(this, "portrait.jpg");
  sources[1] = new GLTexture(this, "car.jpg");
  dest = new GLTexture(this, width, height);
  
  filters = new GLTextureFilter[7];  
  filters[0] = new GLTextureFilter(this, "CrossHatch.xml");
  filters[1] = new GLTextureFilter(this, "Thermal.xml");
  filters[2] = new GLTextureFilter(this, "Toon.xml");
  filters[3] = new GLTextureFilter(this, "Dream.xml");
  filters[4] = new GLTextureFilter(this, "CrossStich.xml");
  filters[5] = new GLTextureFilter(this, "FreiChen.xml");
  filters[6] = new GLTextureFilter(this, "Sobel.xml");
  
  textureMode(NORMALIZED);
}

void draw() {
  filters[selFilter].apply(sources[selImage], dest);
    
  noStroke();
  
  beginShape(QUADS);
  texture(sources[selImage]);
  vertex(0, 0, 0, 0);
  vertex(mouseX, 0, float(mouseX)/width, 0); 
  vertex(mouseX, height, float(mouseX)/width, 1); 
  vertex(0, height, 0, 1);  
  endShape();
 
  beginShape(QUADS);
  texture(dest);
  vertex(mouseX, 0, float(mouseX)/width, 0);
  vertex(width, 0, 1, 0); 
  vertex(width, height, 1, 1); 
  vertex(mouseX, height, float(mouseX)/width, 1);  
  endShape();
 
  fill(255, 0, 0);   
  stroke(255, 0, 0);
  line(mouseX, 0, mouseX, height);
  text(filters[selFilter].getName(), 0, 20);
}

void keyPressed() {
  if (key == '1') {
    selImage = 0;
  } else if (key == '2') {
    selImage = 1;
  } else {    
    selFilter = (selFilter + 1) % filters.length;
  }
}

