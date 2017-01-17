// Implementation of a bloom effect using GLTextureFilters.
// By Andres Colubri
// Based in the HDR example by Stephane Metz:
// http://www.smetz.fr/?page_id=83
//
// Moving the mouse on the horizontal direction controls the brightness value
// used to detect bright regions, moving it along the vertical direction
// controls the exposure value used in the tone-mapping filter.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLTexture srcTex, bloomMask, destTex;
GLTexture tex0, tex2, tex4, tex8, tex16;

GLTextureFilter extractBloom, blur, blend4, toneMap;

PFont font;

boolean showAllTextures;
boolean showSrcTex, showTex16, showBloomMask, showDestTex;

void setup()
{
    size(640, 480, GLConstants.GLGRAPHICS);
    noStroke();
    
    // Loading required filters.
    extractBloom = new GLTextureFilter(this, "ExtractBloom.xml");
    blur = new GLTextureFilter(this, "Blur.xml");
    blend4 = new GLTextureFilter(this, "Blend4.xml");  
    toneMap = new GLTextureFilter(this, "ToneMap.xml");
       
    srcTex = new GLTexture(this, "lights.jpg");
    int w = srcTex.width;
    int h = srcTex.height;
    destTex = new GLTexture(this, w, h);

    // Initializing bloom mask and blur textures.
    bloomMask = new GLTexture(this, w, h, GLTexture.FLOAT);
    tex0 = new GLTexture(this, w, h, GLTexture.FLOAT);
    tex2 = new GLTexture(this, w / 2, h / 2, GLTexture.FLOAT);
    tex4 = new GLTexture(this, w / 4, h / 4, GLTexture.FLOAT);
    tex8 = new GLTexture(this, w / 8, h / 8, GLTexture.FLOAT);
    tex16 = new GLTexture(this, w / 16, h / 16, GLTexture.FLOAT);
    
    font = loadFont("EstrangeloEdessa-24.vlw");
    textFont(font, 24);     
    
    showAllTextures = true;
    showSrcTex = false;
    showTex16 = false;
    showBloomMask = false;
    showDestTex = false;
}

void draw()
{
    background(0);
    
    float fx = float(mouseX) / width;
    float fy = float(mouseY) / height;

    // Extracting the bright regions from input texture.
    extractBloom.setParameterValue("bright_threshold", fx);
    extractBloom.apply(srcTex, tex0);
  
    // Downsampling with blur.
    tex0.filter(blur, tex2);
    tex2.filter(blur, tex4);    
    tex4.filter(blur, tex8);    
    tex8.filter(blur, tex16);     
    
    // Blending downsampled textures.
    blend4.apply(new GLTexture[]{tex2, tex4, tex8, tex16}, new GLTexture[]{bloomMask});
    
    // Final tone mapping into destination texture.
    toneMap.setParameterValue("exposure", fy);
    toneMap.setParameterValue("bright", fx);
    toneMap.apply(new GLTexture[]{srcTex, bloomMask}, new GLTexture[]{destTex});

    if (showAllTextures)
    {
        image(srcTex, 0, 0, 320, 240);
        image(tex16, 320, 0, 320, 240);
        image(bloomMask, 0, 240, 320, 240);
        image(destTex, 320, 240, 320, 240);      
        
        fill(220, 20, 20);
        text("source texture", 10, 230);
        text("downsampled texture", 330, 230);
        text("bloom mask", 10, 470);        
        text("final texture", 330, 470);        
    }
    else
    {
        if (showSrcTex) image(srcTex, 0, 0, width, height);
        else if (showTex16) image(tex16, 0, 0, width, height);
        else if (showBloomMask) image(bloomMask, 0, 0, width, height);        
        else if (showDestTex) image(destTex, 0, 0, width, height);
    }
}

void mousePressed()
{
    if (showAllTextures)
    {
        showAllTextures = false;
        showSrcTex = (0 <= mouseX) && (mouseX < 320) && (0 <= mouseY) && (mouseY < 240);
        showTex16 = (320 <= mouseX) && (mouseX <= 640) && (0 <= mouseY) && (mouseY < 240);    
        showBloomMask = (0 <= mouseX) && (mouseX < 320) && (240 <= mouseY) && (mouseY <= 480);
        showDestTex = (320 <= mouseX) && (mouseX <= 640) && (240 <= mouseY) && (mouseY <= 480);   
    }
    else
    {
        showAllTextures = true; 
    }
}
