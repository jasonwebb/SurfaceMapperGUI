// Example of multiple filters with GLTexture and GLTextureFilter.
// By Andres Colubri
// Note: this example requires a video card that supports opengl 2
// (geforce 6x00 or better for nvidia, and radeon 1x00 or better for ati).

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTextureFilter pulseEmboss, pixelate, gaussBlur, edgeDetect, posterize;
GLTexture tex0, tex1, tex2, tex3, tex4, tex5;

PImage img;

void setup()
{
    size(640, 480, GLConstants.GLGRAPHICS);
    noStroke();

    // Loading moderately big image file (1600x1200)
    tex0 = new GLTexture(this, "old_house.jpg");
    
    // Creating destination textures for the filters.
    tex1 = new GLTexture(this, tex0.width, tex0.height);
    tex2 = new GLTexture(this, tex0.width, tex0.height);    
    tex3 = new GLTexture(this, tex0.width, tex0.height);
    tex4 = new GLTexture(this, tex0.width, tex0.height);
    tex5 = new GLTexture(this, tex0.width, tex0.height);
    
    // A filter is defined in an xml file where the glsl shaders and grid are specified.
    pulseEmboss = new GLTextureFilter(this, "pulsatingEmboss.xml");
    gaussBlur = new GLTextureFilter(this, "gaussBlur.xml");
    pixelate = new GLTextureFilter(this, "pixelate.xml");    
    edgeDetect = new GLTextureFilter(this, "edgeDetect.xml");
    posterize = new GLTextureFilter(this, "posterize.xml");    
}

void draw()
{
   background(0); 

   // Filters can be chained, like here:   
   tex0.filter(pulseEmboss, tex1);
   tex1.filter(gaussBlur, tex2);

   // The resolution of the pixelization in the pixelate filter is controlled.
   // by the pixel_size parameter in the shader.
   pixelate.setParameterValue("pixel_size", map(mouseX, 0, 640, 1, 100));
   tex0.filter(pixelate, tex3);
   
   tex0.filter(edgeDetect, tex4);
   tex0.filter(posterize, tex5);
   
   tex2.render(0, 0, 320, 240);
   tex3.render(320, 0, 320, 240);
   tex4.render(0, 240, 320, 240);   
   tex5.render(320, 240, 320, 240);
}
