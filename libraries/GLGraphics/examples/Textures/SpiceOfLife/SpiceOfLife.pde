/** Conway's Game of Life as GPU image process
 * Set framerate to 30 or it's too fast to see!
 * 
 * (C)2010 Kevin Bjorke, http://www.botzilla.com/
 * Free to copy with attribution
 *
 * press keys and mouse buttons to do a few things
 *
 * requires Andres Colubri's "GLGraphics" library
*/

import processing.opengl.*;
import codeanticode.glgraphics.*;

// modes
static final boolean video = false;
static final boolean forWeb = true;

// GLGraphics objects
GLTextureFilter advanceFilter, copyFilter;
GLTexture tex0, tex1;

int autoResetFrame; // when the auto-reset will kick in
boolean userNeedsHelp;

boolean TZero; // used for buffer flipping
boolean halted;
float desiredFrameRate; // fps (if you can hit it)

PFont font;
CaptionLine Caption;
ZoomControl Zoomer;

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void setup()
{
   int wd = 512;
   int ht = 512;
   if (forWeb) {
     wd = ht = 512; // smaller for web pages
   } else if (video) {
     wd = 854;
     ht = 480; // 16:9 video 480p
   } else {
     wd = (screen.width>1024)?1024:512;
     ht = (screen.height>512)?512:256; // power-of-two sizes prefered
   }
   size(wd, ht, GLConstants.GLGRAPHICS);
   desiredFrameRate = 240; // wishful thinking? not on some GPUs....
   halted = false;
   userNeedsHelp = true;
   frameRate(desiredFrameRate); // slow down to 30 or you can't even see blinkers etc on many displays
   font = loadFont("EstrangeloEdessa-24.vlw");
   textFont(font, 20);
   Caption = new CaptionLine();
   Zoomer = new ZoomControl(this);
   // configure our two texture targets to suppress hardware filtering
   GLTextureParameters gp = new GLTextureParameters();
   gp.minFilter = GLConstants.NEAREST_SAMPLING;
   gp.magFilter = GLConstants.NEAREST_SAMPLING;
   tex0 = new GLTexture(this, width, height, gp);    
   tex1 = new GLTexture(this, tex0.width, tex0.height,gp);
   copyFilter = new GLTextureFilter(this, "copyFS.xml"); // just copes one texture to another
   advanceFilter = new GLTextureFilter(this, "advanceFS.xml"); // does the game-of-life stuff
   advanceFilter.setParameterValue("StepSize", new float[]{(1.0/tex0.width),(1.0/tex0.height)}); // texel width
   if (video) random_start(); else pick_a_start(); // initialize the life buffer
   Caption.set("SpiceOfLife - Kevin Bjorke, botzilla.com, 2010",12);
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void draw()
{
   // background(0); // redundant
   Zoomer.advance();
   //
   // using "TZero" this way may seem redundant but I seem to get the best frame rate this way
   GLTexture prevTex, newTex;
   if (TZero) {
     prevTex = tex0;
     newTex = tex1;
   } else {
     prevTex = tex1;
     newTex = tex0;
   }
   if (halted) {
     prevTex.filter(copyFilter, newTex); // just copy, don't advance
   } else {
     prevTex.filter(advanceFilter, newTex); // advance cells one step
   }
   if (Zoomer.Zoom <= 1.0) {
     newTex.render(0,0,width,height);
   } else {
     newTex.filter(Zoomer.zoomFilter, prevTex); // we're going to overwrite "prevTex" on the next frame anyway
     prevTex.render(0,0,width,height);
   }
   TZero = (!TZero);
   if (frameCount > autoResetFrame) {
      pick_a_start();
   }
   if (Zoomer.Zoom>1.0) {
     // draw center reticule to make mouse moves easier
     strokeWeight(1);
     stroke(80);
     int cx = width/2;
     int cy = height/2;
     line(cx-10,cy,cx+10,cy);
     line(cx,cy-10,cx,cy+10);
   }
   Caption.draw();
   if (video) { saveFrame(); }
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void mousePressed() {
  if (mouseButton == LEFT) {
    if (Zoomer.Zoom <= 1.0) {
      Caption.set("] or + keys will zoom to cursor",2); // can't move if zoomed all the way out!
    } else {
      float x = ((mouseX-(width/2.0))/width)/Zoomer.Zoom;
      float y = ((mouseY-(height/2.0))/height)/Zoomer.Zoom;
      Zoomer.move(x,y); // recenter view on x,y
    }
  } else if (mouseButton == RIGHT) {
    if (Zoomer.Zoom <= 1.0) {
      Caption.set("space g r e s ? keys to refresh",4); // a hint
    } else {
      Caption.set("[ ] - + keys to zoom",2); // reminder
      Zoomer.moveZoom(0.5,0.5,1.0/Zoomer.Zoom); // zoom ALL the way out
    }
  } else {
    desiredFrameRate = 240.0;
    frameRate(desiredFrameRate);
    Caption.set("z x tab keys to change speed",3); // hint
  }
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void keyPressed()
{
    if (key == CODED) {
      if (Zoomer.Zoom <= 1.0) {
        Caption.set("Use ] or + to zoom-in first",2);
      } else {
        if (keyCode == UP) {
          Zoomer.move(0.0,-10.0/tex0.height);
        } else if (keyCode == DOWN) {
          Zoomer.move(0.0,10.0/tex0.height);
        } else if (keyCode == LEFT) {
          Zoomer.move(-10.0/tex0.width,0.0);
        } else if (keyCode == RIGHT) {
          Zoomer.move(10.0/tex0.width,0.0);
        }
      }
    } else if ((key==']')||(key=='}')) { // zoom in
      float x = ((mouseX-(width/2.0))/width)/Zoomer.Zoom;
      float y = ((mouseY-(height/2.0))/height)/Zoomer.Zoom;
      Zoomer.moveZoom(x,y,1.1);
    } else if ((key=='[')||(key=='{')) { // zoom out
      Zoomer.setZoom(1.0/1.1);
    } else if ((key == '+')||(key == '=')) { // zoom in more
      float x = ((mouseX-(width/2.0))/width)/Zoomer.Zoom;
      float y = ((mouseY-(height/2.0))/height)/Zoomer.Zoom;
      Zoomer.moveZoom(x,y,2.0);
    } else if ((key == '-')||(key=='_')) { // zoom out more
      Zoomer.setZoom(1.0/2.0);
    } else if ((key == '?')||(key=='/')) { // randomized refrash
      random_start();
    } else if ((key == 'r')||(key=='R')) { // radial refresh
      radial_start();
    } else if ((key == 'g')||(key=='G')) { // gliders and ships refresh
      gliders_start();
    } else if ((key == 'e')||(key=='E')) { // duel engine refresh
      engine_start();
    } else if ((key == 's')||(key=='S')) { // single engine refresh
      single_engine_start();
    } else if ((key=='z')||(key=='Z')) { // slow down
      desiredFrameRate /= 2.0;
      if (desiredFrameRate <= 0.25) desiredFrameRate = 0.25;
      frameRate(desiredFrameRate);
      Caption.set(("frameRate "+desiredFrameRate),3);
    } else if ((key=='x')||(key=='X')) { // desiredFrameRate up
      desiredFrameRate *= 2.0;
      if (desiredFrameRate >= 240.0) desiredFrameRate = 240.0;
      frameRate(desiredFrameRate);
      Caption.set(("frameRate "+desiredFrameRate),3);
    } else if (key == '\t') {         // stop/start
      halted = ! halted;
      if (halted) {
        Caption.set("halted",5);
      } else {
        Caption.set("carry on",2);
      }
    } else if (key == ' ') {          // randomly refresh
      pick_a_start();
    } else if ((key == 'h')||(key=='H')) {          // basic help
      Caption.set("Try space, tab, [, ], arrows, & clicks",5);
      userNeedsHelp = true;
    } else if (userNeedsHelp) {      // any "wrong" key
      userNeedsHelp = false;
      Caption.set("Try space, [, ], arrows, & mouse clicks",5);
    }
}

//////////////////////////////////////
///////////////////////////// eof ////
//////////////////////////////////////

