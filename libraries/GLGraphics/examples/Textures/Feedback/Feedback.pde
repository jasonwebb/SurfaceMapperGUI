// Effect by Spector:
// http://www.aaaaaaaarrrrrrrrggggggggbbbbbbbb.net/
// Move the mouse around to change the parameters of the
// filter and obtain different visual results.

import processing.opengl.*;
import codeanticode.glgraphics.*;

int sketchWidth = 800;
int sketchHeight = 524;

PImage img;

GLTextureFilter feedBack;
GLTextureParameters params;
GLTexture[] pmedian;
int read = 0;
int write = 0;

void setup() {
  size(sketchWidth, sketchHeight, GLConstants.GLGRAPHICS);
  textureSetup();
  frameRate(30);
}

void draw() {
  background(255);
  drawTexture();
}

void textureSetup() {
  img = createImage(width, height, RGB);
  // Create noise
  makeImg(img);
  params = new GLTextureParameters();
  params.wrappingU = REPEAT;
  params.wrappingV = REPEAT;

  feedBack = new GLTextureFilter(this, "Feedback.xml");

  pmedian = new GLTexture[2];
  pmedian[0] = new GLTexture(this, width, height, params);
  pmedian[1] = new GLTexture(this, width, height, params);
  
  pmedian[0].putImage(img);
  read = 0;
  write = 1;
}

void drawTexture() {
  feedBack.setParameterValue("radio", map(mouseY, 0, width, radians(0), radians(360)));
  feedBack.setParameterValue("amp", map(mouseX, 0, width, .1, 6.));

  feedBack.apply(pmedian[read], pmedian[write]);

  image(pmedian[write], 0, 0);
   
  int temp = write;
  write = read;
  read = temp;
}

void makeImg(PImage imgd) {
  imgd.loadPixels();
  
  for (int i=0; i<imgd.width*imgd.height; i++) {
    imgd.pixels[i] = color(random(256), random(256), random(256), random(256));
  }
  
  imgd.updatePixels();
}
