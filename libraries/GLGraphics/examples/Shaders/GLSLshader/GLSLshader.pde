// Example of GLSL shader with GLGraphics.
// Adapted from Vitamin's shaderlib:
// http://www.pixelnerve.com/processing/libraries/shaderlib/
// More online resources about GLSL:
// http://nehe.gamedev.net/data/articles/article.asp?article=21
// http://zach.in.tu-clausthal.de/teaching/cg_literatur/glsl_tutorial/index.html

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel torus;
GLSLShader shader;
float angle;

void setup() {
  size(800, 600, GLConstants.GLGRAPHICS);

  torus = createTorus(100, 50, 20, 100, 200, 0, 150, 255, "");  
  
  // Loading toon shader. Taken from here:
  // http://www.lighthouse3d.com/opengl/glsl/index.php?toon3
  shader = new GLSLShader(this, "toonvert.glsl", "toonfrag.glsl");
}

void draw() {
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
  
  background(0);  

  lights();
  
  // Centering the model in the screen.
  translate(width/2, height/2, 0);
  
  angle += 0.01;
  rotateY(angle);

  // The light is drawn after applying the translation and
  // rotation trasnformations, so it always shines on the
  // same side of the torus.
  pointLight(250, 250, 250, 0, 600, 400);   

  shader.start(); // Enabling shader.
  // Any geometry drawn between the shader's stop() and end() will be 
  // processed by the shader.
  renderer.model(torus);
  shader.stop(); // Disabling shader.

  renderer.endGL();  
}

