// Swarming points using GLModel and GLCamera, using sprite textures.
// By Andres Colubri.
//
// It uses the Obsessive Camera Direction library:
// http://www.gdsstudios.com/processing/libraries/ocd/reference/

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel model;
GLTexture tex;
float[] coords;
float[] colors;

int numPoints = 10000;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);  
    
  model = new GLModel(this, numPoints, GLModel.POINT_SPRITES, GLModel.DYNAMIC);
  model.initColors();
  tex = new GLTexture(this, "particle.png");    
    
  coords = new float[4 * numPoints];
  colors = new float[4 * numPoints];
    
  for (int i = 0; i < numPoints; i++) {
    for (int j = 0; j < 3; j++) coords[4 * i + j] = 100.0 * random(-1, 1);
    coords[4 * i + 3] = 1.0; // The W coordinate of each point must be 1.
    for (int j = 0; j < 3; j++) colors[4 * i + j] = random(0, 1);
    colors[4 * i + 3] = 0.9;
  }

  model.updateVertices(coords);
  model.updateColors(colors);

   float pmax = model.getMaxPointSize();
   println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   
   model.initTextures(1);
   model.setTexture(0, tex);  
   // Setting the maximum sprite to the 90% of the maximum point size.
   model.setMaxSpriteSize(0.9 * pmax);
   // Setting the distance attenuation function so that the sprite size
   // is 20 when the distance to the camera is 400.
   model.setSpriteSize(20, 400);
   model.setBlendMode(BLEND);
}

void draw() {    
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();  
    
  background(0);
        
  for (int i = 0; i < numPoints; i++) {    
    for (int j = 0; j < 3; j++) {
      coords[4 * i + j] += random(-0.5, 0.5);
    }
  }
    
  model.updateVertices(coords);
    
  translate(width/2, height/2, 0);        
  rotateY(frameCount * 0.01);     
    
  // Disabling depth masking to properly render semitransparent
  // particles without need of depth-sorting them.    
  renderer.setDepthMask(false);
  model.render();
  renderer.setDepthMask(true);
    
  renderer.endGL();
}
