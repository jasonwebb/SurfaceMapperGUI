// Example showing the integration of GLGraphics, proscene and 
// plain OpenGL. 

import processing.opengl.*;
import codeanticode.glgraphics.*;

// Proscene library for camera handling. Download from here:
// http://code.google.com/p/proscene/
import remixlab.proscene.*;

// This import is needed to use OpenGL directly.
import javax.media.opengl.*;

GLModel cube;
Scene scene;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);
  
  scene = new Scene(this);
  scene.setRadius(200);
  scene.showAll();
  scene.setAxisIsDrawn(false);
  scene.setGridIsDrawn(false);  
 
  cube = new GLModel(this, 24, QUADS, GLModel.STATIC);
  
  cube.beginUpdateVertices();
  // Front face
  cube.updateVertex(0, -100, -100, +100);
  cube.updateVertex(1, +100, -100, +100);
  cube.updateVertex(2, +100, +100, +100);
  cube.updateVertex(3, -100, +100, +100);
  // Back face
  cube.updateVertex(4, -100, -100, -100);
  cube.updateVertex(5, +100, -100, -100);
  cube.updateVertex(6, +100, +100, -100);
  cube.updateVertex(7, -100, +100, -100);
  // Rigth face
  cube.updateVertex(8, +100, -100, +100);
  cube.updateVertex(9, +100, -100, -100);
  cube.updateVertex(10, +100, +100, -100);
  cube.updateVertex(11, +100, +100, +100);
  // Left face
  cube.updateVertex(12, -100, -100, +100);
  cube.updateVertex(13, -100, -100, -100);
  cube.updateVertex(14, -100, +100, -100);
  cube.updateVertex(15, -100, +100, +100);
  // Top face
  cube.updateVertex(16, +100, +100, +100);
  cube.updateVertex(17, +100, +100, -100);
  cube.updateVertex(18, -100, +100, -100);
  cube.updateVertex(19, -100, +100, +100);
  // Bottom face
  cube.updateVertex(20, +100, -100, +100);
  cube.updateVertex(21, +100, -100, -100);
  cube.updateVertex(22, -100, -100, -100);
  cube.updateVertex(23, -100, -100, +100);
  cube.endUpdateVertices();
  
  cube.initColors();
  cube.beginUpdateColors();
  // Front face
  cube.updateColor(0, 200, 50, 50, 100);
  cube.updateColor(1, 200, 50, 50, 100);
  cube.updateColor(2, 200, 50, 50, 100);
  cube.updateColor(3, 200, 50, 50, 100);
  // Back face 
  cube.updateColor(4, 50, 200, 50, 100);
  cube.updateColor(5, 50, 200, 50, 100);
  cube.updateColor(6, 50, 200, 50, 100);
  cube.updateColor(7, 50, 200, 50, 100);
  // Rigth face
  cube.updateColor(8, 50, 50, 200, 100);
  cube.updateColor(9, 50, 50, 200, 100);
  cube.updateColor(10, 50, 50, 200, 100);
  cube.updateColor(11, 50, 50, 200, 100);
  // Left face
  cube.updateColor(12, 200, 200, 50, 100);
  cube.updateColor(13, 200, 200, 50, 100);
  cube.updateColor(14, 200, 200, 50, 100);
  cube.updateColor(15, 200, 200, 50, 100);
  // Top face
  cube.updateColor(16, 50, 200, 200, 100);
  cube.updateColor(17, 50, 200, 200, 100);
  cube.updateColor(18, 50, 200, 200, 100);
  cube.updateColor(19, 50, 200, 200, 100);
  // Bottom face
  cube.updateColor(20, 200, 50, 200, 100);
  cube.updateColor(21, 200, 50, 200, 100);
  cube.updateColor(22, 200, 50, 200, 100);
  cube.updateColor(23, 200, 50, 200, 100);
  cube.endUpdateColors();
}

void draw() {
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
  
  // We get the gl object contained in the GLGraphics renderer.
  GL gl = renderer.gl;

  background(0);

  // Now we can do direct calls to OpenGL:
  gl.glEnable(GL.GL_BLEND);
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
 
  // Disabling depth masking to properly render a semitransparent
  // object without using depth sorting.
  gl.glDepthMask(false);  
  renderer.model(cube);
  gl.glDepthMask(true);
  
  renderer.endGL();    
}