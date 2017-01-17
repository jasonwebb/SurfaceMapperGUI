// Example of GLSL geometry shader with GLGraphics.
// Adapted from example code in tutorial by Mike Bailey
// http://www.docstoc.com/docs/48449742/GLSL-Geometry-Shaders
// http://web.engr.oregonstate.edu/~mjb/WebMjb/mjb.html
//
// The data sent to the GPU using a GLModel is an octahedron,
// and the geometry shader emits new vertices in order to subdivide
// the original triangles into a finer mesh.
// Move the mouse from left to right to increase the dubdivision.

import processing.opengl.*;
import codeanticode.glgraphics.*;

ArrayList vertices;
ArrayList normals;

GLModel octa;
GLSLShader shader;

float angle;

void setup() {
  size(400, 400, GLConstants.GLGRAPHICS);

  genOctahedron();
  octa = new GLModel(this, vertices.size(), TRIANGLES, GLModel.STATIC); 
  octa.updateVertices(vertices);    
  octa.initNormals();
  octa.updateNormals(normals);
  
  shader = new GLSLShader(this, "subdivvert.glsl", "subdivgeom.glsl", "subdivfrag.glsl");
  int n = shader.getMaxOutVertCount();
  println("Maximum number of vertices that can be emitted by the geometry shader: " + n);
  shader.setupGeometryShader(TRIANGLES, TRIANGLE_STRIP, n);
}

void draw() {
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
  
  background(0);  

  translate(width/2, height/2, 0);
  angle += 0.01;
  rotateY(angle);            

  shader.start();
  shader.setFloatUniform("FpLevel", int(map(mouseX, 0, width, 0, 4)));
  shader.setFloatUniform("Radius", 100);
  shader.setVecUniform("Color", 1, 1, 0, 1);
  renderer.model(octa);
  shader.stop();

  renderer.endGL();  
}



