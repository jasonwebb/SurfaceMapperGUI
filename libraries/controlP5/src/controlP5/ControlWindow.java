package controlP5;

/**
 * controlP5 is a processing gui library.
 *
 *  2006-2012 by Andreas Schlegel
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author 		Andreas Schlegel (http://www.sojamo.de)
 * @modified	10/22/2012
 * @version		1.5.2
 *
 */

import java.awt.Component;
import java.awt.Frame;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowFocusListener;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

/**
 * the purpose of a control window is to shift controllers from the main window into a separate
 * window. to save cpu, a control window is not updated when not active - in focus. for the same
 * reason the framerate is set to 15. To constantly update the control window, use
 * {@link ControlWindow#setUpdateMode(int)}
 * 
 * @example controllers/ControlP5window
 */
public class ControlWindow implements MouseWheelListener, WindowFocusListener {

	protected ControlP5 controlP5;

	protected int mouseX;

	protected int mouseY;

	protected int pmouseX;

	protected int pmouseY;

	protected boolean mousePressed;

	protected boolean mouselock;

	protected Controller<?> isControllerActive;

	public int background = 0x00000000;

	protected CColor color = new CColor();

	private String _myName = "main";

	protected PApplet _myApplet;

	private boolean isPAppletWindow;

	protected ControllerList _myTabs;

	protected boolean isVisible = true;

	protected boolean isInit = false;

	protected boolean isRemove = false;

	protected CDrawable _myDrawable;

	protected boolean isAutoDraw;

	protected boolean isUpdate;

	public final static int NORMAL = PAppletWindow.NORMAL;

	public final static int ECONOMIC = PAppletWindow.ECONOMIC;

	protected List<ControlWindowCanvas> _myControlWindowCanvas;

	private List<ControllerInterface<?>> mouseoverlist;

	private boolean isMouseOver;

	protected boolean isDrawBackground = true;

	protected boolean isUndecorated = false;

	protected boolean is3D;

	protected PVector autoPosition = new PVector(10, 30, 0);

	protected float tempAutoPositionHeight = 0;

	protected boolean rendererNotification = false;

	protected PVector positionOfTabs = new PVector(0, 0, 0);

	private boolean isMouse = true;

	private Pointer _myPointer;

	private boolean mousewheel = true;

	private int _myFrameCount = 0;

	private int mouseWheelMoved = 0;

	/**
	 * @exclude
	 */
	public ControlWindow(final ControlP5 theControlP5, final PApplet theApplet) {
		mouseoverlist = new ArrayList<ControllerInterface<?>>();
		controlP5 = theControlP5;
		_myApplet = theApplet;
		_myApplet.registerMouseEvent(this);
		_myApplet.addMouseWheelListener(this);
		try {
			_myApplet.frame.addWindowFocusListener(this);
		} catch (Exception e) {

		}
		isAutoDraw = true;
		init();
	}

	protected void init() {
		_myPointer = new Pointer();

		String myRenderer = _myApplet.g.getClass().toString().toLowerCase();
		is3D = (myRenderer.contains("gl") || myRenderer.contains("3d"));

		_myTabs = new ControllerList();
		_myControlWindowCanvas = new ArrayList<ControlWindowCanvas>();

		// TODO next section conflicts with Android
		if (_myApplet instanceof PAppletWindow) {
			_myName = ((PAppletWindow) _myApplet).name();
			isPAppletWindow = true;
			((PAppletWindow) _myApplet).setControlWindow(this);
		}

		if (_myApplet instanceof PAppletWindow) {
			background = 0xff000000;
		}

		if (isInit == false) {
			// TODO next section conflicts with Android
			if (_myApplet instanceof PAppletWindow) {
				_myApplet.registerKeyEvent(new ControlWindowKeyListener(this));
			} else {
				controlP5.keyHandler.update(this);
			}
		}

		_myTabs.add(new Tab(controlP5, this, "global"));
		_myTabs.add(new Tab(controlP5, this, "default"));

		activateTab((Tab) _myTabs.get(1));

		/*
		 * register a post event that will be called by processing after the draw method has been
		 * finished.
		 */

		// processing pre 2.0 will not draw automatically if in P3D mode. in earlier versions of controlP5
		// this had been checked here and the user had been informed to draw controlP5 manually by adding
		// cp5.draw() to the sketch's draw function. with processing 2.0 and this version of controlP5
		// this notification does no longer exist.
		
		if (isInit == false) {
			_myApplet.registerPre(this);
			_myApplet.registerDraw(this);
		}
		isInit = true;
	}

	@Override public void windowGainedFocus(WindowEvent e) {
	}

	@Override public void windowLostFocus(WindowEvent e) {
		controlP5.keyHandler.clear();
	}

	public Tab getCurrentTab() {
		for (int i = 1; i < _myTabs.size(); i++) {
			if (((Tab) _myTabs.get(i)).isActive()) {
				return (Tab) _myTabs.get(i);
			}
		}
		return null;
	}

	public ControlWindow activateTab(String theTab) {

		for (int i = 1; i < _myTabs.size(); i++) {
			if (((Tab) _myTabs.get(i)).getName().equals(theTab)) {
				if (!((Tab) _myTabs.get(i)).isActive) {
					resetMouseOver();
				}
				activateTab((Tab) _myTabs.get(i));
			}
		}
		return this;
	}

	public ControlWindow removeTab(Tab theTab) {
		_myTabs.remove(theTab);
		return this;
	}

	public Tab add(Tab theTab) {
		_myTabs.add(theTab);
		return theTab;
	}

	public Tab addTab(String theTab) {
		return getTab(theTab);
	}

	protected ControlWindow activateTab(Tab theTab) {
		for (int i = 1; i < _myTabs.size(); i++) {
			if (_myTabs.get(i) == theTab) {
				if (!((Tab) _myTabs.get(i)).isActive) {
					resetMouseOver();
				}
				((Tab) _myTabs.get(i)).setActive(true);
			} else {
				((Tab) _myTabs.get(i)).setActive(false);
			}
		}
		return this;
	}

	public ControllerList getTabs() {
		return _myTabs;
	}

	public Tab getTab(String theTabName) {
		return controlP5.getTab(this, theTabName);
	}

	/**
	 * Sets the position of the tab bar which is set to 0,0 by default. to move the tabs to
	 * y-position 100, use cp5.window().setPositionOfTabs(new PVector(0,100,0));
	 * 
	 * @param thePVector
	 */
	public ControlWindow setPositionOfTabs(PVector thePVector) {
		positionOfTabs.set(thePVector);
		return this;
	}

	public ControlWindow setPositionOfTabs(int theX, int theY) {
		positionOfTabs.set(theX, theY, positionOfTabs.z);
		return this;
	}

	/**
	 * Returns the position of the tab bar as PVector. to move the tabs to y-position 100, use
	 * cp5.window().getPositionOfTabs().y = 100; or cp5.window().setPositionOfTabs(new
	 * PVector(0,100,0));
	 * 
	 * @return PVector
	 */
	public PVector getPositionOfTabs() {
		return positionOfTabs;
	}

	void setAllignmentOfTabs(int theValue, int theWidth) {
		// TODO
	}

	void setAllignmentOfTabs(int theValue, int theWidth, int theHeight) {
		// TODO
	}

	void setAllignmentOfTabs(int theValue) {
		// TODO
	}

	public void remove() {
		for (int i = _myTabs.size() - 1; i >= 0; i--) {
			((Tab) _myTabs.get(i)).remove();
		}
		_myTabs.clear();
		_myTabs.clearDrawable();
		controlP5.controlWindowList.remove(this);
	}

	/**
	 * clear the control window, delete all controllers from a control window.
	 */
	public ControlWindow clear() {
		remove();
		if (_myApplet instanceof PAppletWindow) {
			_myApplet.unregisterMouseEvent(this);
			_myApplet.removeMouseWheelListener(this);
			_myApplet.stop();
			((PAppletWindow) _myApplet).dispose();
			_myApplet = null;
			System.gc();
		}
		return this;
	}

	protected void updateFont(ControlFont theControlFont) {
		for (int i = 0; i < _myTabs.size(); i++) {
			((Tab) _myTabs.get(i)).updateFont(theControlFont);
		}
	}

	/**
	 * @exclude
	 */
	@ControlP5.Invisible public void updateEvents() {
		handleMouseOver();
		handleMouseWheelMoved();
		if (_myTabs.size() <= 0) {
			return;
		}
		((ControllerInterface<?>) _myTabs.get(0)).updateEvents();
		for (int i = 1; i < _myTabs.size(); i++) {
			((Tab) _myTabs.get(i)).continuousUpdateEvents();
			if (((Tab) _myTabs.get(i)).isActive() && ((Tab) _myTabs.get(i)).isVisible()) {
				((ControllerInterface<?>) _myTabs.get(i)).updateEvents();
			}
		}
	}

	/**
	 * returns true if the mouse is inside a controller. !!! doesnt work for groups yet.
	 */
	public boolean isMouseOver() {
		// TODO doesnt work for all groups yet, only ListBox and DropdownList.
		if (_myFrameCount + 1 < _myApplet.frameCount) {
			resetMouseOver();
		}
		return isVisible ? isMouseOver : false;
	}

	public boolean isMouseOver(ControllerInterface<?> theController) {
		return mouseoverlist.contains(theController);
	}

	public void resetMouseOver() {
		isMouseOver = false;
		for (int i = mouseoverlist.size() - 1; i >= 0; i--) {
			mouseoverlist.get(i).setMouseOver(false);
		}
		mouseoverlist.clear();
	}

	public ControllerInterface<?> getFirstFromMouseOverList() {
		if (getMouseOverList().isEmpty()) {
			return null;
		} else {
			return getMouseOverList().get(0);
		}
	}

	/**
	 * A list of controllers that are registered with a mouseover.
	 */
	public List<ControllerInterface<?>> getMouseOverList() {
		return mouseoverlist;
	}

	private ControlWindow handleMouseOver() {
		for (int i = mouseoverlist.size() - 1; i >= 0; i--) {
			if (!mouseoverlist.get(i).isMouseOver() || !isVisible) {
				mouseoverlist.remove(i);
			}
		}
		isMouseOver = mouseoverlist.size() > 0;
		return this;
	}

	public ControlWindow removeMouseOverFor(ControllerInterface<?> theController) {
		mouseoverlist.remove(theController);
		return this;
	}

	protected ControlWindow setMouseOverController(ControllerInterface<?> theController) {
		if (!mouseoverlist.contains(theController) && isVisible && theController.isVisible()) {
			mouseoverlist.add(theController);
		}
		isMouseOver = true;
		return this;
	}

	/**
	 * updates all controllers inside the control window if update is enabled.
	 * 
	 * @exclude
	 */
	public void update() {
		((ControllerInterface<?>) _myTabs.get(0)).update();
		for (int i = 1; i < _myTabs.size(); i++) {
			((Tab) _myTabs.get(i)).update();
		}
	}

	/**
	 * enable or disable the update function of a control window.
	 */
	public void setUpdate(boolean theFlag) {
		isUpdate = theFlag;
		for (int i = 0; i < _myTabs.size(); i++) {
			((ControllerInterface<?>) _myTabs.get(i)).setUpdate(theFlag);
		}
	}

	/**
	 * check the update status of a control window.
	 */
	public boolean isUpdate() {
		return isUpdate;
	}

	public ControlWindow addCanvas(ControlWindowCanvas theCanvas) {
		_myControlWindowCanvas.add(theCanvas);
		theCanvas.setControlWindow(this);
		theCanvas.setup(_myApplet);
		return this;
	}

	public ControlWindow removeCanvas(ControlWindowCanvas theCanvas) {
		_myControlWindowCanvas.remove(theCanvas);
		return this;
	}

	private boolean isReset = false;

	public ControlWindow pre() {
		if (_myFrameCount + 1 < _myApplet.frameCount) {
			if (isReset) {
				resetMouseOver();
				isReset = false;
			}
		} else {
			isReset = true;
		}
		if (isVisible) {
			if (isPAppletWindow) {
				if (isDrawBackground) {
					_myApplet.background(background);
				}
			}
		}
		return this;
	}

	/**
	 * enable smooth controlWindow rendering.
	 */
	public ControlWindow smooth() {
		if (isPAppletWindow) {
			_myApplet.smooth();
		}
		return this;
	}

	/**
	 * disable smooth controlWindow rendering.
	 */
	public ControlWindow noSmooth() {
		if (isPAppletWindow) {
			_myApplet.noSmooth();
		}
		return this;
	}

	/**
	 * @exclude draw content.
	 */
	public void draw() {

		_myFrameCount = _myApplet.frameCount;
		if (controlP5.blockDraw == false) {

			updateEvents();
			if (isVisible) {

				// TODO save stroke, noStroke, fill, noFill, strokeWeight
				// parameters and restore after drawing controlP5 elements.

				int myRectMode = _myApplet.g.rectMode;
				int myEllipseMode = _myApplet.g.ellipseMode;
				int myImageMode = _myApplet.g.imageMode;
				_myApplet.pushStyle();
				_myApplet.rectMode(PConstants.CORNER);
				_myApplet.ellipseMode(PConstants.CORNER);
				_myApplet.imageMode(PConstants.CORNER);
				_myApplet.noStroke();
				// TODO next section conflicts with Android
				if (_myApplet instanceof PAppletWindow) {
					_myApplet.background(background);
				}

				if (_myDrawable != null) {
					_myDrawable.draw(_myApplet);
				}

				for (int i = 0; i < _myControlWindowCanvas.size(); i++) {
					if ((_myControlWindowCanvas.get(i)).mode() == ControlWindowCanvas.PRE) {
						(_myControlWindowCanvas.get(i)).draw(_myApplet);
					}
				}

				_myApplet.noStroke();
				_myApplet.noFill();
				int myOffsetX = (int) getPositionOfTabs().x;
				int myOffsetY = (int) getPositionOfTabs().y;
				int myHeight = 0;
				if (_myTabs.size() > 0) {
					for (int i = 1; i < _myTabs.size(); i++) {
						if (((Tab) _myTabs.get(i)).isVisible()) {
							if (myHeight < ((Tab) _myTabs.get(i)).height()) {
								myHeight = ((Tab) _myTabs.get(i)).height();
							}
							if (myOffsetX > (component().getWidth()) - ((Tab) _myTabs.get(i)).width()) {
								myOffsetY += myHeight + 1;
								myOffsetX = (int) getPositionOfTabs().x;
								myHeight = 0;
							}

							((Tab) _myTabs.get(i)).setOffset(myOffsetX, myOffsetY);

							if (((Tab) _myTabs.get(i)).isActive()) {
								((Tab) _myTabs.get(i)).draw(_myApplet);
							}

							if (((Tab) _myTabs.get(i)).updateLabel()) {
								((Tab) _myTabs.get(i)).drawLabel(_myApplet);
							}
							myOffsetX += ((Tab) _myTabs.get(i)).width();
						}
					}
					((ControllerInterface<?>) _myTabs.get(0)).draw(_myApplet);
				}
				for (int i = 0; i < _myControlWindowCanvas.size(); i++) {
					if ((_myControlWindowCanvas.get(i)).mode() == ControlWindowCanvas.POST) {
						(_myControlWindowCanvas.get(i)).draw(_myApplet);
					}
				}

				pmouseX = mouseX;
				pmouseY = mouseY;

				// draw Tooltip here.
				controlP5.getTooltip().draw(this);
				_myApplet.rectMode(myRectMode);
				_myApplet.ellipseMode(myEllipseMode);
				_myApplet.imageMode(myImageMode);
				_myApplet.popStyle();
			}
		}

	}

	/**
	 * Adds a custom context to a ControlWindow. Use a custom class which implements the CDrawable
	 * interface
	 * 
	 * @see controlP5.CDrawable
	 * @param theDrawable CDrawable
	 */
	public ControlWindow setContext(CDrawable theDrawable) {
		_myDrawable = theDrawable;
		return this;
	}

	/**
	 * returns the name of the control window.
	 */
	public String name() {
		return _myName;
	}

	/**
	 * @exclude
	 * @param theMouseEvent MouseEvent
	 */
	public void mouseEvent(MouseEvent theMouseEvent) {
		if (isMouse) {
			mouseX = theMouseEvent.getX();
			mouseY = theMouseEvent.getY();
			if (theMouseEvent.getID() == MouseEvent.MOUSE_PRESSED) {
				mousePressedEvent();

			}
			if (theMouseEvent.getID() == MouseEvent.MOUSE_RELEASED) {
				mouseReleasedEvent();
			}
		}
	}

	private void mousePressedEvent() {
		if (isVisible) {
			mousePressed = true;
			for (int i = 0; i < _myTabs.size(); i++) {
				if (((ControllerInterface<?>) _myTabs.get(i)).setMousePressed(true)) {
					mouselock = true;
					return;
				}
			}
		}
	}

	private void mouseReleasedEvent() {
		if (isVisible) {
			mousePressed = false;
			mouselock = false;
			for (int i = 0; i < _myTabs.size(); i++) {
				((ControllerInterface<?>) _myTabs.get(i)).setMousePressed(false);
			}
		}
	}

	public ControlWindow disableMouseWheel() {
		mousewheel = false;
		return this;
	}

	public ControlWindow enableMouseWheel() {
		mousewheel = true;
		return this;
	}

	public boolean isMouseWheel() {
		return mousewheel;
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@ControlP5.Invisible public void mouseWheelMoved(MouseWheelEvent e) {
		if (mousewheel && isMouseOver()) {
			mouseWheelMoved = e.getWheelRotation();
		}
	}

	@SuppressWarnings("unchecked") private void handleMouseWheelMoved() {
		if (mouseWheelMoved != 0) {
			CopyOnWriteArrayList<ControllerInterface<?>> mouselist = new CopyOnWriteArrayList<ControllerInterface<?>>(mouseoverlist);
			for (ControllerInterface<?> c : mouselist) {
				if (c.isVisible()) {
					if (c instanceof Controller) {
						((Controller) c).onScroll(mouseWheelMoved);
					}
					if (c instanceof ControllerGroup) {
						((ControllerGroup) c).onScroll(mouseWheelMoved);
					}
					if (c instanceof Slider) {
						((Slider) c).scrolled(mouseWheelMoved);
					} else if (c instanceof Knob) {
						((Knob) c).scrolled(mouseWheelMoved);
					} else if (c instanceof Numberbox) {
						((Numberbox) c).scrolled(mouseWheelMoved);
					} else if (c instanceof ListBox) {
						((ListBox) c).scrolled(mouseWheelMoved);
					} else if (c instanceof DropdownList) {
						((DropdownList) c).scrolled(mouseWheelMoved);

					} else if (c instanceof Textarea) {
						((Textarea) c).scrolled(mouseWheelMoved);
					}
					break;
				}
			}
		}
		mouseWheelMoved = 0;
	}

	/**
	 * @exclude
	 * @param theCoordinates
	 */
	@ControlP5.Invisible public void multitouch(int[][] theCoordinates) {
		for (int n = 0; n < theCoordinates.length; n++) {
			mouseX = theCoordinates[n][0];
			mouseY = theCoordinates[n][1];
			if (isVisible) {
				if (theCoordinates[n][2] == MouseEvent.MOUSE_PRESSED) {
					mousePressed = true;
					for (int i = 0; i < _myTabs.size(); i++) {
						if (((ControllerInterface<?>) _myTabs.get(i)).setMousePressed(true)) {
							mouselock = true;
							ControlP5.logger().finer(" mouselock = " + mouselock);
							return;
						}
					}

				}
				if (theCoordinates[n][2] == MouseEvent.MOUSE_RELEASED) {
					mousePressed = false;
					mouselock = false;
					for (int i = 0; i < _myTabs.size(); i++) {
						((ControllerInterface<?>) _myTabs.get(i)).setMousePressed(false);
					}
				}
			}
		}
	}

	public boolean isMousePressed() {
		return mousePressed;
	}

	/**
	 * @exclude
	 * @param theKeyEvent KeyEvent
	 */
	public void keyEvent(KeyEvent theKeyEvent) {
		for (int i = 0; i < _myTabs.size(); i++) {
			((ControllerInterface<?>) _myTabs.get(i)).keyEvent(theKeyEvent);
		}
	}

	/**
	 * set the color for the controller while active.
	 */
	public ControlWindow setColorActive(int theColor) {
		color.setActive(theColor);
		for (int i = 0; i < getTabs().size(); i++) {
			((Tab) getTabs().get(i)).setColorActive(theColor);
		}
		return this;
	}

	/**
	 * set the foreground color of the controller.
	 */
	public ControlWindow setColorForeground(int theColor) {
		color.setForeground(theColor);
		for (int i = 0; i < getTabs().size(); i++) {
			((Tab) getTabs().get(i)).setColorForeground(theColor);
		}
		return this;
	}

	/**
	 * set the background color of the controller.
	 */
	public ControlWindow setColorBackground(int theColor) {
		color.setBackground(theColor);
		for (int i = 0; i < getTabs().size(); i++) {
			((Tab) getTabs().get(i)).setColorBackground(theColor);
		}
		return this;
	}

	/**
	 * set the color of the text label of the controller.
	 */
	public ControlWindow setColorLabel(int theColor) {
		color.setCaptionLabel(theColor);
		for (int i = 0; i < getTabs().size(); i++) {
			((Tab) getTabs().get(i)).setColorLabel(theColor);
		}
		return this;
	}

	/**
	 * set the color of the values.
	 */
	public ControlWindow setColorValue(int theColor) {
		color.setValueLabel(theColor);
		for (int i = 0; i < getTabs().size(); i++) {
			((Tab) getTabs().get(i)).setColorValue(theColor);
		}
		return this;
	}

	/**
	 * set the background color of the control window.
	 */
	public ControlWindow setBackground(int theValue) {
		background = theValue;
		return this;
	}

	/**
	 * get the papplet instance of the ControlWindow.
	 */
	public PApplet papplet() {
		return _myApplet;
	}

	public Component component() {
		return papplet();
	}

	/**
	 * set the title of a control window. only applies to control windows of type PAppletWindow.
	 */
	public ControlWindow setTitle(String theTitle) {
		if (_myApplet instanceof PAppletWindow) {
			((PAppletWindow) _myApplet).setTitle(theTitle);
		}
		return this;
	}

	/**
	 * shows the xy coordinates displayed in the title of a control window. only applies to control
	 * windows of type PAppletWindow.
	 * 
	 * @param theFlag
	 */
	public ControlWindow showCoordinates() {
		if (_myApplet instanceof PAppletWindow) {
			((PAppletWindow) _myApplet).showCoordinates();
		}
		return this;
	}

	/**
	 * hide the xy coordinates displayed in the title of a control window. only applies to control
	 * windows of type PAppletWindow.
	 * 
	 * @param theFlag
	 */
	public ControlWindow hideCoordinates() {
		if (_myApplet instanceof PAppletWindow) {
			((PAppletWindow) _myApplet).hideCoordinates();
		}
		return this;
	}

	/**
	 * hide the controllers and tabs of the ControlWindow.
	 */
	public ControlWindow hide() {
		isVisible = false;
		isMouseOver = false;
		if (isPAppletWindow) {
			((PAppletWindow) _myApplet).visible(false);
		}
		return this;
	}

	/**
	 * set the draw mode of a control window. a separate control window is only updated when in
	 * focus. to update the context of the window continuously, use
	 * yourControlWindow.setUpdateMode(ControlWindow.NORMAL); otherwise use
	 * yourControlWindow.setUpdateMode(ControlWindow.ECONOMIC); for an economic, less cpu intensive
	 * update.
	 * 
	 * @param theMode
	 */
	public ControlWindow setUpdateMode(int theMode) {
		if (isPAppletWindow) {
			((PAppletWindow) _myApplet).setMode(theMode);
		}
		return this;
	}

	/**
	 * sets the frame rate of the control window.
	 * 
	 * @param theFrameRate
	 * @return ControlWindow
	 */
	public ControlWindow frameRate(int theFrameRate) {
		_myApplet.frameRate(theFrameRate);
		return this;
	}

	public ControlWindow show() {
		isVisible = true;
		if (isPAppletWindow) {
			((PAppletWindow) _myApplet).visible(true);
		}
		return this;
	}

	/**
	 * by default the background of a controlWindow is filled with a background color every frame.
	 * to enable or disable the background from drawing, use setDrawBackgorund(true/false).
	 * 
	 * @param theFlag
	 * @return ControlWindow
	 */
	public ControlWindow setDrawBackground(boolean theFlag) {
		isDrawBackground = theFlag;
		return this;
	}

	public boolean isDrawBackground() {
		return isDrawBackground;
	}

	public boolean isVisible() {
		return isVisible;
	}

	protected boolean isControllerActive(Controller<?> theController) {
		if (isControllerActive == null) {
			return false;
		}
		return isControllerActive.equals(theController);
	}

	protected ControlWindow setControllerActive(Controller<?> theController) {
		isControllerActive = theController;
		return this;
	}

	public ControlWindow toggleUndecorated() {
		setUndecorated(!isUndecorated());
		return this;
	}

	public ControlWindow setUndecorated(boolean theFlag) {
		if (theFlag != isUndecorated()) {
			isUndecorated = theFlag;
			_myApplet.frame.removeNotify();
			_myApplet.frame.setUndecorated(isUndecorated);
			_myApplet.setSize(_myApplet.width, _myApplet.height);
			_myApplet.setBounds(0, 0, _myApplet.width, _myApplet.height);
			_myApplet.frame.setSize(_myApplet.width, _myApplet.height);
			_myApplet.frame.addNotify();
		}
		return this;
	}

	public Frame getFrame() {
		return _myApplet.frame;
	}

	public boolean isUndecorated() {
		return isUndecorated;
	}

	public ControlWindow setPosition(int theX, int theY) {
		return setLocation(theX, theY);
	}

	public ControlWindow setLocation(int theX, int theY) {
		_myApplet.frame.setLocation(theX, theY);
		return this;
	}

	public Pointer getPointer() {
		return _myPointer;
	}

	public ControlWindow disablePointer() {
		_myPointer.disable();
		return this;
	}

	public ControlWindow enablePointer() {
		_myPointer.enable();
		return this;
	}

	/**
	 * A pointer by default is linked to the mouse and stores the x and y position as well as the
	 * pressed and released state. The pointer can be accessed by its getter method
	 * {@link ControlWindow#getPointer()}. Then use {@link controlP5.ControlWindow#set(int, int)} to
	 * alter its position or invoke { {@link controlP5.ControlWindow#pressed()} or
	 * {@link controlP5.ControlWindow#released()} to change its state. To disable the mouse and
	 * enable the Pointer use {@link controlP5.ControlWindow#enable()} and
	 * {@link controlP5.ControlWindow#disable()} to default back to the mouse as input parameter.
	 */
	public class Pointer {

		public Pointer setX(int theX) {
			mouseX = theX;
			return this;
		}

		public Pointer setY(int theY) {
			mouseY = theY;
			return this;
		}

		public int getY() {
			return mouseY;
		}

		public int getX() {
			return mouseX;
		}

		public int getPreviousX() {
			return pmouseX;
		}

		public int getPreviousY() {
			return pmouseY;
		}

		public Pointer set(int theX, int theY) {
			setX(theX);
			setY(theY);
			return this;
		}

		public Pointer pressed() {
			mousePressedEvent();
			return this;
		}

		public Pointer released() {
			mouseReleasedEvent();
			return this;
		}

		public void enable() {
			isMouse = false;
		}

		public void disable() {
			isMouse = true;
		}

		public boolean isEnabled() {
			return !isMouse;
		}
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public ControllerList tabs() {
		return _myTabs;
	}

	/**
	 * @exclude
	 * @deprecated
	 */
	@Deprecated public Tab tab(String theTabName) {
		return controlP5.getTab(this, theTabName);
	}

	/**
	 * @deprecated
	 * @exclude
	 */
	@Deprecated public Tab currentTab() {
		for (int i = 1; i < _myTabs.size(); i++) {
			if (((Tab) _myTabs.get(i)).isActive()) {
				return (Tab) _myTabs.get(i);
			}
		}
		return null;
	}

	/**
	 * @exclude
	 * @deprecated
	 * @param theMode
	 */
	@Deprecated public void setMode(int theMode) {
		setUpdateMode(theMode);
	}

}