//
// Conway's Game of Life as GPU image process
// Set framerate to 30 or it's too fast to see!
// (C)2010 Kevin Bjorke, http://www.botzilla.com/
// Free to copy with attribution
//
// requires Andres Colubri's "GLGraphics" library
//

// func shared by all refresh options - all refresh methods fill tex0 with cells and reset most display attributes
//
void launch_it(int minutes,float fromX,float fromY,String Name)
{
  autoResetFrame = frameCount+30*60*minutes; // based on 30fps, which actually varies between computers
  // set whatever needs wrapping up to complete initialization
  tex0.updatePixels();
  tex0.loadTexture();
  tex0.render(0,0,width,height);
  TZero = true;
  Zoomer.reset();
  Zoomer.ZoomTarget=2.0;
  Zoomer.CenterTarget.set(0.5+0.5*(fromX-0.5),0.5+0.5*(fromY-0.5),0.0);
  Zoomer.setZoom(0.5);
  Caption.set(Name,3);
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

// we have three initializers: random, radial, and gliders, plus two engine samples and a randomizer

void random_start() // fill screen randomly
{
  int k=0;
  float noiseScale = 0.19;
  tex0.loadPixels();
  for (int i=0; i<tex0.height; i++) {
    float fi = (i+frameCount)*noiseScale;
    for (int j=0; j<tex0.width; j++) {
      float ns = noise(fi,(j)*noiseScale);
      tex0.pixels[k] = (ns>0.65) ? 0xFFFFFFFF : 0xFF000000;
      k++;
    }
  }
  launch_it(5,0.5,0.5,"? random");
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void radial_start() // radiate density around the mouse
{
  int k=0;
  float noiseScale = 6.7;
  tex0.loadPixels();
  float far = tex0.width;
  float xCtr = (frameCount < 2) ? width/2.0 : mouseX;
  float yCtr = (frameCount < 2) ? height/2.0 : mouseY;
  for (int i=0; i<tex0.height; i++) {
    float fi = (i+frameCount)*noiseScale;
    float dx = i-yCtr;
    for (int j=0; j<tex0.width; j++) {
      float dy = j-xCtr;
      float d = sqrt(dx*dx+dy*dy)/far;
      d = pow(d,0.3);
      float ns = noise(fi,j*noiseScale);
      tex0.pixels[k] = (ns>d) ? 0xFFFFFFFF : 0xFF000000;
      k++;
    }
  }
  launch_it(6,(xCtr/tex0.width),(yCtr/tex0.height),"radiating");
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

////////// these functions let us create SPECIFIC patterns //////

void clear_tex0()
{
  int k=0;
  tex0.loadPixels();
  for (int i=0; i<tex0.height; i++) {
    for (int j=0; j<tex0.width; j++) {
      tex0.pixels[k] = 0xFF000000;
      k++;
    }
  }
}

void set_cell(int px,int py)
{
  if (px>= tex0.width) return;
  if (py>= tex0.height) return;
  if (px<0) return;
  if (py<0) return;
  int k = px+py*tex0.width;
  tex0.pixels[k] = 0xFFFFFFFF;
}

void glider(int px, int py) // classic life glider
{
  int xs = (px>mouseX)?-1:1;
  int ys = (py>mouseY)?-1:1;
  set_cell(px,py+2*ys);
  set_cell(px+xs,py+2*ys);
  set_cell(px+xs*2,py+2*ys);
  set_cell(px+xs*2,py+ys);
  set_cell(px+xs,py);
}

void ship(int px, int py) // classic "LWSS"
{
  int xs = (px>mouseX)?-1:1;
  int ys = (py>mouseY)?-1:1;
  set_cell(px,py+4*ys);
  set_cell(px+xs,py+4*ys);
  set_cell(px+xs*2,py+4*ys);
  set_cell(px+xs*3,py+4*ys);
  set_cell(px+xs*3,py+3*ys);
  set_cell(px+xs*3,py+2*ys);
  set_cell(px+xs*2,py+ys);
  set_cell(px-xs,py+3*ys);
  set_cell(px-xs,py+ys);
}

void gliders_start() // create a fleet of ships aimed roughly at the mouse
{
  clear_tex0();
  for (int i=0; i<10*(tex0.width/32); i++) {
      int s = (int)floor(random(tex0.width));
      int t = (int)floor(random(tex0.height));
      if (random(1.0)>0.3) {
        glider(s,t);
      } else {
        ship(s,t);
      }
  }
  launch_it(5,0.5,0.5,"galactic fleet");
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void engine_start()    // a dual engine -- all in one line!
{
  clear_tex0();
  int px = (frameCount < 2) ? width/2 : mouseX;
  int py = (frameCount < 2) ? height/2 : mouseY;
  px = (px<30)?30:((px>tex0.width-80)?tex0.width-80:px);
  py = (py<30)?30:((py>tex0.height-50)?tex0.height-50:py);
  int i;
  for (i=0; i<8; i++) set_cell(px++,py);
  px++;
  for (i=0; i<5; i++) set_cell(px++,py);
  px+=3;
  for (i=0; i<3; i++) set_cell(px++,py);
  px+=6;
  for (i=0; i<7; i++) set_cell(px++,py);
  px++;
  for (i=0; i<5; i++) set_cell(px++,py);
  launch_it(3,0.5,0.5,"engines");
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void single_engine_start() // a single engine
{
  clear_tex0();
  int px = (frameCount < 2) ? width/2 : mouseX;
  int py = (frameCount < 2) ? height/2 : mouseY;
  px = (px<60)?60:((px>tex0.width-20)?tex0.width-20:px);
  py = (py<40)?40:((py>tex0.height-70)?tex0.height-70:py);
  set_cell(px-4,py-2);
  set_cell(px-2,py-2);
  set_cell(px-2,py-1);
  set_cell(px,py);
  set_cell(px,py+1);
  set_cell(px,py+2);
  set_cell(px+2,py+1);
  set_cell(px+2,py+2);
  set_cell(px+2,py+3);
  set_cell(px+3,py+2);
  launch_it(3,0.5,0.5,"single engine");
}

//////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

void pick_a_start() // randomly select one of the above
{
  float e = random(8.0);
  if (e>7.0) {  single_engine_start();
  } else if (e>6.0) {  engine_start();
  } else if (e>4.0) { random_start();
  } else if (e>2.0) {  radial_start();
  } else {  gliders_start(); }
}

///////////////////// eof //
