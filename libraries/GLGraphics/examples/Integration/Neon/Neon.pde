// Neon effect, based on this discussion:
// http://processing.org/discourse/yabb2/YaBB.pl?num=1262637573/0
// It uses the OCD library for camera motion:
// http://www.gdsstudios.com/processing/libraries/ocd/reference/

import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;
import damkjer.ocd.*;

GLGraphics pgl;
GLGraphicsOffScreen offscreen;
GL gl;

GLTexture srcTex, bloomMask, destTex;
GLTexture tex0, tex2, tex4, tex8, tex16;
GLTexture tmp2, tmp4, tmp8, tmp16;
GLTextureFilter extractBloom, blur, blend4, toneMap;

Camera cam;

void setup(){
 size(720, 480, GLConstants.GLGRAPHICS);
 noStroke();
 hint( ENABLE_OPENGL_4X_SMOOTH );  
 
 // Loading required filters.
 extractBloom = new GLTextureFilter(this, "ExtractBloom.xml");
 blur = new GLTextureFilter(this, "Blur.xml");
 blend4 = new GLTextureFilter(this, "Blend4.xml");  
 toneMap = new GLTextureFilter(this, "ToneMap.xml");
   
 destTex = new GLTexture(this, width, height);
 
 // Initializing bloom mask and blur textures.
 bloomMask = new GLTexture(this, width, height, GLTexture.FLOAT);
 tex0 = new GLTexture(this, width, height, GLTexture.FLOAT);
 tex2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT);
 tmp2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT); 
 tex4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
 tmp4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
 tex8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT);
 tmp8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT); 
 tex16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
 tmp16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
 
 cam = new Camera(this, 0, 0, 200);
 
 offscreen = new GLGraphicsOffScreen(this, width, height, true, 4);  
 pgl = (GLGraphics) g;  
 gl = offscreen.gl;
 
 frameRate(30);

}

void draw(){
 
 background(0);
 
 float fx = constrain(float(mouseX) / width, 0.01, 1);
 float fy = float(mouseY) / height;
 
 srcTex = offscreen.getTexture();
 
 offscreen.beginDraw();
   offscreen.background(0);
       
   cam.circle(radians(noise(millis()*2)*noise(millis())*50));    
   //cam.circle(radians(mouseX / 800.) * PI);
   cam.feed();
   
   //offscreen.glDisable( GL.GL_DEPTH_TEST );
   //offscreen.glEnable( GL.GL_BLEND );
   //offscreen.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
       
   offscreen.beginGL();
     gl.glPushMatrix();
       line_3d(new PVector(  0,  50,  50), new PVector(-50, -50, -50), 1.66, color(255, 70, 70));
       line_3d(new PVector(-50, -50, -50), new PVector( 50, -50, -50), 1.66, color(255, 70, 70));
       line_3d(new PVector( 50, -50, -50), new PVector(  0,  50,  50), 1.66, color(255, 70, 70));
             
       line_3d(new PVector(  0,  50, -50), new PVector(-50, -50,  50), 1.66, color(255, 70, 70));
       line_3d(new PVector(-50, -50,  50), new PVector( 50, -50,  50), 1.66, color(255, 70, 70));
       line_3d(new PVector( 50, -50,  50), new PVector(  0,  50, -50), 1.66, color(255, 70, 70));      
     gl.glPopMatrix();
   offscreen.endGL();
 
 offscreen.endDraw();
 
 // Extracting the bright regions from input texture.
 extractBloom.setParameterValue("bright_threshold", fx);
 extractBloom.apply(srcTex, tex0);

 // Downsampling with blur
 tex0.filter(blur, tex2);
 tex2.filter(blur, tmp2);        
 tmp2.filter(blur, tex2);
    
 tex2.filter(blur, tex4);        
 tex4.filter(blur, tmp4);
 tmp4.filter(blur, tex4);            
 tex4.filter(blur, tmp4);
 tmp4.filter(blur, tex4);            
    
 tex4.filter(blur, tex8);        
 tex8.filter(blur, tmp8);
 tmp8.filter(blur, tex8);        
 tex8.filter(blur, tmp8);
 tmp8.filter(blur, tex8);        
 tex8.filter(blur, tmp8);
 tmp8.filter(blur, tex8);

 tex8.filter(blur, tex16);     
 tex16.filter(blur, tmp16);
 tmp16.filter(blur, tex16);        
 tex16.filter(blur, tmp16);
 tmp16.filter(blur, tex16);        
 tex16.filter(blur, tmp16);
 tmp16.filter(blur, tex16);
 tex16.filter(blur, tmp16);
 tmp16.filter(blur, tex16);  
 
 // Blending downsampled textures.
 blend4.apply(new GLTexture[]{tex2, tex4, tex8, tex16}, new GLTexture[]{bloomMask});
 
 // Final tone mapping into destination texture.
 toneMap.setParameterValue("exposure", fy);
 toneMap.setParameterValue("bright", fx);
 toneMap.apply(new GLTexture[]{srcTex, bloomMask}, new GLTexture[]{destTex});
 
 image(destTex, 0, 0, width, height);

}

//inspired from James Carruthers's drawLine
//http://processing.org/discourse/yabb2/YaBB.pl?num=1262458611/4#4
void line_3d(PVector pv1, PVector pv2, float weight, color _color){
 PVector v1 = new PVector(pv2.x - pv1.x, pv2.y - pv1.y, pv2.z - pv1.z);
 
 float rho = sqrt(pow(v1.x, 2) + pow(v1.y, 2) + pow(v1.z, 2));
 float phi = acos(v1.z / rho);
 float the = atan2(v1.y, v1.x);
 
 v1.mult(0.5);      
 
 float zval = pv1.dist(pv2) * 0.5;  
 float rad = radians(120) * weight * 0.5;
   
 gl.glPushMatrix();
   gl.glTranslatef(pv1.x, pv1.y, pv1.z);
   gl.glTranslatef(v1.x, v1.y, v1.z);
   gl.glRotatef(degrees(the), 0, 0, 1);
   gl.glRotatef(degrees(phi), 0, 1, 0);
   gl.glColor4f(red(_color)/255, green(_color)/255, blue(_color)/255, 0.67);
   
   //DRAW THE 3D 'LINE' (with 3 planes)  
   gl.glBegin(GL.GL_QUADS);
     //1
     gl.glVertex3f( rad, -rad,  zval);
     gl.glVertex3f( rad, -rad, -zval);
     gl.glVertex3f(-rad, -rad, -zval);
     gl.glVertex3f(-rad, -rad,  zval);      
     //2
     gl.glVertex3f(-rad, -rad,  zval);
     gl.glVertex3f(-rad, -rad, -zval);
     gl.glVertex3f(   0,  rad, -zval);
     gl.glVertex3f(   0,  rad,  zval);
     //3
     gl.glVertex3f(   0,  rad,  zval);
     gl.glVertex3f(   0,  rad, -zval);
     gl.glVertex3f( rad, -rad, -zval);
     gl.glVertex3f( rad, -rad,  zval);
   gl.glEnd();
   
 gl.glPopMatrix();
   
} 
