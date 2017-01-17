// MillionCubes example.
// By Andres Colubri
//
// This example draws 1,000,000 cubes using GLModel + indexed 
// vertices. Vertex indices allow to reduce the vertex count of 
// a model // by reusing vertices shared between quads or triangles.
//
// One limitation of using vertex indices occurs when shared
// vertices need to have different texture coordinates, normals
// or colors assigned to them, depending on which face they are
// in. In this case they cannot be shared, and they need to be
// duplicated for each different texcoord/normal/color value.
// This discussion is relevant on this issue:
// http://www.mail-archive.com/android-developers@googlegroups.com/msg86794.html
//
// Also note that 1 million cubes might be too taxing for
// some GPUs. If this sketch runs too slow, decrease the cube 
// count below.

import processing.opengl.*;
import codeanticode.glgraphics.*;

int cubeCount = 1000000;
float cubeSize = 10;
float volSize = 300;

GLModel cubes;
GLModel xcubes;

// The indices that connect the 8 vertices
// in a single cube, in the form of 12 triangles.
int cubeIndices[] = {0, 4, 5, 0, 5, 1,
                     1, 5, 6, 1, 6, 2,
                     2, 6, 7, 2, 7, 3,
                     3, 7, 4, 3, 4, 0,
                     4, 7, 6, 4, 6, 5,
                     3, 0, 1, 3, 1, 2};

Chronometer chrono;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);
  
  chrono = new Chronometer();
 
  println("Creating cubes...");  
  createIndexedCubes();
  println("Done.");
  
  printInfo();  
}

void draw() {
  chrono.update();  
  
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
 
  background(0);
 
  translate(width/2, height/2, -500);        
  rotateY(frameCount * 0.01); 

  renderer.model(xcubes);

  renderer.endGL();    
  
  chrono.printFps();
}

void printInfo() {
  println("Drawing indexed vertices");
}

// Indexed cubes
void createIndexedCubes() {
  xcubes = new GLModel(this, 8 * cubeCount, TRIANGLES, GLModel.STATIC);
  
  xcubes.beginUpdateVertices();
  for (int i = 0; i < cubeCount; i++) {
    int n0 = 8 * i;
    float x0 = random(-volSize, +volSize);
    float y0 = random(-volSize, +volSize);    
    float z0 = random(-volSize, +volSize);    
    xcubes.updateVertex(n0 + 0, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
    xcubes.updateVertex(n0 + 1, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
    xcubes.updateVertex(n0 + 2, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
    xcubes.updateVertex(n0 + 3, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
    xcubes.updateVertex(n0 + 4, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
    xcubes.updateVertex(n0 + 5, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
    xcubes.updateVertex(n0 + 6, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
    xcubes.updateVertex(n0 + 7, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
  }
  xcubes.endUpdateVertices();
  
  xcubes.initColors();
  xcubes.setColors(255, 10);
  
  // Creating vertex indices for all the cubes in the model.
  // Since each cube is identical, the indices are the same,
  // with the exception of the shifting to take into account
  // the position of the cube inside the model.
  int indices[] = new int[36 * cubeCount];  
  for (int i = 0; i < cubeCount; i++) {
    int n0 = 36 * i;    
    int m0 = 8 * i;
    for (int j = 0; j < 36; j++) {
      indices[n0 + j] = m0 + cubeIndices[j];
    }
  }  
  
  xcubes.initIndices(36 * cubeCount);
  xcubes.updateIndices(indices);  
}

// Normal cubes, it is disabled because it takes too much memory to even run
void createCubes() {
  cubes = new GLModel(this, 24 * cubeCount, QUADS, GLModel.STATIC);  
  cubes.beginUpdateVertices();
  for (int i = 0; i < cubeCount; i++) {
    int n0 = 24 * i;
    float x0 = random(-volSize, +volSize);
    float y0 = random(-volSize, +volSize);    
    float z0 = random(-volSize, +volSize);    
    // Front face
    cubes.updateVertex(n0 + 0, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 1, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 2, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 3, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
    // Back face
    cubes.updateVertex(n0 + 4, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 5, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 6, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 7, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
    // Rigth face
    cubes.updateVertex(n0 + 8, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 9, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 10, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 11, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
    // Left face
    cubes.updateVertex(n0 + 12, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 13, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 14, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 15, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
    // Top face
    cubes.updateVertex(n0 + 16, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 17, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 18, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 19, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
    // Bottom face
    cubes.updateVertex(n0 + 20, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
    cubes.updateVertex(n0 + 21, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 22, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
    cubes.updateVertex(n0 + 23, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
  }
  cubes.endUpdateVertices();
  
  cubes.initColors();
  cubes.setColors(255, 10);  
}
