// Bilboard quads using GLModel and GLModelEffect. The size of the
// quads is arbitrary, and they always face the camera using bilboarding
// done on the GPU with a GLSL shader. The quads are not affected by
// lighting.
// By Andres Colubri.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel model;
GLModelEffect bilboard;
GLTexture tex;
float[] coords;
float[] objcorn;
float[] colors;
float[] tcoords;

int numSprites = 50000;
float spriteWidth = 50.0;
float spriteHeight = 50.0;
float spriteAlpha = 0.8;
boolean textured = false;
boolean shake = false;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);  
    
  model = new GLModel(this, 4 * numSprites, GLModel.QUADS, GLModel.DYNAMIC);  
  
  bilboard = new GLModelEffect(this, "bilboard.xml");
    
  // 4 vertices per sprite (1 sprite = 1 quad), and four coordinates per vertex:
  coords = new float[4 * 4 * numSprites];
  colors = new float[4 * 4 * numSprites];
  
  // Each sprite quad has 4 vertex attributes, consisting in the quad corners.
  objcorn = new float[4 * 3 * numSprites];
    
  // For texture coordinates, only two coordinates (uv) per vertex:
  tcoords = new float[4 * 2 * numSprites];
    
  for (int n = 0; n < numSprites; n++) {
    // Generating random quad for sprite n (note that the texture coordinates
    // need to be inverted because the GLModel uses OpenGL convention for
    // orientation of Y axis). Each quad is defined by the center point
    // (x0, y0, z0), and the four displacements to define corners: 
    
    float x0 = 200 * random(-1, 1); 
    float y0 = 200 * random(-1, 1);
    float z0 = 200 * random(-1, 1);
    
    // Corner 0 of sprite n.
    coords[16 * n + 0] = x0; 
    coords[16 * n + 1] = y0;
    coords[16 * n + 2] = z0;
    coords[16 * n + 3] = 1.0;    
    objcorn[12 * n + 0] = -0.5 * spriteWidth; 
    objcorn[12 * n + 1] = -0.5 * spriteHeight;
    objcorn[12 * n + 2] = 0;
    tcoords[8 * n + 0] = 0; 
    tcoords[8 * n + 1] = 1;    

    // Corner 1 of sprite n.
    coords[16 * n + 4 + 0] = x0; 
    coords[16 * n + 4 + 1] = y0;
    coords[16 * n + 4 + 2] = z0;
    coords[16 * n + 4 + 3] = 1.0;
    objcorn[12 * n + 3 + 0] = +0.5 * spriteWidth; 
    objcorn[12 * n + 3 + 1] = -0.5 * spriteHeight; 
    objcorn[12 * n + 3 + 2] = 0;
    tcoords[8 * n + 2] = 1; 
    tcoords[8 * n + 3] = 1;    

    // Corner 2 of sprite n.
    coords[16 * n + 8 + 0] = x0;
    coords[16 * n + 8 + 1] = y0;
    coords[16 * n + 8 + 2] = z0;
    coords[16 * n + 8 + 3] = 1.0;
    objcorn[12 * n + 6 + 0] = +0.5 * spriteWidth; 
    objcorn[12 * n + 6 + 1] = +0.5 * spriteHeight; 
    objcorn[12 * n + 6 + 2] = 0;
    tcoords[8 * n + 4] = 1; 
    tcoords[8 * n + 5] = 0;   

    // Corner 3 of sprite n.
    coords[16 * n + 12 + 0] = x0; 
    coords[16 * n + 12 + 1] = y0;
    coords[16 * n + 12 + 2] = z0;
    coords[16 * n + 12 + 3] = 1.0;    
    objcorn[12 * n + 9 + 0] = -0.5 * spriteWidth; 
    objcorn[12 * n + 9 + 1] = +0.5 * spriteHeight;
    objcorn[12 * n + 9 + 2] = 0;
    tcoords[8 * n + 6] = 0; 
    tcoords[8 * n + 7] = 0;    
     
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) colors[16 * n + 4 * i + j] = random(0, 1);
      colors[16 * n + 4 * i + 3] = spriteAlpha;
    }
  }

  model.updateVertices(coords);
   
  model.initColors();
  model.updateColors(colors);

  tex = new GLTexture(this, "tree.png");
  model.initTextures(1);
  model.setTexture(0, tex);   
  model.updateTexCoords(0, tcoords);
  
  model.initAttributes(1);
  model.setAttribute(0, "Object corners", 3);
  model.updateAttributes(0, objcorn);

  // The options for blend mode are: BLEND (Processing's default blending mode),
  // ADD, MULTIPLY and SUBSTRACT.
  model.setBlendMode(BLEND); 
}

void draw() {    
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();  
    
  background(0);
        
  if (shake) {
    for (int n = 0; n < numSprites; n++) {        
      float[] d = new float[] {random(-5.0, 5.0), random(-5.0, 5.0), random(-5.0, 5.0)};
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
          coords[16 * n + 4 * i + j] += d[j]; 
        }
      }
    }    
    model.updateVertices(coords);
  }
  
  translate(width/2, height/2, map(mouseY, 0, height, 0, -600));
  rotateX(map(mouseX, 0, width, 0, TWO_PI));
  
  // Render the model using the bilboard effect:  
  bilboard.setParameterValue("textured", textured ? 1 : 0);
  model.render(bilboard);
  
  renderer.endGL();
      
  println(frameRate);
}

void keyPressed() {
  if (key == 's') shake = !shake;
  else if (key == 't') textured = !textured;
}

