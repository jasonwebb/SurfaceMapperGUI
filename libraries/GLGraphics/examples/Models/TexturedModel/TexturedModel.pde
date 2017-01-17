// Textured GLModel example.
// By Andres Colubri.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel texquad;
GLTexture tex;

int numPoints = 4;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);  

  // The model is dynamic, which means that its coordinates can be
  // updating during the drawing loop.
  texquad = new GLModel(this, numPoints, QUADS, GLModel.DYNAMIC);
    
  // Updating the vertices to their initial positions.
  texquad.beginUpdateVertices();
  texquad.updateVertex(0, -100, -100, 0);
  texquad.updateVertex(1, 100, -100, 0);
  texquad.updateVertex(2, 100, 100, 0);
  texquad.updateVertex(3, -100, 100, 0);    
  texquad.endUpdateVertices();

  // Enabling the use of texturing...
  texquad.initTextures(1);
  // ... and loading and setting texture for this model.
  tex = new GLTexture(this, "milan.jpg");    
  texquad.setTexture(0, tex);
   
  // Setting the texture coordinates.
  texquad.beginUpdateTexCoords(0);
  texquad.updateTexCoord(0, 0, 0);
  texquad.updateTexCoord(1, 1, 0);    
  texquad.updateTexCoord(2, 1, 1);
  texquad.updateTexCoord(3, 0, 1);
  texquad.endUpdateTexCoords();

  // Enabling colors.
  texquad.initColors();
  texquad.beginUpdateColors();
  for (int i = 0; i < numPoints; i++) {
    texquad.updateColor(i, random(0, 255), random(0, 255), random(0, 255), 225);
  }
  texquad.endUpdateColors();    
}

void draw() {    
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();   
    
  background(0);
  
  translate(width/2, height/2, 200);        
  rotateY(frameCount * 0.01);   
    
  // Randomizing the vertices.
  texquad.beginUpdateVertices();
  for (int i = 0; i < numPoints; i++) { 
    texquad.displaceVertex(i, random(-1.0, 1.0), random(-1.0, 1.0), random(-1.0, 1.0));   
  }
  texquad.endUpdateVertices();    

  renderer.model(texquad);
    
  renderer.endGL();    
}
