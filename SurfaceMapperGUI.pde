/********************************************************
 SurfaceMapperGUI
 
 Author: Jason Webb
 Author website: http://jason-webb.info
 Github repo: https://github.com/jasonwebb/SurfaceMapperGUI
    
 FUTURE IMPROVEMENTS
 ===================
 1) Add ability to remove a surface
 
********************************************************/
import ixagon.SurfaceMapper.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;
import controlP5.*;

// ArrayLists for textures, movies and lookups
ArrayList<GLTexture> textures;          // Actual textures
ArrayList<String> textureNames;         // File names of textures
ArrayList<Integer> textureLookup;       // Associates surfaces (ID) to texture index
ArrayList<GSMovie> movies;              // All videos in textures folder
ArrayList<Integer> movieTextureLookup;  // Associates videos to textures

boolean moviesPlaying = false;

// File types that are accepted as textures
String[] imageTypes = {"jpg","jpeg","png","gif","bmp"};
String[] movieTypes = {"mp4","mov","avi"};

// SurfaceMapper variables
GLGraphicsOffScreen glos;
SurfaceMapper sm;
int initialSurfaceResolution = 6;

// Custom GUI objects
ControlP5 gui;
QuadOptionsMenu quadOptions;
BezierOptionsMenu bezierOptions;
ProgramOptionsMenu programOptions;
int mostRecentSurface = 0;

void setup(){
//  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
  size(1024, 768, GLConstants.GLGRAPHICS);
  
  // Setup the ControlP5 GUI
  gui = new ControlP5(this);
  
  // Initialize custom menus
  quadOptions = new QuadOptionsMenu();
  bezierOptions = new BezierOptionsMenu();
  programOptions = new ProgramOptionsMenu();
  
  // Hide the menus
  //quadOptions.hide();
  bezierOptions.hide();
  
  // Update the GUI for the default surface
  quadOptions.setSurfaceName("0");
  bezierOptions.setSurfaceName("0");
  
  // Create an off-screen buffer (makes graphics go fast!)
  glos = new GLGraphicsOffScreen(this, width, height, false);
  
  // Create new instance of SurfaceMapper
  sm = new SurfaceMapper(this, width, height);
  sm.setDisableSelectionTool(true);
  
  // Creates one surface with subdivision 3, at center of screen
  sm.createQuadSurface(initialSurfaceResolution,width/2,height/2);
  
  // Initialize texture ArrayLists
  textures = new ArrayList();
  textureNames = new ArrayList();
  textureLookup = new ArrayList();
  movies = new ArrayList();
  movieTextureLookup = new ArrayList();
  
  // Create reference to default texture for first quad
  textureLookup.add(0);
  
  loadTextures();
}

void draw(){
  background(0);
  
  // Empty out the off-screen renderer
  glos.beginDraw();
  glos.clear(0);
  glos.endDraw();

  // Calibration mode
  if(sm.getMode() == sm.MODE_CALIBRATE) {
    sm.render(glos);
    
    // Show the GUI
    programOptions.show();
    
  // Render mode
  } else if(sm.getMode() == sm.MODE_RENDER){
    // Hide the GUI
    quadOptions.hide();
    bezierOptions.hide();
    programOptions.hide();

    // Update every texture (gets all new frames from movies)
    for(int i=0; i<textures.size(); i++) {
      GLTexture tex = textures.get(i);
      tex.putPixelsIntoTexture();
    }      
   
    // Render each surface to the GLOS using their textures
    for(SuperSurface ss : sm.getSurfaces()) {
      ss.render(glos, textures.get(textureLookup.get(ss.getId())));
    }
  }
  
  // Display the GLOS to screen
  image(glos.getTexture(),0,0,width,height);
  
  // Render any stray GUI elements over the GLOS
  if(sm.getMode() == sm.MODE_CALIBRATE) {
    programOptions.render();
    
    SuperSurface ss = sm.getSurfaceById(mostRecentSurface);
    
    if(ss.getSurfaceType() == ss.QUAD)
      quadOptions.render();
    else if(ss.getSurfaceType() == ss.BEZIER)
      bezierOptions.render();
  }
}

/*********************************************
 controlEvent(ControlEvent e)
 
 Called when some component of the ControLP5 
 GUI has fired off and event to be handled.
**********************************************/
public void controlEvent(ControlEvent e) {
  SuperSurface ss;
  int diff;
  
  switch(e.getId()) {
    // Program Options -> Create quad surface button
    case 1:
      sm.createQuadSurface(initialSurfaceResolution,width/2,height/2);
      
      // Add a reference to the default texture for this surface
      textureLookup.add(0);
      
      break;
      
    // Program Options -> Create bezier surface button
    case 2:
      sm.createBezierSurface(initialSurfaceResolution,width/2,height/2);
      
      // Add a reference to the default texture for this surface
      textureLookup.add(0);
      
      break;
    
    // Program Options -> Load layout button
    case 3:
      sm.load(selectInput("Load layout"));
      
      // Clear out ArrayLists
      textureLookup.clear();
      movieTextureLookup.clear();
      
      // Read textureLookup.txt
      try {
        BufferedReader reader = createReader(sketchPath + "/data/lookups/textureLookup.txt");
        String line;
        
        try {
          while((line = reader.readLine()) != null)
            textureLookup.add(Integer.parseInt(line));
            
          println("Texture lookups successfully loaded.");
        } catch(IOException ee) {
          println("Could not read line from textureLookup.txt");
        }
      } catch(Exception ee) {
        println("Could not load textureLookup.txt");
        
        ArrayList surfaces = sm.getSurfaces();
        for(int i=0; i<surfaces.size(); i++) {
          textureLookup.add(0);
        }
      }
      
      // Read movieTextureLookup.txt
      try {
        BufferedReader reader = createReader(sketchPath + "/data/lookups/movieTextureLookup.txt");
        String line;
        
        try {
          while((line = reader.readLine()) != null)
            movieTextureLookup.add(Integer.parseInt(line));
            
          println("Movie/texture lookups successfully loaded.");
        } catch(IOException ee) {
          println("Could not read line from movieTextureLookup.txt");
        }
      } catch(Exception ee) {
        println("Could not load movieTextureLookup.txt");
      }
           
      mostRecentSurface = 0;
      break;      
      
    // Program Options -> Save layout button
    case 4:
      sm.save(selectOutput("Save layout"));
      
      // Write textureLookup to file
      PrintWriter output = createWriter(sketchPath + "/data/lookups/textureLookup.txt");
      for(int i=0; i<textureLookup.size(); i++) {
        int id = (int)textureLookup.get(i);
        output.println(id);
      }
      output.flush();
      output.close();
      
      // Write movieTextureLookup to file
      output = createWriter(sketchPath + "/data/lookups/movieTextureLookup.txt");
      for(int i=0; i<movieTextureLookup.size(); i++) {
        int id = (int)movieTextureLookup.get(i);
        output.println(id);
      }
      output.flush();
      output.close();      
      
      break;

    // Program Options -> Switch to render mode
    case 5:
      sm.toggleCalibration();
      break;
      
    // RESERVED for Quad Options > name
    case 6:
      break;
      
    // Quad Options -> increase resolution
    case 7:
      // Get the most recently active surface
      // This throws a bunch of gnarly errors to the console, but seems to work...
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.increaseResolution();
      break;
      
    // Quad Options -> decrease resolution
    case 8:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.decreaseResolution();
      break;
      
    // Quad Options -> Source file
    case 9:
      // Find the index of the filename
      int textureIndex = -1;
      for(int i=0; i<textureNames.size(); i++) {
        String textureName = textureNames.get(i);
        
        if(e.getGroup().captionLabel().getText().equals(textureName))
          textureIndex = i;
      }
      
      // Assign the texture to the correct surface
      if(textureIndex >= 0)
        textureLookup.set(mostRecentSurface, textureIndex);
      
      break;
      
    // RESERVED for Bezier Options-> name
    case 10:
      break;
      
    // Bezier Options -> increase resolution
    case 11:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.increaseResolution();
      break;
      
    // Bezier Options -> decrease resolution
    case 12:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.decreaseResolution();
      break;
      
    // Bezier Options -> increase horizontal force
    case 13:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.increaseHorizontalForce();
      break;
    // Bezier Options -> decrease horizontal force
    case 14:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.decreaseHorizontalForce();
      break;
      
    // Bezier Options -> increase vertical force
    case 15:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.increaseVerticalForce();
      break;
      
    // Bezier Options -> decrease vertical force
    case 16:
      ss = sm.getSurfaceById(mostRecentSurface);
      ss.decreaseVerticalForce();
      break;
   
    // Bezier Options -> Source file
    case 17:
      // Find the index of the filename
      textureIndex = -1;
      for(int i=0; i<textureNames.size(); i++) {
        String textureName = textureNames.get(i);
        
        if(e.getGroup().captionLabel().getText().equals(textureName))
          textureIndex = i;
      }
      
      // Assign the texture to the correct surface
      if(textureIndex >= 0) {
        textureLookup.set(mostRecentSurface, textureIndex);
      }
      
      break;
  }
}

void mouseReleased() {
  // Double click returns to calibration mode
  if(sm.getMode() == sm.MODE_RENDER && mouseEvent.getClickCount() == 2) {
    sm.toggleCalibration();
    
    // Stop all videos
    if(moviesPlaying) {
      for(int i=0; i<movies.size(); i++) {
        GSMovie movie = movies.get(i);
        movie.stop();
      }
      moviesPlaying = false;
    }
  }
  
  // Show and update the appropriate menu
  if(sm.getMode() == sm.MODE_CALIBRATE) { 
    // Find selected surface
    for(SuperSurface ss : sm.getSelectedSurfaces())
      mostRecentSurface = ss.getId();
  
    SuperSurface ss = sm.getSurfaceById(mostRecentSurface);
    
    if(ss.getSurfaceType() == ss.QUAD) {
      bezierOptions.hide();
      quadOptions.show();
      
      quadOptions.setSurfaceName(""+ss.getId());
    } else if(ss.getSurfaceType() == ss.BEZIER) {
      quadOptions.hide();
      bezierOptions.show();
      
      bezierOptions.setSurfaceName(""+ss.getId());
    }    
  }
}

void keyReleased() {
  if(key == ' ') {
    if(moviesPlaying) {
      for(int i=0; i<movies.size(); i++) {
        GSMovie movie = movies.get(i);
        movie.pause();
        movie.jump(0);
      }
      moviesPlaying = false;
    } else {
      for(int i=0; i<movies.size(); i++) {
        GSMovie movie = movies.get(i);
        movie.loop();
      }
      moviesPlaying = true;
    }
  }
}

/*************************************
 Read frames from all videos
**************************************/
void movieEvent(GSMovie movie) {
  movie.read();
}

void loadTextures() {
  // Load all textures from texture folder
  File file = new File(sketchPath + "/data/textures");
  
  if(file.isDirectory()) {
    File[] files = file.listFiles();
    
    for(int i=0; i<files.length; i++) {
      // Get and split the filename
      String filename = files[i].getName();
      String[] filenameParts = split(filename,".");
      
      // Check to see if file is an image
      boolean isImage = false;
      for(int j=0; j<imageTypes.length; j++)
        if(filenameParts[1].equals(imageTypes[j]))
          isImage = true;

      // Check to see if file is a movie
      boolean isMovie = false;
      if(!isImage)
        for(int j=0; j<movieTypes.length; j++)
          if(filenameParts[1].equals(movieTypes[j]))
            isMovie = true;

      // Create a texture for the files, add to ArrayList
      GLTexture tex;
      
      // Images get added directly to textures ArrayList
      if(isImage) {
        tex = new GLTexture(this, sketchPath + "/data/textures/" + filename);
        textures.add(tex);
        textureNames.add(filename);
        
      // Videos need empty texture in textures ArrayList, as well as
      // actual video in videos ArrayList (and lookup)
      } else if(isMovie) {      
        // Create texture 
        tex = new GLTexture(this);
        textures.add(tex);
        textureNames.add(filename);
        
        // Create movie
        GSMovie movie = new GSMovie(this, sketchPath + "/data/textures/" + filename);
        movie.setPixelDest(tex);
        movies.add(movie);
        
        // Associate movie to texture
        movieTextureLookup.add(movies.size()-1, textures.size()-1);
      }
    }
  }
}
