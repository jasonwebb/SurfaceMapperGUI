/**
 * Textured Sphere 
 * by Mike 'Flux' Chang (cleaned up by Aaron Koblin). 
 * Based on code by Toxi. 
 * Ported to GLGraphics by Andres Colubri
 * 
 * A 3D textured sphere with simple rotation control.
 * Note: Controls will be inverted when sphere is upside down. 
 * Use an "arc ball" to deal with this appropriately.
 */ 

import processing.opengl.*;
import codeanticode.glgraphics.*;

float rotationX = 0;
float rotationY = 0;
float velocityX = 0;
float velocityY = 0;

ArrayList vertices;
ArrayList texCoords;
ArrayList normals;

int globeDetail = 35;                 // Sphere detail setting.
float globeRadius = 450;              // Sphere radius.
String globeMapName = "world32k.jpg"; // Image of the earth.

GLModel earth;
GLTexture tex;

float distance = 30000; // Distance of camera from origin.
float sensitivity = 1.0;

void setup()
{
    size(1024, 768, GLConstants.GLGRAPHICS);
  
    // This funtion calculates the vertices, texture coordinates and normals for the earth model.
    calculateEarthCoords();

    earth = new GLModel(this, vertices.size(), TRIANGLE_STRIP, GLModel.STATIC);
    
    // Sets the coordinates.
    earth.updateVertices(vertices);
    
    // Sets the texture map.
    tex = new GLTexture(this, globeMapName);
    earth.initTextures(1);
    earth.setTexture(0, tex);
    earth.updateTexCoords(0, texCoords);

    // Sets the normals.
    earth.initNormals();
    earth.updateNormals(normals);
    
    // Sets the colors of all the vertices to white.
    earth.initColors();
    earth.setColors(255);
}

void draw() 
{
    background(0);
  
    GLGraphics renderer = (GLGraphics)g;
    renderer.beginGL();   
    
    translate(width/2, height/2, 0);
        
    pushMatrix();
    rotateX(radians(rotationX));
    rotateY(radians(270 - rotationY));
  
    renderer.model(earth);

    popMatrix();    

    renderer.endGL();
    
    rotationX += velocityX;
    rotationY += velocityY;
    velocityX *= 0.95;
    velocityY *= 0.95;
  
    // Implements mouse control (interaction will be inverse when sphere is  upside down)
    if (mousePressed)
    {
        velocityX += -(mouseY-pmouseY) * 0.01;
        velocityY -= (mouseX-pmouseX) * 0.01;
    }
}
