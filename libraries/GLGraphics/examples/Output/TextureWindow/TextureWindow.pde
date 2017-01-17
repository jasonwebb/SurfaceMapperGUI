// Texture window example. The texture window is used 
// to show a single GLTexture. Press a key to hide/show the 
// texture window. Drag the mouse on the primary window to 
// control the parameters of the particle swarm.
//  
// By Andres Colubri. 
// Swarm code by Andor Salga: 
// http://matrix.senecac.on.ca/~asalga/pjswebide/index.php
//
// An application of this technique would be an situation where 
// the main processing window is show to user interface, while the 
// texture window just outputs the resulting graphics (to a secondary
// screen or a projector, for example).

import processing.opengl.*;
import codeanticode.glgraphics.*;
import com.sun.opengl.util.FPSAnimator;

// Swarm parameters:
float SIZE = 5;
float SPEED = 1;

GLGraphicsOffScreen canvas;
GLTextureWindow texWin;

void setup() {
  size(300, 300, GLConstants.GLGRAPHICS);
  frameRate(60);  
  
  // Creating an ofscreen canvas to do some drawing on it.
  canvas = new GLGraphicsOffScreen(this, 400, 400);  

  // The window is located at (0, 0) and has a size of (400, 400).
  // By default, it doesn't borders and it is visible.
  texWin = new GLTextureWindow(this, 0, 0, 400, 400);
  
  // Additional arguments can be provided in the constructor to
  // control the appearance the window:
  // * title string
  // * visible/not visible (first boolean argument)
  // * with/out borders (second boolean argument)
  // * resizable/fixed size (third boolean argument)  
  //texWin = new GLTextureWindow(this, "Output", 0, 0, 400, 400, true, true, true);
   
  // Attaching the offscreen texture to the window.
  texWin.setTexture(canvas.getTexture());
    
  // We can set a frame rate for the texture window,
  // different from the main sketch window.  
  //texWin.frameRate(30);
  
  /*
  // If setting the override property of the texture window to 
  // false, then it won't be drawn automatically. In this case,
  // it can be manually updated after the main draw is finished
  // using the post event (uncomment the post() function at the
  // bottom of this example):*/
  //texWin.setOverride(true);
  //registerPost(this);
}
  
boolean setAnimator = false;  
void draw() {
  background(255);
  
  line(0, mouseY, width, mouseY);
  line(mouseX, 0, mouseX, height);
  
  SIZE = map(mouseX, 0, width, 5, 10);
  SPEED = map(mouseY, 0, height, 1, 3);

  // The ready() condition is not really necessary, but it helps
  // to minimize "GLException: wglShareLists(0x20000, 0x20001)" 
  // errors, specially under windows 7.
  if (texWin.ready()) {
    canvas.beginDraw();
    canvas.noStroke();
    canvas.fill(0, 5);  
    canvas.rect(0, 0, canvas.width, canvas.height);
    canvas.noFill();
    canvas.stroke(255, 0, 0, 10);  
    for (int i = 1; i < 50; i++){
      canvas.strokeWeight(SIZE);
      canvas.pushMatrix();
      canvas.translate(canvas.width/2.0f, canvas.height/2.0f);
      canvas.rotate((i*50) + SPEED * frameCount/100.0f/ (i*2)) ;
      canvas.translate(cos((i*60) + SPEED * frameCount/50.0f ) * (i + 10.0f), 
                       sin((i*50) + SPEED * frameCount/80.0f) * ((i*1) + 30.0f));
      canvas.point(i, i);
      canvas.popMatrix();
    }
    canvas.endDraw();
  }
  
  println(frameRate + " " + texWin.frameRate);
}

void keyPressed() {
  if (texWin.isVisible()) texWin.hide();
  else texWin.show();
}

void post() {
  texWin.render();  
}