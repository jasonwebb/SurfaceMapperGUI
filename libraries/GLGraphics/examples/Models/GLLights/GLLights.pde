// GLGraphics re-implements the light API built into Processing. 
// Lights can be ambient, directional, point or spot. Use the A,
// D, P and D keys to switch between the four types of lights.
// Mouse controls placement of the light source.
// Note: an offscreen surface (GLGraphicsOffScreen) has its own
// lights, independent from the main renderer.

import processing.opengl.*;
import codeanticode.glgraphics.*;

GLModel sphere1, sphere2;

float lightX, lightY, lightZ;
int lightType;

void setup() {
  size(400, 400, GLConstants.GLGRAPHICS); 
 
  sphere1 = createSphere(30, 40);
  sphere2 = createSphere(30, 4);
  
  sphere1.setTint(255);
  sphere2.setTint(255);  
  
  lightType = 0;
}

void draw() {    
    lightX = mouseX;
    lightY = mouseY;
    lightZ = 100;
  
    // GLModels need to be rendered between
    // beginGL/endGL.
    GLGraphics renderer = (GLGraphics)g;
    renderer.beginGL();

    background(0);
    
    if (lightType == 0) {      
      ambientLight(51, 102, 126, lightX, lightY, lightZ);  
    } else if (lightType == 1) {
      float dirX = width/2 - lightX;
      float dirY = height/2 - lightY;
      float dirZ = 0 - lightZ;      
      float n = sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ);
      dirX /= n;
      dirY /= n;      
      dirZ /= n; 
      directionalLight(51, 102, 126, -dirX, -dirY, -dirZ);
    } else if (lightType == 2) {
      pointLight(51, 102, 126, lightX, lightY, lightZ);  
    } else if (lightType == 3) {
      float dirX = width/2 - lightX;
      float dirY = height/2 - lightY;
      float dirZ = 0 - lightZ;      
      float n = sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ);
      dirX /= n;
      dirY /= n;      
      dirZ /= n;       
      spotLight(51, 102, 126, lightX, lightY, lightZ, dirX, dirY, dirZ, PI/2, 40);
    }
    
    pushMatrix();
    translate(width/2, height/2, 0);
    sphere1.render();
    popMatrix();

    noLights();
    pushMatrix();
    translate(lightX, lightY, lightZ);
    sphere2.render();
    popMatrix();
  
    renderer.endGL();  
}

void keyPressed() {
    if (key == 'A' || key == 'a') {
        lightType = 0;
        println("Using ambient light");
    }  
    else if (key == 'D' || key == 'd') {
        lightType = 1;
        println("Using directional light");
    }      
    else if (key == 'P' || key == 'p') {
        lightType = 2;
        println("Using point light");
    }
    else if (key == 'S' || key == 's') {
        lightType = 3;
        println("Using spot light");
    }    
}
  

