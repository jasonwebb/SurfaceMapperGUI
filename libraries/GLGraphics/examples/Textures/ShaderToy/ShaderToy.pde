// Texture filters based on the shaders compiled by Inigo Quilez
// in the WebGL application Shader Toy:
// http://www.iquilezles.org/apps/shadertoy/
// Press any key to cycle through the available filters. Some might
// use mouse input.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTexture src1, src2, src3, src4, dest;
GLTexture[] sources;
GLTextureFilter[] filters;
int sel = 0;

void setup() {
  size(512, 384, GLConstants.GLGRAPHICS);
  frameRate(120);
  
  PFont font = loadFont("Tahoma-18.vlw");
  textFont(font, 18);

  // Some filters need repeat texturing mode.
  GLTextureParameters params = new GLTextureParameters();
  params.wrappingU = REPEAT;
  params.wrappingV = REPEAT;
  src1 = new GLTexture(this, "tex1.jpg", params);
  src2 = new GLTexture(this, "tex2.jpg", params);  
  src3 = new GLTexture(this, "tex3.jpg", params); 
  src4 = new GLTexture(this, "tex4.jpg", params);   
  dest = new GLTexture(this, width, height);
  
  filters = new GLTextureFilter[7];
  sources = new GLTexture[7];
  
  filters[0] = new GLTextureFilter(this, "Deform.xml");
  sources[0] = src1;
  
  filters[1] = new GLTextureFilter(this, "Monjori.xml");
  sources[1] = null;
  
  filters[2] = new GLTextureFilter(this, "Tunnel.xml");
  sources[2] = src1;
  
  filters[3] = new GLTextureFilter(this, "Ribbon.xml");
  sources[3] = null;
  
  filters[4] = new GLTextureFilter(this, "Mandel.xml");
  sources[4] = null;  
  
  filters[5] = new GLTextureFilter(this, "Radialblur.xml");
  sources[5] = src1;  
  
  filters[6] = new GLTextureFilter(this, "Postpro.xml");
  sources[6] = src4;  
  
  float[] res = new float[] {width, height};  
  for (int i = 0; i < filters.length; i++) {
    filters[i].setParameterValue("resolution", res);
  }
}

void draw() {
  float t = millis() / 1000.0;
  float[] mouse = new float[] {mouseX, mouseY, 0, 0};
   
  filters[sel].setParameterValue("time", t);
  if (filters[sel].hasParameter("mouse")) {
    filters[sel].setParameterValue("mouse", mouse);
  }
  if (0 < filters[sel].getNumInputTextures()) {
    filters[sel].apply(sources[sel], dest);
  } else {
    filters[sel].apply(dest);
  }
  
  image(dest, 0, 0);  
  text(filters[sel].getName() + " - fps: " + nfc(frameRate, 2) + " - time: " + nfc(t, 2), 0, 20);
}

void keyPressed() {
  sel = (sel + 1) % filters.length;
}

