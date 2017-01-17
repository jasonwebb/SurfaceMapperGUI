import codeanticode.gsvideo.*;
import ixagon.SurfaceMapper.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;

/***********************************************************
* EXAMPLE PROVIDED WITH SURFACEMAPPER LIBRARY DEVELOPED BY *
* IXAGON AB.                                               *
* This example shows you how to setup the library and      *
* and display a movie to multiple surfaces.                *
* Check the keyPressed method to see how to access         *
* different settings                                       *
***********************************************************/

GLTexture tex;
GLTexture img;
GLTexture name;
GLGraphicsOffScreen glos;
SurfaceMapper sm;
GSMovie movie;

void setup(){
  size(1600,1050, GLConstants.GLGRAPHICS);
  glos = new GLGraphicsOffScreen(this, width, height, false);
  tex = new GLTexture(this);
  img = new GLTexture(this, "img.jpg");
  name = new GLTexture(this, "name.jpg");
  //Create new instance of SurfaceMapper
  sm = new SurfaceMapper(this, width, height);
  //Creates one surface with subdivision 3, at center of screen
  sm.createQuadSurface(3,width/2,height/2);
  //set the name of the surface
  sm.getSurfaces().get(0).setSurfaceName("name");
  movie = new GSMovie(this, "streets.mp4");
  movie.setPixelDest(tex);  
  movie.loop();
}

void draw(){
  background(0);
  glos.beginDraw();
  glos.clear(0);
  glos.hint(ENABLE_DEPTH_TEST);
  glos.endDraw();
  //get movie frame
  if(tex.putPixelsIntoTexture())
  //Updates the shaking of the surfaces in render mode
  sm.shake();
  //render all surfaces in calibration mode
  if(sm.getMode() == sm.MODE_CALIBRATE)sm.render(glos);
  //render all surfaces in render mode
  if(sm.getMode() == sm.MODE_RENDER){
    for(SuperSurface ss : sm.getSurfaces()){
      //render this surface to GLOS, use name as texture if the surfaces name is 'name'
      if(ss.getSurfaceName().equals("name")){
        ss.render(glos, name);
      }else{
        //use the movie as texture is the surfaces id is an even number, use the image if it's odd.
        if(ss.getId() % 2 == 0) ss.render(glos,tex);
        else ss.render(glos, img);
      }
    }
  }
  //display the GLOS to screen
  image(glos.getTexture(),0,0,width,height);
}

void movieEvent(GSMovie movie) {
  movie.read();
}

void keyPressed(){
  //create a new QUAD surface at mouse pos
  if(key == 'a')sm.createQuadSurface(3,mouseX,mouseY);
  //create new BEZIER surface at mouse pos
  if(key == 'z')sm.createBezierSurface(3,mouseX,mouseY);
  //switch between calibration and render mode
  if(key == 'c')sm.toggleCalibration();
  //increase subdivision of surface
  if(key == 'p'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.increaseResolution();
    }
  }
  //decrease subdivision of surface
  if(key == 'o'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.decreaseResolution();
    }
  }
  //save layout to xml
  if(key == 's')sm.save("bla.xml");
  //load layout from xml
  if(key == 'l')sm.load("bla.xml");
  //rotate how the texture is mapped in the QUAD (clockwise)
  if(key == 'j'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.rotateCornerPoints(0);
    }
  }
  //rotate how the texture is mapped in the QUAD (counter clockwise)
  if(key == 'k'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.rotateCornerPoints(1);
    }
  }
  //increase the horizontal force on a BEZIER surface
  if(key == 't'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.increaseHorizontalForce();
    }
  }
  //decrease the horizontal force on a BEZIER surface  
  if(key == 'y'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.decreaseHorizontalForce();
    }
  }
  //increase the vertical force on a BEZIER surface  
  if(key == 'g'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.increaseVerticalForce();
    }
  }
  //decrease the vertical force on a BEZIER surface  
  if(key == 'h'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.decreaseVerticalForce();
    }
  }
      //shake all surfaces with strength (max z displacement), speed, and duration (0 - 1000)
  if(key == 'q'){
    sm.setShakeAll(50, 850, 20);
  }
    //shake all surfaces with strength (max z displacement), speed, and duration (0 - 1000)
  if(key == 'w'){
    sm.setShakeAll(75, 650, 130);
  }
    //shake all surfaces with strength (max z displacement), speed, and duration (0 - 1000)
  if(key == 'e'){
    sm.setShakeAll(100, 450, 300);
  }
    //shake only the selected surfaces with strength (max z displacement), speed, and duration (0 - 1000)
  if(key == 'r'){
    for(SuperSurface ss : sm.getSelectedSurfaces()){
      ss.setShake(200,400,50);
    }
  }
}
