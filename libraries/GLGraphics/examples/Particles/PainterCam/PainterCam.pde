// Painterly effect.
// By Andres Colubri
// This effect uses a particle system simulated on the GPU to 
// generate a painterly effect. Tested only on NVidia Geforce. For 
// models previous to 8x00, change the xml files in createFilters()
// (PainterEffect.pde)

import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

int SYSTEM_SIZE = 100000;
int CANVAS_WIDTH = 800;
int CANVAS_HEIGHT = 600;

boolean clearImg = false;
boolean changeImg = true;
float stillTime = 1.0;
float changeTime = 0.5;
float destTexTransparency = 1.0;
float lastChangeTime = 0.0;

GLTexture srcTex, destTex, brushTex;

PainterEffect painter;
GSCapture cam;

int sec0;

void setup()
{
    size(CANVAS_WIDTH, CANVAS_HEIGHT, GLConstants.GLGRAPHICS);
    colorMode(RGB, 1.0);
    
    cam = new GSCapture(this, 640, 480);
    cam.start();
    
    srcTex = new GLTexture(this);
    brushTex = new GLTexture(this, "brush1.png");    
    
    destTex = new GLTexture(this, width, height);
    destTex.loadPixels();
    for (int i = 0; i < destTex.width * destTex.height; i++) destTex.pixels[i] = 0xff000000;
    destTex.loadTexture();    

    painter = new PainterEffect(this, SYSTEM_SIZE, CANVAS_WIDTH, CANVAS_HEIGHT);
}

void captureEvent(GSCapture cam)
{
    cam.read();  
}

void draw()
{
    background(0);
    
    float time = millis() / 1000.0;
    if (time - lastChangeTime > stillTime)
    {
        srcTex.putPixelsIntoTexture(cam);
        changeImg = true;
        lastChangeTime = time;

      }
    painter.apply(srcTex, brushTex, destTex, clearImg, changeImg, changeTime);
    if (changeImg) changeImg = false;

    tint(1.0, 1.0 - destTexTransparency);     
    image(srcTex, 0, 0, width, height); 
    tint(1.0, destTexTransparency);
    image(destTex, 0, 0, width, height);

    int sec = second();
    if (sec != sec0) println("FPS: " + frameRate);
    sec0 = sec;
}

void mouseDragged()
{
    destTexTransparency = float(mouseX) / width;
}

void keyPressed()
{
    if (key == CODED)
    {
        if (keyCode == UP) painter.noiseMag = constrain(painter.noiseMag + 0.2, 0.0, 10.0);
        else if (keyCode == DOWN) painter.noiseMag = constrain(painter.noiseMag - 0.2, 0.0, 10.0);
        else if (keyCode == RIGHT) painter.brushMaxLength = constrain(painter.brushMaxLength + 1, 1, 100);
        else if (keyCode == LEFT) painter.brushMaxLength = constrain(painter.brushMaxLength - 1, 1, 100);
        else if (keyCode == ALT) painter.brushSize = constrain(painter.brushSize + 1.0, 1.0, 100.0);
        else if (keyCode == CONTROL) painter.brushSize = constrain(painter.brushSize - 1.0, 1.0, 100.0);
    }
    else if (key == '+') painter.velMean = constrain(painter.velMean + 0.2, 0.0, 20.0);
    else if (key == '-') painter.velMean = constrain(painter.velMean - 0.2, 0.0, 20.0);
    else if ((key == 'F') || (key == 'f')) painter.followGrad = !painter.followGrad;
    else if ((key == 'U') || (key == 'u')) painter.updateColor = !painter.updateColor;
    else if ((key == 'B') || (key == 'b')) painter.blendBrushes = !painter.blendBrushes;    
    else if ((key == 'R') || (key == 'r')) painter.setDefParameters();
    else if ((key == 'C') || (key == 'c')) clearImg = !clearImg;
    else if ((key == 'S') || (key == 's')) saveFrame("painter-####.tif");
}

