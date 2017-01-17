// Applying a filter to a movie (it also uses the gsvideo library).
// By Andres Colubri
// The gsvideo library is available here:
// http://gsvideo.sourceforge.net/

import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

GSMovie movie;
GLTexture texSrc, texFiltered;

GLTextureFilter blur, emboss, edges, poster, pixelate, invert;
GLTextureFilter currentFilter;
String filterStr;

PFont font;

void setup() {
  size(640, 480, GLConstants.GLGRAPHICS);
   
  texSrc = new GLTexture(this);   
  texFiltered = new GLTexture(this);    
   
  movie = new GSMovie(this, "station.mov");
  movie.setPixelDest(texSrc);
  movie.loop();
   
  blur = new GLTextureFilter(this, "Blur.xml");
  emboss = new GLTextureFilter(this, "Emboss.xml");
  edges = new GLTextureFilter(this, "Edges.xml");
  poster = new GLTextureFilter(this, "Posterize.xml");
  pixelate = new GLTextureFilter(this, "Pixelate.xml");
  invert = new GLTextureFilter(this, "Invert.xml");
    
  font = loadFont("EstrangeloEdessa-24.vlw");
  textFont(font, 24);      
    
  currentFilter = edges;
  filterStr = "edges";
}

void movieEvent(GSMovie movie) {
  movie.read();
}

void draw() {
  if (movie.ready()) {
    if (texSrc.putPixelsIntoTexture()) {

      // Calculating height to keep aspect ratio.      
      float h = width * texSrc.height / texSrc.width;
      float b = 0.5 * (height - h);

      if (currentFilter == null) image(texSrc, 0, b, width, h);
      else {
        if (currentFilter == pixelate) {
          currentFilter.setParameterValue("pixel_size", map(mouseX, 0, width, 1, 30)); 
        }
            
        if (currentFilter == invert) {
          float x = map(mouseX, 0, width, 0, texSrc.width);
          float y = map(mouseY, 0, height, 0, texSrc.height);
          currentFilter.setParameterValue("mpos", new float[]{x, y});
          currentFilter.setParameterValue("mdist", 50.0);              
        }
            
        texSrc.filter(currentFilter, texFiltered);
        image(texFiltered, 0, b, width, h);            
      }
        
      fill(50, 200, 50);
      if (currentFilter == null) text("Selected filter: none (1-6 to change, 0 to disable)", 10, 30);
      else text("Selected filter: " + currentFilter.getName() + " (1-6 to change, 0 to disable)", 10, 30); 
    }     
  }
}

void keyPressed() {
  if ((key == '1')) { currentFilter = blur; }
  else if ((key == '2')) { currentFilter = emboss; }
  else if ((key == '3')) { currentFilter = edges; }  
  else if ((key == '4')) { currentFilter = poster; }
  else if ((key == '5')) { currentFilter = pixelate; }  
  else if ((key == '6')) { currentFilter = invert; }
  else if ((key == '0')) { currentFilter = null; }
}