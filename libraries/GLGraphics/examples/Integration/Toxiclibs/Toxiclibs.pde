// Integration between GLGraphics and Toxiclibs. 
//
// Adapted from NoiseSurfaceDemo example from toxiclibs,
// which comes with the following license:

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.volume.*;
import toxi.math.noise.*;

import processing.opengl.*;
import codeanticode.glgraphics.*;

import javax.media.opengl.*;

int DIMX=192;
int DIMY=64;
int DIMZ=64;

float ISO_THRESHOLD = 0.1;
float NS=0.03;
Vec3D SCALE=new Vec3D(3, 1, 1).scaleSelf(300);

float currScale=1;

TriangleMesh mesh;

// used to store mesh on GPU
GLModel surf;

void setup() {
  size(1024, 768, GLConstants.GLGRAPHICS);
  VolumetricSpace volume=new VolumetricSpaceArray(SCALE, DIMX, DIMY, DIMZ);
  // fill volume with noise
  for (int z=0; z<DIMZ; z++) {
    for (int y=0; y<DIMY; y++) {
      for (int x=0; x<DIMX; x++) {
        volume.setVoxelAt(x, y, z, (float)SimplexNoise.noise(x*NS, y*NS, z*NS)*0.5);
      }
    }
  }
  volume.closeSides();
  // store in IsoSurface and compute surface mesh for the given threshold value
  mesh=new TriangleMesh("iso"); 
  IsoSurface surface=new HashIsoSurface(volume, 0.333333);
  surface.computeSurfaceMesh(mesh, ISO_THRESHOLD);
  
  // update lighting information
  mesh.computeVertexNormals();
  // get flattened vertex array
  float[] verts=mesh.getMeshAsVertexArray();
  // in the array each vertex has 4 entries (XYZ + 1 spacing)
  int numV=verts.length/4;  
  float[] norms=mesh.getVertexNormalsAsArray();
  
  surf = new GLModel(this, numV, TRIANGLES, GLModel.STATIC);
  surf.beginUpdateVertices();
  for (int i = 0; i < numV; i++) surf.updateVertex(i, verts[4 * i], verts[4 * i + 1], verts[4 * i + 2]);
  surf.endUpdateVertices(); 
    
  surf.initNormals();
  surf.beginUpdateNormals();
  for (int i = 0; i < numV; i++) surf.updateNormal(i, norms[4 * i], norms[4 * i + 1], norms[4 * i + 2]);
  surf.endUpdateNormals();  

  // Setting the color of all vertices to green, but not used, see comments in the draw() method.
  surf.initColors();
  surf.beginUpdateColors();
  for (int i = 0; i < numV; i++) surf.updateColor(i, 0, 255, 0, 225);
  surf.endUpdateColors(); 
  
  // Setting model shininess.
  surf.setShininess(32);
}

void draw() {
  background(128);
  translate(width/2, height/2, 0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  scale(currScale);

  // need to switch to pure OpenGL mode first
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
    
  renderer.gl.glEnable(GL.GL_LIGHTING);
  
  // Disabling color tracking, so the lighting is determined using the colors
  // set only with glMaterialfv()
  renderer.gl.glDisable(GL.GL_COLOR_MATERIAL);
  
  // Enabling color tracking for the specular component, this means that the 
  // specular component to calculate lighting will obtained from the colors 
  // of the model (in this case, pure green).
  // This tutorial is quite good to clarify issues regarding lighting in OpenGL:
  // http://www.sjbaker.org/steve/omniv/opengl_lighting.html
  //renderer.gl.glEnable(GL.GL_COLOR_MATERIAL);
  //renderer.gl.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR);  
  
  renderer.gl.glEnable(GL.GL_LIGHT0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, new float[]{0.1,0.1,0.1,1}, 0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[]{1,0,0,1}, 0);  
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, new float[] {-1000, 600, 2000, 0 }, 0);
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_SPECULAR, new float[] { 1, 1, 1, 1 }, 0); 
 
  renderer.model(surf);
  
  // back to processing
  renderer.endGL();
}

void keyPressed() {
  if (key=='-') currScale=max(currScale-0.1, 0.5);
  if (key=='=') currScale=min(currScale+0.1, 10);
  if (key=='s') {
    // save mesh as STL or OBJ file
    mesh.saveAsSTL(sketchPath("noise.stl"));
  }
}

