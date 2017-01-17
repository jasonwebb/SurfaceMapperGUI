//
// Conway's Game of Life as GPU image process
// Set framerate to 30 or it's too fast to see!
// (C)2010 Kevin Bjorke, http://www.botzilla.com/
// Free to copy with attribution
//
// requires Andres Colubri's "GLGraphics" library
//

class CaptionLine {
  int countDown; // timer for text displays
  String caption;
  CaptionLine() {
    caption = "";
    countDown = frameCount;
  }
  void set(String what,int howLong)
  {
    caption = what;
    countDown = 30*howLong; // nominal assumption: 30fps
  }
  void draw() {
   if (countDown > 0) {
     int gr = min(255,countDown*8);
     fill(20,20,50,3*gr/4);
     noStroke();
     quad(30,height-50,30,height-80,width,height-80,width,height-50);
     fill(200,200,200,gr);
     text(caption,40,height-60); // assuming a 20-pixel font here....
     countDown--;
   }
  }
}

/// eof //
