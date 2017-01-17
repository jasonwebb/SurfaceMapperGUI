// Example of Cg shader with GLGraphics.
// Original by Andres Colubri, lighting improvements by Kevin Bjorke.
//
// It requires the Cg toolkit from NVidia installed on the system:
// http://developer.nvidia.com/object/cg_toolkit.html
// Adapted from Vitamin's shaderlib:
// http://www.pixelnerve.com/processing/libraries/shaderlib/
// More online resources about Cg:
// http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=47
// http://arxiv.org/abs/cs/0302013

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel torus;
GLCgShader shader;
float angle; // rotate model
float lTheta; // orbit lamp
float lGamma; // orbit lamp

void setup() {
  size(800, 600, GLConstants.GLGRAPHICS);
  torus = createTorus(240, 110, 12, 48, "UV.jpg", "alpha.png");
  
  shader = new GLCgShader(this, "diffusevert.cg", "diffusefrag.cg"); // load both vertex and pixel shaders as one
  angle = 0;
  lTheta = 0.2;
  lGamma = 1.1;
}

void draw() {
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
  
  background(0);  // Just a black background.
  
  // Centering the model in the screen.
  translate(width/2, height/2, 0);  
    
  rotateY(angle);
  rotateZ(angle);
  
  shader.start(); // Enabling shader.
  
  // The parameters of the Cg shader can be set with the methods setTexParameter, 
  // setIntParameter, setFloatParameter, etc., but first the program containing the
  // parameter (either fragment, geometry or fragment) needs to be specified.
  shader.setProgram(GLConstants.FRAGMENT_PROGRAM);
  
  // These calls are actually redundant, because Cg will use which textures
  // from binding them in OpenGL (the GLModel object takes does this when it
  // is drawn).
  shader.setTexParameter("decalMap", torus.getTexture(0));
  shader.setTexParameter("alphaMap", torus.getTexture(1));
      
  // Also, the modelview-projection matrix from OpenGL must be passed explicitly
  // to the shader using the setModelviewProjectionMatrix() method:
  shader.setProgram(GLConstants.VERTEX_PROGRAM); // The modelview-projection parameter is in the vertex program.
  shader.setModelviewProjectionMatrix("worldViewProj");
      
  // This shader also needs the position of the light in the scene to calculate
  // the diffuse color of the pixels.
  float radius = 380.0;
  float gx = radius * cos(lGamma);
  float gz = radius * sin(lGamma);
  float gy = sin(lTheta)*gx;
  gx *= cos(lTheta);
  shader.setVecParameter("lightPos", gx, gy, gz);
      
  // Any geometry drawn between shader.start() and shader.stop() will be 
  // processed by the shader.
  renderer.model(torus);
      
  shader.stop(); // Disabling shader.

  renderer.endGL();
  
  // Advance animation
  angle += 0.01;
  lTheta += 0.003;
  lGamma += 0.041;
}
