// Implementation of "irregular masking" between two textures 
// using GLTextureFilter. 
// The first texture passed to the filter is used as the source image to
// be masked, and the second is the mask itself. The alpha channel of 
// the mask texture is used to determine the visible areas of the 
// souce image. The mask factor controls how much of the non-transparent
// areas of the mask are seen.
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;

size(256, 256, GLConstants.GLGRAPHICS);

GLTexture imgTex = new GLTexture(this, "beach.jpg");
GLTexture imgMask = new GLTexture(this, "mask.png");
GLTexture maskedTex = new GLTexture(this, 256, 256);

GLTextureFilter maskFilter = new GLTextureFilter(this, "Mask.xml");

maskFilter.setParameterValue("mask_factor", 0.0f);
maskFilter.apply(new GLTexture[]{imgTex, imgMask}, maskedTex);

// Background pattern.
background(0);
stroke(255);
for (int x = 0; x < width; x += 10) line(x, 0, x, height);
for (int y = 0; y < width; y += 10) line(0, y, width, y);

image(maskedTex, 0, 0);
