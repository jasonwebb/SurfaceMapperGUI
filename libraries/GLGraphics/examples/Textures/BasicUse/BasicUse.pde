// Basic example of GLTexture and GLTextureFilter.
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTextureFilter pulseEmboss;
GLTexture tex0, tex1;
PImage img;
PFont font;

float fade;

void setup()
{
    size(640, 480, GLConstants.GLGRAPHICS);
    
    // A GLTexture object can be created in different ways.
    // Loading an image directly upon creation:
    tex0 = new GLTexture(this, "milan_rubbish.jpg");
    // Creating an empty texture and then loading the image.
    //tex0 = new GLTexture(this);
    //tex0.loadTexture("milan_rubbish.jpg");
    
    // The texture can be created empty but with a specified size:
    tex1 = new GLTexture(this, tex0.width, tex0.height);
    println(tex0.width + " " + tex0.height);
    
    // A filter is defined in an xml file where the glsl shaders and grid are specified.
    pulseEmboss = new GLTextureFilter(this, "pulsatingEmboss.xml");
    
    img = new PImage(tex0.width, tex0.height);
    
    font = loadFont("EstrangeloEdessa-24.vlw");
    textFont(font, 24);
    
    /*
    // GLTexture is a descendant of PImage, so it has pixels that can be 
    // modified.
    tex0.init(200, 200);
    tex0.loadPixels();
    int k = 0;
    for (int j = 0; j < tex0.height; j++)
        for (int i = 0; i < tex0.width; i++)    
        {
           if (j < 100) tex0.pixels[k] = 0xffffffff;
           else tex0.pixels[k] = 0xffffff00;        
           k++;
        }
    // loadTexture function copies pixels to texture.
    tex0.loadTexture();
    */

    /*
    // Images can pe passed to a GLTexture object using a PImage as an intermediate container:
    img = loadImage("milan_rubbish.jpg"); 
    tex0.putImage(img);
    */
    
    fade = 1.0;
}

void draw()
{
    background(0); 

    tint(255, 255, 255, 255);   
    image(tex0, 0, 0);
    fill(255);   
    text("source texture", 0, 220);
  
    // A filer is applied on a texture by passing it as a parameter,
    // together with the destination texture. Right after applying the
    // filter, only the texture data in tex1 contains the filtered image,
    // not the pixel nor the image.
    tex0.filter(pulseEmboss, tex1, fade);

    // The texture can be flipped along X or Y.
    //tex1.setFlippedX(true);
    //tex1.setFlippedY(true);

    tint(255, 200, 200, 180);
   
    // A texture can be drawn using the image function, or its render method. The latter approach
    // draws the texture inside a quad, so stroke is disabled.
    noStroke();
   
    // The texture can be drawn as a regular PImage, but the operation
    // is much faster since is accelerated on the video card.
    image(tex1, mouseX, mouseY);
   
    // Alternatively, a PImage can be obtained from a GLTexture object,
    // and drawn to the screen. This is substantially slower, not only
    // because the drawing is not accelerated, but because the texture 
    // has to be copied from the video card to the PImage on the CPU 
    // memory.
    //tex1.getImage(img);
    //image(img, mouseX, mouseY);
   
    fill(255);
    text("filtered texture", mouseX, mouseY + 220);
    text("use up and down arrow keys to control effect fade", 0, 470);
}

void keyPressed()
{
    if (key == CODED) 
    {
        if (keyCode == UP) 
        {
            fade = constrain(fade + 0.01, 0.0, 1.0);
        } 
        else if (keyCode == DOWN)
        {
            fade = constrain(fade - 0.01, 0.0, 1.0);
        }
    }
}
