// A simple particle system example with GLGraphics
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;
import java.nio.FloatBuffer;

GLModel sys;
GLTexture tex;

int npartTotal = 1000;
int npartPerFrame = 10;
float speed = 1.0;
float gravity = 0.05;

int partLifetime;

PVector velocities[];
int lifetimes[];

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);  
    
  partLifetime = npartTotal / npartPerFrame;
    
  sys = new GLModel(this, npartTotal, GLModel.POINT_SPRITES, GLModel.DYNAMIC);
  initColors();
  initPositions();
  initSprites();

  initVelocities();
  initLifetimes();  
}

void draw() {    
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();  
    
  background(0);

  updatePositions();
  updateColors();
  updateLifetimes();
    
  //translate(mouseX, mouseY, 0);   
    
  // Disabling depth masking to properly render semitransparent
  // particles without need of depth-sorting them.    
  renderer.setDepthMask(false);
  sys.render();
  renderer.setDepthMask(true);
    
  renderer.endGL();
}

void initSprites() {
   tex = new GLTexture(this, "particle.png");    
   float pmax = sys.getMaxPointSize();
   println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   
   sys.initTextures(1);
   sys.setTexture(0, tex);  
   // Setting the maximum sprite to the 90% of the maximum point size.
   sys.setMaxSpriteSize(0.9 * pmax);
   // Setting the distance attenuation function so that the sprite size
   // is 20 when the distance to the camera is 400.
   sys.setSpriteSize(20, 400);
   sys.setBlendMode(BLEND);  
}

void initColors() {
  sys.initColors();
  sys.setColors(0, 0);
}

void initPositions() {
  sys.beginUpdateVertices();
  FloatBuffer vbuf = sys.vertices;
  float pos[] = { 0, 0, 0, 0 };
  for (int n = 0; n < sys.getSize(); n++) {
    vbuf.position(4 * n);
    vbuf.get(pos, 0, 3);  
    
    pos[0] = 0;
    pos[1] = 0;
    pos[2] = 0;
    pos[3] = 1; // The W coordinate must be 1.
    
    vbuf.position(4 * n);
    vbuf.put(pos, 0, 4);
  }  
  sys.endUpdateVertices();  
}

void initVelocities() {
  velocities = new PVector[npartTotal];
  for (int n = 0; n < velocities.length; n++) {
    velocities[n] = new PVector();
  }  
}

void initLifetimes() {
  // Initialzing particles with negative lifetimes so they are added
  // progresively into the scene during the first frames of the program  
  lifetimes = new int[npartTotal];
  int t = -1;
  for (int n = 0; n < lifetimes.length; n++) {    
    if (n % npartPerFrame == 0) {
      t++;
    }
    lifetimes[n] = -t; 
  }  
}

void updatePositions() {
  sys.beginUpdateVertices();
  FloatBuffer vbuf = sys.vertices;
  float pos[] = { 0, 0, 0 };
  for (int n = 0; n < sys.getSize(); n++) {
    vbuf.position(4 * n);
    vbuf.get(pos, 0, 3);  
  
    if (lifetimes[n] == 0) {
      // Respawn dead particle:
      pos[0] = mouseX; 
      pos[1] = mouseY;
      pos[2] = 0;
      float a = random(0, TWO_PI);
      float s = random(0.5 * speed, speed);
      velocities[n].x = s * cos(a);
      velocities[n].y = s * sin(a);
      velocities[n].z = 0;  
    } else {
      // Update moving particle.
      pos[0] += velocities[n].x; 
      pos[1] += velocities[n].y;
      pos[2] += velocities[n].z;
      // Updating velocity.
      velocities[n].y += gravity;      
    }
  
    vbuf.position(4 * n);
    vbuf.put(pos, 0, 3);
  }
  vbuf.rewind();
  sys.endUpdateVertices();  
}

void updateColors() {
  sys.beginUpdateColors();
  FloatBuffer cbuf = sys.colors;
  float col[] = { 0, 0, 0, 0 };
  for (int n = 0; n < sys.getSize(); n++) {
    if (0 <= lifetimes[n]) {
      // Interpolating between alpha 1 to 0:
      float a = 1.0 - float(lifetimes[n]) / partLifetime;
    
      col[0] = 1.0;
      col[1] = 1.0;
      col[2] = 1.0;
      col[3] = a;
      
      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }
  }
  cbuf.rewind();
  sys.endUpdateColors();
}

void updateLifetimes() {
  for (int n = 0; n < sys.getSize(); n++) {
    lifetimes[n]++;
    if (lifetimes[n] == partLifetime) {
      lifetimes[n] = 0;
    }    
  }
}  

