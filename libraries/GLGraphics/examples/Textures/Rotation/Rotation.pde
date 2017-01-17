// Example showing how to pass a matrix parameter to a texture 
// filter. The matrix is used to rotate the texture coordinates
// of the source texture.
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTexture srcTex, desTex;
GLTextureFilter rotationFilter;
PMatrix2D rotationMatrix;
float[] rotationArray;

void setup() {
  size(256, 256, GLConstants.GLGRAPHICS);

  srcTex = new GLTexture(this, "beach.jpg");
  desTex = new GLTexture(this);
  
  rotationFilter = new GLTextureFilter(this, "Rotation.xml");
  rotationMatrix = new PMatrix2D();  
  rotationArray = new float[4];
}

void draw() {
  // Composing previous rotation with the new one...
  rotationMatrix.rotate(map(mouseX, 0, width, 0, TWO_PI));

  rotationArray[0] = rotationMatrix.m00;
  rotationArray[1] = rotationMatrix.m01;  
  rotationArray[2] = rotationMatrix.m10;
  rotationArray[3] = rotationMatrix.m11;  
  
  rotationFilter.setParameterValue("rot_matrix", rotationArray);
  srcTex.filter(rotationFilter, desTex);

  image(desTex, 0, 0);
}
