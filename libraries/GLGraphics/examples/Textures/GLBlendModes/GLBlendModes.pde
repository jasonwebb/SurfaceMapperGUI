//
// GLBlendModes, October 2010
//
// Provides most common image blend modes as GLTextureFilters
// GLSL code is in the data folder
// Will advance automaticallty through blend-modes, or hit "space" to speed it up
// Use up/down arrows to adjust opacity
//
// (C) 2010 Kevin Bjorke http://www.botzilla.com
// Free to Distribute with Attribution
// Made with Processing - http://www.processing.org
// Requires the GLGraphics library - http://codeanticode.wordpress.com/
//

import processing.opengl.*;
import codeanticode.glgraphics.*;

//
// User params class
//
class ScalarParam {
  float value;
  float minValue;
  float maxValue;
  float step;
  ScalarParam(float v,float mn, float mx, float s) {
    value = v;
    minValue = mn;
    maxValue = mx;
    step = s;
  }
  void Increment() {
    value += step;
    if (value > maxValue) value=maxValue;
  }
  void Decrement() {
    value -= step;
    if (value < minValue) value=minValue;
  }
}

/// Class to contain filter data //////////////////////////////////

class LayerBlend {
  String name;
  GLTextureFilter filter;
  LayerBlend(PApplet Parent,String Name,String XmlFile) {
    name = Name;
    filter = new GLTextureFilter(Parent,XmlFile);
  }
  void apply() {
    filter.apply(new GLTexture[]{bottomLayer, topLayer}, resultLayer); // all are called the same way
  }
}

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

ArrayList BlendModes; // will be an arraylist of LayerBlends

GLTexture bottomLayer, topLayer, resultLayer;
PFont font;
ScalarParam opacity;
PImage bottomImg;
PImage topImg;

Iterator ii;

int displayCount;

LayerBlend current;

////////////////////////////////////////////////////////////////////////
// Setup ///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

void setup()
{
  size(500,281, GLConstants.GLGRAPHICS);
  BlendModes = new ArrayList();
  BlendModes.add(new LayerBlend(this,"Color","BlendColor.xml"));
  BlendModes.add(new LayerBlend(this,"Luminance","BlendLuminance.xml"));
  BlendModes.add(new LayerBlend(this,"Multiply","BlendMultiply.xml"));
  BlendModes.add(new LayerBlend(this,"Subtract","BlendSubtract.xml"));
  BlendModes.add(new LayerBlend(this,"Linear Dodge (Add)","BlendAdd.xml"));
  BlendModes.add(new LayerBlend(this,"ColorDodge","BlendColorDodge.xml"));
  BlendModes.add(new LayerBlend(this,"ColorBurn","BlendColorBurn.xml"));
  BlendModes.add(new LayerBlend(this,"Darken","BlendDarken.xml"));
  BlendModes.add(new LayerBlend(this,"Lighten","BlendLighten.xml"));
  BlendModes.add(new LayerBlend(this,"Difference","BlendDifference.xml"));
  BlendModes.add(new LayerBlend(this,"InverseDifference","BlendInverseDifference.xml"));
  BlendModes.add(new LayerBlend(this,"Exclusion","BlendExclusion.xml"));
  BlendModes.add(new LayerBlend(this,"Overlay","BlendOverlay.xml"));
  BlendModes.add(new LayerBlend(this,"Screen","BlendScreen.xml"));
  BlendModes.add(new LayerBlend(this,"HardLight","BlendHardLight.xml"));
  BlendModes.add(new LayerBlend(this,"SoftLight","BlendSoftLight.xml"));
  BlendModes.add(new LayerBlend(this,"Normal (Unpremultiplied, Photo Mask)","BlendUnmultiplied.xml"));
  BlendModes.add(new LayerBlend(this,"Normal (Premultiplied, CG Alpha)","BlendPremultiplied.xml"));
  font = loadFont("EstrangeloEdessa-24.vlw");
  textFont(font, 20);
  opacity = new ScalarParam(1.0,0.0,1.0,0.01);
  bottomLayer = new GLTexture(this, "bjorke_P1040584.jpg");
  topLayer = new GLTexture(this, "bjorke_P1100182.jpg");
  resultLayer = new GLTexture(this, topLayer.width,topLayer.height);
  ii = BlendModes.iterator();
  displayCount = 0;
}

////////////////////////////////////////////////////////////////////////
// Draw ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

void tdrop(String Text,int x, int y) {
  fill(0);
  text(Text,x+1,y+1);
  fill(255);
  text(Text,x,y);
}

void draw()
{
  background(0);
  noStroke();
  if (displayCount == 0) {
    if (! ii.hasNext()) {
      ii = BlendModes.iterator();
    }
    current = (LayerBlend)ii.next();
  }
  displayCount ++;
  if (displayCount > 200) displayCount = 0;
  current.filter.setParameterValue("Opacity",opacity.value);
  current.apply();
  resultLayer.render(0,0);
  int o = (int)floor(opacity.value*100.0);
  textFont(font, 20);
  tdrop("GLBlendModes V1.0",10,20);
  tdrop(""+o+"% "+current.name,10,44);
  textFont(font, 14);
  tdrop("up, down, space keys",10,260);
}

////////////////////////////////////////////////////////////////////////
// KeyPressed //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) opacity.Increment();
    else if (keyCode == DOWN) opacity.Decrement();
  } else if (key == ' ') {
    displayCount = 0;
  }
}

///////////////////////////////////////////
////////////////////////////////// eof ////
///////////////////////////////////////////
