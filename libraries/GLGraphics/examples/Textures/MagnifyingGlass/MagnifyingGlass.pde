// Magnifying glass filter. 
// Original version by Daniel Howe.
// Port to GLSL by Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;

int lensDiam = 900;
float magFactor = 5, scalef = .3f;
GLTexture textImage, lensImage;
GLTextureFilter lensFilter;

void setup() {
  size(450, 450, GLConstants.GLGRAPHICS);
  noFill();
  ellipseMode(CORNERS);
  textureMode(NORMAL);
  textImage = new GLTexture(this, "text.png");
  lensImage = new GLTexture(this, textImage.width, textImage.height);
  lensFilter = new GLTextureFilter(this, "Mask.xml");
}

void draw() {
  int radius = lensDiam/2;
  float radiusAdj = radius/magFactor;
  float lensDiamAdj = (int)(lensDiam/magFactor);

  if (mouseX <= 0) mouseX = width/2;
  if (mouseY <= 0) mouseY = height/2;
  
  float x0 = constrain(mouseX, 90, width - 90);
  float y0 = constrain(mouseY, 90, height - 90);

  float x = (x0 - radiusAdj);
  float y = (y0 - radiusAdj);

  // display the original picture
  image(textImage, 0, 0, width, height); 
  
  // Converting magnified area to normalized texture coordinates:
  float u0 = constrain(x / width, 0, 1);
  float v0 = constrain(y / height, 0, 1);
  float u1 = constrain(u0 + lensDiamAdj / width, 0, 1);
  float v1 = constrain(v0 + lensDiamAdj / height, 0, 1);  
  
  // Making pixels transparent outside the lens area.
  lensFilter.setParameterValue("center", new float[]{(u0 + u1)/2, (v0 + v1) / 2});
  lensFilter.setParameterValue("radius", (float)radiusAdj/(width));
  lensFilter.apply(textImage, lensImage);

  // display magnified image  
  noStroke();
  translate(x0 - (radius*scalef), y0 - (radius*scalef));
  scale(scalef);
  beginShape(QUADS);
  texture(lensImage);
  vertex(0, 0, u0, v0);
  vertex(lensDiam, 0, u1, v0);
  vertex(lensDiam, lensDiam, u1, v1);
  vertex(0, lensDiam, u0, v1);
  endShape();
  
  // drawing lens border.
  stroke(0);
  noFill();
  ellipse(0, 0, lensDiam,lensDiam);
}

