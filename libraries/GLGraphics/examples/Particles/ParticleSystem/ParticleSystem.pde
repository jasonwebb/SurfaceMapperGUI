// Simple Particle system simulated on the GPU.
// By Andres Colubri
// GPGPU techniques are used to calculate the motion of a large number of
// particles on the GPU. Tested only on NVidia Geforce 8x00.
// Note: For some unknown reason, it doesn't work on OSX. I tried to fix, but
// wasn't successful.

import processing.opengl.*;
import codeanticode.glgraphics.*;

// Number of particles. It is actually approximated to the closest power-of-two value.
int SYSTEM_SIZE = 20000;

// Size of the particles.
float PARTICLE_SIZE = 10.0;

GLTexture canvasTex;              // Texture where the particles are rendered to.
GLTexture bubbleTex;              // Texture used to draw each particle.

// Ping-pong textures used to store the position and velocities of the particles.
GLTexturePingPong partPosTex;
GLTexturePingPong partVelTex;

GLTextureFilter movePartFilter;    // Filter that contains the dynamic kernel that updates the position and velocities of the particles on the GPU.
GLTextureFilter renderPartFilter;  // Filter that renders the particles.

int sec0;

void setup()
{
    size(800, 600, GLConstants.GLGRAPHICS);  
    colorMode(RGB);
    
    initTextures();
    initFilters();
}

void draw()
{
    background(0);
   
    // Here, the motion of the particles is updated. There are four textures involved here,
    // two from which the old position and velocity are read from, and two to which the updated
    // velocities and positions are write to.
    GLTexture[] inputTex = { partPosTex.getReadTex(), partVelTex.getReadTex() };
    GLTexture[] outputTex = { partPosTex.getWriteTex(), partVelTex.getWriteTex() };
     
    // Input parameters used to control the motion of the particles.
    movePartFilter.setParameterValue("mpos", new float[]{mouseX, mouseY}); // Position of the mouse (the particles that are closes to the mouse are the most affected by it).
    movePartFilter.setParameterValue("mdisp", new float[]{mouseX - pmouseX, mouseY - pmouseY}); // Displacement vector used to set the velocity of the particles.
    
    
    movePartFilter.apply(inputTex, outputTex); 
    // Exchanging the role of the ping-pong particles: those used to write to will be
    // used to read from in the next iteration.
    partPosTex.swap();
    partVelTex.swap();    

    // paint() fills the texture with the specified color, and transparency can be used
    // see through the last image.
    canvasTex.paint(0, 0, 0, 10);
    
    // clear() erases the texture, so if it has a previous image, it is lost, even if the
    // transparency is set to less than the maximum.
    canvasTex.clear(0, 0, 0, 255);
    
    // Rendering the particles using their current positions.
    inputTex[0] = partPosTex.getReadTex();
    inputTex[1] = bubbleTex;
    renderPartFilter.apply(inputTex, canvasTex);
    
    // Drawing the texture with the image.
    image(canvasTex, 0, 0, width, height);

    int sec = second();
    if (sec != sec0) println("FPS: " + frameRate);
    sec0 = sec;
}

void initTextures()
{   
    bubbleTex = new GLTexture(this, "bubble.png");

    canvasTex = new GLTexture(this, width, height);
    canvasTex.loadPixels();
    for (int i = 0; i < canvasTex.width * canvasTex.height; i++) canvasTex.pixels[i] = 0xff000000;
    canvasTex.loadTexture();
  
    // Creating Ping-pong textures for position and velocities.
    GLTextureParameters floatTexParams = new GLTextureParameters();
    floatTexParams.minFilter = GLTexture.NEAREST_SAMPLING; // We don't want linear filtering for GPGPU calculations.
    floatTexParams.magFilter = GLTexture.NEAREST_SAMPLING;
    floatTexParams.format = GLTexture.FLOAT; // The ping-pong textures are float since they store position and velocity values.
    partPosTex = new GLTexturePingPong(new GLTexture(this, SYSTEM_SIZE, floatTexParams), 
                                       new GLTexture(this, SYSTEM_SIZE, floatTexParams));
    
    partVelTex = new GLTexturePingPong(new GLTexture(this, SYSTEM_SIZE, floatTexParams),
                                       new GLTexture(this, SYSTEM_SIZE, floatTexParams));

    partPosTex.getReadTex().setRandom(0, width, 0, height, 0, 0, 0, 0);
    partPosTex.getWriteTex().setRandom(0, width, 0, height, 0, 0, 0, 0);

    partVelTex.getReadTex().setZero();
    partVelTex.getWriteTex().setZero();

    int w = partPosTex.getReadTex().width;
    int h = partPosTex.getReadTex().height;
    println("Size of particles box: " + w + "x" + h);
    println("Number of particles: " + w * h);
}

void initFilters()
{
    movePartFilter = new GLTextureFilter(this, "MovePart.xml");
    movePartFilter.setParameterValue("edges", new float[]{width, height}); // Edges of the area where the particles can move.
    
    renderPartFilter = new GLTextureFilter(this, "RenderPart.xml");
    renderPartFilter.setParameterValue("brush_size", PARTICLE_SIZE);
    renderPartFilter.setBlendMode(BLEND);
}

