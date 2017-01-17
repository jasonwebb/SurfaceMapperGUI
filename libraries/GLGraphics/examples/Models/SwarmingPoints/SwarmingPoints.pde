// Swarming points using GLModel. The GLModel class 
// allows to create 3D models (with colors, normals
// and textures) directly in the GPU memory.
// By Andres Colubri.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel points;

int numPoints = 10000;

float a = 0;

void setup()
{
    size(640, 480, GLConstants.GLGRAPHICS);  
    
    points = new GLModel(this, numPoints, POINTS, GLModel.DYNAMIC);
    points.initColors();
    
    points.beginUpdateVertices();
    for (int i = 0; i < numPoints; i++) points.updateVertex(i, 100 * random(-1, 1), 100 * random(-1, 1), 100 * random(-1, 1));
    points.endUpdateVertices();

    points.beginUpdateColors();
    for (int i = 0; i < numPoints; i++) points.updateColor(i, random(0, 255), random(0, 255), random(0, 255), 225);
    points.endUpdateColors();  
}

void draw()
{      
    // When drawing GLModels, the drawing calls need to be encapsulated 
    // between beginGL()/endGL() to ensure that the camera configuration 
    // is properly set.
    GLGraphics renderer = (GLGraphics)g;
    renderer.beginGL();  
    
    background(0);  
    // The vertices are displaced randomly (so each particle describes a random walk).  
    points.beginUpdateVertices();
    for (int i = 0; i < numPoints; i++) points.displaceVertex(i, random(-0.5, 0.5), random(-0.5, 0.5), random(-0.5, 0.5));
    points.endUpdateVertices();

    translate(width/2,height/2,0);        
    rotateY(a);
    
    // A model can be drawn through the GLGraphics renderer:
    renderer.model(points);
    // ...or just by calling its render() method:
    //points.render();
    
    renderer.endGL();  
  
    a += 0.005;
    
    println(frameRate);
}