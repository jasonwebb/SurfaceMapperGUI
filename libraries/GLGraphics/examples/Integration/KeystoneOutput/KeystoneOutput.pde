/**
 * This is example shows the combination of GLGraphics with the Keystone
 * library to adjust an offscreen surface to compensate for keystone
 * deformations. The offscreen surface is shown in a second texture
 * window that can be directed to a projector.
 *
 * The Keystone library is available here:
 * http://keystonep5.sourceforge.net/ 
 */

import processing.opengl.*;
import codeanticode.glgraphics.*;

import deadpixel.keystone.*;

// this object is key! you can use it to render fully accelerated
// OpenGL scenes directly to a texture
GLGraphicsOffScreen canvas;
GLGraphicsOffScreen canvasKeystoned;

Keystone ks;
CornerPinSurface surface;
GLTextureWindow output;

boolean calibrating = false;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);

  canvas = new GLGraphicsOffScreen(this, width, height);
  canvasKeystoned = new GLGraphicsOffScreen(this, width, height);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  
  // The arguments for the GLTextureWindow constructor are:
  // * title string
  // * initial x of left upper corner
  // * initial y of left upper corner
  // * initial width
  // * initial height
  // * visible/not visible
  // * with/out borders
  // * resizable/fixed size
  output = new GLTextureWindow(this, "Output", 100, 100, 800, 600, true, true, true);
  
  // The texture of the keystoned canvas is attached to the output window. 
  // Anything is drawn on this canvas will be seen in the output window.
  output.setTexture(canvasKeystoned.getTexture());
}

void draw() {
  float x, y;
  if (calibrating) {
    PVector mouse = surface.getTransformedMouse();
    x = mouse.x;
    y = mouse.y;
  } else {
    x = mouseX;
    y = mouseY;
  }
  
  // first draw the sketch offscreen
  canvas.beginDraw();
  canvas.background(50);
  canvas.lights();
  canvas.fill(255);
  canvas.translate(x, y);
  canvas.rotateX(millis()/200.0);
  canvas.rotateY(millis()/400.0);
  canvas.box(100);
  canvas.endDraw();

  // Render the keystoned surface on the main window only
  // when we are calibrating.
  background(0);
  if (calibrating) {
    surface.render(canvas.getTexture());
  } else {
    image(canvas.getTexture(), 0, 0);
  }  
  
  // The ready() condition is not really necessary, but it helps
  // to minimize "GLException: wglShareLists(0x20000, 0x20001)" 
  // errors, specially under windows 7.
  if (output.ready()) {  
    // Render the keystoned surface on the output window.
    canvasKeystoned.beginDraw();
    canvasKeystoned.background(0);
    surface.render(canvasKeystoned, canvas.getTexture());
    canvasKeystoned.endDraw();  
  }
}

// Controls for the Keystone object
void keyPressed() {
  
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // & moved
    ks.toggleCalibration();
    calibrating = !calibrating;
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}
