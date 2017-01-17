//
// Conway's Game of Life as GPU image process
// Set framerate to 30 or it's too fast to see!
// (C)2010 Kevin Bjorke, http://www.botzilla.com/
// Free to copy with attribution
//
// requires Andres Colubri's "GLGraphics" library
//

class ZoomControl {
  float Zoom;
  PVector Center;
  float ZoomTarget;
  PVector CenterTarget;
  float ZoomStep;
  PVector CenterStep;
  int count;
  boolean userHelp;
  GLTextureFilter zoomFilter;
  ZoomControl(processing.core.PApplet parent) {
    Zoom = ZoomTarget = 1.0;
    ZoomStep = 0.0;
    Center = new PVector(0.5,0.5);
    CenterTarget = new PVector(0.5,0.5);
    CenterStep = new PVector(0.0,0.0);
    count = 0;
    userHelp = true;
    zoomFilter = new GLTextureFilter(parent, "zoomFS.xml");
  }
  void reset() {
    Zoom = 1.0;
    ZoomTarget = 1.0;
    ZoomStep = 0.0;
    Center.set(0.5,0.5,0.0); // z ignored. we COULD put the zoom there...
    CenterTarget.set(Center);
    CenterStep.set(0.0,0.0,0.0);
    count = 0;
  }
  void advance() {
    if (count<=0) {
      jumpToTargets();
    } else {
      Zoom += ZoomStep;
      if (Zoom < 1.0) Zoom = 1.0;
      Center.add(CenterStep);
      float d = (Zoom-1.0)/Zoom; // make sure we are always on-screen
      float margin = 0.5 - 0.5*d;
      Center.x = max(Center.x,margin);
      Center.y = max(Center.y,margin);
      margin = 0.5 + 0.5*d;
      Center.x = min(Center.x,margin);
      Center.y = min(Center.y,margin);
      count--;
      //debug();
    }
    zoomFilter.setParameterValue("Center", new float[]{Zoomer.Center.x,Zoomer.Center.y});
    zoomFilter.setParameterValue("Scale", Zoomer.Zoom);
  }
  void jumpToTargets() {
    if (ZoomTarget < 1.0) {
      ZoomTarget = 1.0;
      CenterTarget.set(0.5,0.5,0.0);
    }
    Zoom = ZoomTarget;
    Center.set(CenterTarget);
    ZoomStep = 0.0;
    CenterStep.set(0.0,0.0,0.0);
    count = 0;
  }
  void setZoom(float factor)
  {
     if (Zoom <= 1.0) {
       if (userHelp) Caption.set("arrow keys or click to scroll",2);
       // note we DON'T reset userHelp
     }
    jumpToTargets();
    float t = Zoom*factor;
    if (t < 1.0) {
      reset();
    } else if (t > 16.0) {
      t = 16.0;
      if (userHelp) Caption.set("[ - keys or right click to zoom out",3);
      userHelp = false;
    }
    ZoomTarget = t;
    safeCenter();
  }
  void safeCenter() { // this also launches zoom animation
    // make sure we're aiming at a location taht's "legal" -- don't stray off the texture
    float d = (ZoomTarget-1.0)/ZoomTarget;
    float margin = 0.5 - 0.5*d;
    CenterTarget.x = max(CenterTarget.x,margin);
    CenterTarget.y = max(CenterTarget.y,margin);
    margin = 0.5 + 0.5*d;
    CenterTarget.x = min(CenterTarget.x,margin);
    CenterTarget.y = min(CenterTarget.y,margin);
    ZoomStep = (ZoomTarget-Zoom) * 0.05;
    CenterStep.set(CenterTarget);
    CenterStep.sub(Center);
    CenterStep.mult(0.05);
    count = 20;
    //debug();
  }
  void setCenter(float x,float y)
  {
    jumpToTargets();
    CenterTarget.set(x,y,0);
    safeCenter();
  }
  void move(float x, float y) {
    setCenter(Center.x+x,Center.y+y); // to-do -- set safe center based on zoom
  }
  void moveZoom(float x, float y, float factor) {
     if (Zoom <= 1.0) {
       if (userHelp) Caption.set("arrow keys or click to scroll",2);
       // note we DON'T reset userHelp
     }
    jumpToTargets();
    CenterTarget.set(Center.x+x,Center.y+y,0);
    ZoomTarget = Zoom*factor;
    if (ZoomTarget>16.0) {
      ZoomTarget=16.0;
      if (userHelp) Caption.set("[ - keys or right click to zoom out",3);
      userHelp = false;
    }
    safeCenter();
  }
  void debug() {
    print ("Zoom "+Zoom+", Center ["+Center.x+","+Center.y+"]\n");
    print ("Targ "+ZoomTarget+", Center ["+CenterTarget.x+","+CenterTarget.y+"]\n");
    print ("Step "+ZoomStep+", Center ["+CenterStep.x+","+CenterStep.y+"] ("+count+")\n");
  }
}

//////////////////////////////////////// eof ////
