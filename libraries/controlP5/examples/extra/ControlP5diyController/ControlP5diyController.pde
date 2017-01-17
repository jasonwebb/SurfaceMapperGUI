/**
 * ControlP5 DIY controller
 *
 * !!!
 * this example is broken with controlP5 version 0.7.2 and higher
 * Do have a look at the use/ControlP5extendController example instead
 *
 * this example shows how to create your own controller by extending and
 * using the abstract class Controller, the base class for every controller.
 *
 * by Andreas Schlegel, 2011
 * www.sojamo.de/libraries/controlP5
 *
 */
 
import controlP5.*;

ControlPad pad;

ControlP5 cp5;

void setup() {
  size(400,400);

  cp5 = new ControlP5(this);

  // create a new instance of the ControlPad controller.
  pad = new ControlPad(cp5,"DIY",100,50,100,100);
  // register the newly created ControlPad with controlP5
  cp5.register(this,"pad",pad);
}

void draw() {
  background(0);
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.arrayValue());
}


// create your own ControlP5 controller.
// your own controller needs to extend controlP5.Controller
// for reference and documentation see the javadoc for controlP5
// and the source code as indicated on the controlP5 website.
class ControlPad extends Controller {

  // 4 fields for the 2D controller-handle
  int cWidth=10, cHeight=10; 
  float cX, cY;

  // constructor, required.
  ControlPad(ControlP5 theControlP5, String theName, int theX, int theY, int theWidth, int theHeight) {
    // the super class Controller needs to be initialized with the below parameters
    super(theControlP5, theName, theX, theY, theWidth, theWidth);
    // the Controller class provides a field to store values in an 
    // float array format. for this controller, 2 floats are required.
    setArrayValue(new float[2]);
  }

  // overwrite the updateInternalEvents method to handle mouse and key inputs.
  public Controller updateInternalEvents(PApplet theApplet) {
    if(getIsInside()) {
      if(isMousePressed && !cp5.keyHandler.isAltDown()) {
        cX = constrain(mouseX-position().x,0,width-cWidth);
        cY = constrain(mouseY-position().y,0,height-cHeight);
        setValue(0);
      }
    }
    return this;
  }

  // override the draw(PApplet) method to display the controller.
  public void draw(PApplet theApplet) {
    // use pushMatrix and popMatrix when drawing
    // the controller.
    theApplet.pushMatrix();
    theApplet.translate(position().x, position().y);
    // draw the background of the controller.
    if(getIsInside()) {
      theApplet.fill(150);
    } 
    else {
      theApplet.fill(100);
    }
    rect(0,0,width,height);

    // draw the controller-handle
    fill(255);
    rect(cX,cY,cWidth,cHeight);
    // draw the caption- and value-label of the controller
    // they are generated automatically by the super class
    
    // !!! nullpointer when drawing labels here
    
    getCaptionLabel().draw(theApplet, 0, height + 4);
    getValueLabel().draw(theApplet, 40, height + 4);

    theApplet.popMatrix();
  } 

  // override setValue(float)
  public Controller setValue(float theValue) {
    // setValue is usually called from within updateInternalEvents
    // in case of changes, updates. the update of values or 
    // visual elements is done here.
    setArrayValue(0, cX / ((float)(width-cWidth)/(float)width));
    setArrayValue(1, cY / ((float)(height-cHeight)/(float)height));

    // update the value label.
    valueLabel().set(adjustValue(getArrayValue(0),0)+" / "+adjustValue(getArrayValue(1),0));

    // broadcast triggers a ControlEvent, updates are made to the sketch, 
    // controlEvent(ControlEvent) is called.
    // the parameter (FLOAT or STRING) indicates the type of 
    // value and the type of methods to call in the main sketch.
    broadcast(FLOAT);
    return this;
  }

}


