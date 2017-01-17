// Rendering the result of a texture filter operation to a 3D model.
// By Andres Colubri.
//
// Basically, the luminance of of the pixels that result of applying 
// a pulsating emboss filter on an image are used as the Z coordinates 
// of the model. The number of vertices in the model equals  the 
// resolution of the source image, in this case 200x200 = 40000. 
// All of this can be done very quickly because the model is stored and updated
// directly in the GPU memory. There are no transfers between CPU and GPU.
//
// It uses the Obsessive Camera Direction library:
// http://www.gdsstudios.com/processing/libraries/ocd/reference/

import processing.opengl.*;
import codeanticode.glgraphics.*;

import damkjer.ocd.*;

GLTextureFilter pulse, zMap;
GLTexture srcTex, tmpTex, destTex;
GLModel destModel;

Camera cam;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);
  
  cam = new Camera(this, 0, 0, 150); 
   
  srcTex = new GLTexture(this, "dali.jpg");

  // Pulsating emboss filter.
  pulse = new GLTextureFilter(this, "pulsatingEmboss.xml");
  
  // This filter extracts the brightness of an input image.
  zMap = new GLTextureFilter(this, "brightExtract.xml");
  
  tmpTex = new GLTexture(this, srcTex.width, srcTex.height);  
  destTex = new GLTexture(this, srcTex.width, srcTex.height, GLTexture.FLOAT, GLTexture.NEAREST_SAMPLING);
  
  int numPoints = srcTex.width * srcTex.height;
  destModel = new GLModel(this, numPoints, POINTS, GLModel.STREAM);
  destModel.initColors();
  destModel.setColors(255, 100);
}

void draw() {
  background(0);
  
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
    
  pulse.apply(srcTex, tmpTex);
  // The brightness from tmpTex is written into destTex and also into destModel.
  zMap.apply(tmpTex, destTex, destModel); 

  cam.feed();

  renderer.model(destModel);
  
  renderer.endGL();   
   
  println(frameRate);
}

void mouseMoved() {
  cam.circle(radians(mouseX - pmouseX));
}