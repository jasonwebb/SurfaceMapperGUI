/**
 * Part of the SurfaceMapper library: http://surfacemapper.sourceforge.net/
 * Copyright (c) 2011-12 Ixagon AB 
 *
 * This source is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This code is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * A copy of the GNU General Public License is available on the World
 * Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also
 * obtain it by writing to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

package ixagon.SurfaceMapper;

import java.awt.Rectangle;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.core.PGraphics2D;
import processing.core.PVector;
import processing.xml.XMLElement;
import processing.xml.XMLWriter;
import codeanticode.glgraphics.GLGraphicsOffScreen;
import codeanticode.glgraphics.GLTexture;

public class SurfaceMapper {
	public final String VERSION = "1";

	private PApplet parent;
	private ArrayList<SuperSurface> surfaces;
	private ArrayList<SuperSurface> selectedSurfaces;
	
	
	private boolean allowUserInput;
	

	final static public int MODE_RENDER = 0;
	final static public int MODE_CALIBRATE = 1;
	public int MODE = MODE_CALIBRATE;
	private int snapDistance = 30;
	private int selectionDistance = 15; 
	private int selectionMouseColor;
	
	final static public int CMD = 157;
	private int numAddedSurfaces = 0;

	private boolean snap = true;

	private PVector prevMouse = new PVector();
	private boolean ctrlDown;
	private boolean altDown;
	private boolean grouping;
	
	private GLTexture backgroundTexture;
	private boolean usingBackground = false;
	
	private Rectangle selectionTool;
	private PVector startPos;
	private boolean isDragging;
	private boolean disableSelectionTool;
	
	private int[] ccolor;
	private int width;
	private int height;
	
	private PFont idFont;

	private boolean debug = true;

	private boolean shaking;
	private int shakeStrength;
	private int shakeSpeed;
	private float shakeAngle;
	private float shakeZ;
	
	/**
	 * Create instance of IxKeystone
	 * @param parent
	 * @param width
	 * @param height
	 * @param registerMouseEvent
	 */

	public SurfaceMapper(PApplet parent, int width, int height) {
		this.parent = parent;
		this.enableMouseEvents();
		this.parent.registerKeyEvent(this);
		this.width = width;
		this.height = height;
		this.ccolor = new int[0];
		this.idFont = parent.createFont("Verdana", 80);
		this.setSelectionMouseColor(0xFFCCCCCC);
		surfaces = new ArrayList<SuperSurface>();
		selectedSurfaces = new ArrayList<SuperSurface>();
		allowUserInput = true;

		// check the renderer type
		// issue a warning if its PGraphics2D
		PGraphics pg = (PGraphics) parent.g;
		if ((pg instanceof PGraphics2D)) {
			PApplet.println("Keystone --> The keystone library will not work with PGraphics2D as the renderer because it relies on texture mapping.");
		}
		
		parent.addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
		    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
		      mouseWheelAction(evt.getWheelRotation());
		  }}); 
	}
	
	/**
	 * Render method used when calibrating. Shouldn't be used for final rendering.
	 * @param glos
	 */
	public void render(GLGraphicsOffScreen glos) {
		glos.beginDraw();
		glos.clear(50);
		glos.endDraw();
		if (MODE == MODE_CALIBRATE) {
			parent.cursor();
			glos.beginDraw();
			
			if(this.isUsingBackground()){
				glos.image(backgroundTexture, 0, 0, width, height);
			}
			
			glos.fill(0,40);
			glos.noStroke();
			glos.rect(-2,-2,width+4,height+4);
			glos.stroke(255, 255, 255, 40);
			glos.strokeWeight(1);
			float gridRes = 32.0f;
			
			float step = (float)(width/gridRes);

			for (float i = 1; i < width; i += step) {
				glos.line(i, 0, i, parent.height);
			}
			
			step = (float)(height/gridRes);
			
			for (float i = 1; i < width; i += step) {
				glos.line(0, i, parent.width, i);
			}
			
			glos.stroke(255);
			glos.strokeWeight(2);
			glos.line(1,1,width-1,1);
			glos.line(width-1,1,width-1, height-1);
			glos.line(1,height-1,width-1,height-1);
			glos.line(1,1,1,height-1);
			
		
			
			if (selectionTool != null && !disableSelectionTool) {
				glos.stroke(255,100);
				glos.strokeWeight(1);
				glos.fill(100, 100, 255, 50);
				glos.rect(selectionTool.x, selectionTool.y, selectionTool.width, selectionTool.height);
				glos.noStroke();
			}
			
			glos.endDraw();

			for (int i = 0; i < surfaces.size(); i++) {
				surfaces.get(i).render(glos);
			}
			
			//Draw circles for SelectionDistance or SnapDistance (snap if CMD is down)
			glos.beginDraw();
			if(!ctrlDown){
				glos.ellipseMode(PApplet.CENTER);
				glos.fill(this.getSelectionMouseColor(),100);
				glos.noStroke();
				glos.ellipse(parent.mouseX, parent.mouseY, this.getSelectionDistance()*2, this.getSelectionDistance()*2);
			}else{
				glos.ellipseMode(PApplet.CENTER);
				glos.fill(255,0,0,100);
				glos.noStroke();
				glos.ellipse(parent.mouseX, parent.mouseY, this.getSnapDistance()*2, this.getSnapDistance()*2);
			}
			glos.endDraw();
			
		} else {
			parent.noCursor();
		}
	}
	
	/**
	 * Shake all surfaces with max Z-displacement strength, vibration-speed speed, and shake decline fallOfSpeed. (min 0, max 1000 (1000 = un-ending shaking))
	 * @param strength
	 * @param speed
	 * @param fallOfSpeed
	 */
	public void setShakeAll(int strength, int speed, int fallOfSpeed){
		for(SuperSurface ss : surfaces){
			ss.setShake(strength, speed, fallOfSpeed);
		}
	}
	
	/**
	 * Update shaking for all surfaces
	 */
	public void shake(){
		for(SuperSurface ss : surfaces){
			ss.shake();
		}
	}
	
	/**
	 * Get font for drawing text
	 * @return
	 */
	public PFont getIdFont(){
		return idFont;
	}
	
	/**
	 * Unregisters Mouse Event listener for the SurfaceMapper
	 */
	public void disableMouseEvents(){
		this.parent.unregisterMouseEvent(this);
	}
	
	/**
	 * Registers Mouse Event listener for the SurfaceMapper
	 */
	public void enableMouseEvents(){
		this.parent.registerMouseEvent(this);
	}
	
	/**
	 * Get current max distance for an object to be selected
	 * @return
	 */
	public int getSelectionDistance(){
		return selectionDistance;
	}
	
	/**
	 * Set the max distance for an object to be selected
	 * @param selectionDistance
	 */
	public void setSelectionDistance(int selectionDistance){
		this.selectionDistance = selectionDistance;
	}
	
	public void setSelectionMouseColor(int selectionMouseColor) {
		this.selectionMouseColor = selectionMouseColor;
	}

	public int getSelectionMouseColor() {
		return selectionMouseColor;
	}

	/**
	 * Returns the array of colors used in calibration mode for coloring the surfaces.
	 * @return
	 */
	public int[] getColor() {
		return ccolor;
	}
	
	/**
	 * Set the array of colors used in calibration mode for coloring the surfaces.
	 * @param ccolor
	 */
	public void setColor(int[] ccolor) {
		this.ccolor = ccolor;
	}
	
	/**
	 * Returns the rectangle used for selecting surfaces
	 * @return
	 */
	public Rectangle getSelectionTool() {
		return selectionTool;	
	}
	
	/**
	 * Optionally set a background image in calibration mode. 
	 * @param tex
	 */
	public void setBackground(GLTexture tex){
		this.backgroundTexture = tex;
		this.setUsingBackground(true);
	}
	
	/**
	 * Boolean used to know if the background image should be rendered in calibration mode.
	 * @return
	 */
	public boolean isUsingBackground(){
		return usingBackground;
	}
	
	/**
	 * Set if background image should rendered in calibration mode
	 * @param val
	 */
	public void setUsingBackground(boolean val){
		usingBackground = val;
	}

	/**
	 * Creates a Quad surface with perspective transform. Res is the amount of subdivisioning. Returns the surface after it has been created.
	 * @param res
	 * @return
	 */
	public SuperSurface createQuadSurface(int res) {
		SuperSurface s = new SuperSurface(SuperSurface.QUAD, parent, this, parent.mouseX, parent.mouseY, res, numAddedSurfaces);
		if (ccolor.length > 0)
			s.setColor(ccolor[numAddedSurfaces % ccolor.length]);
		s.setModeCalibrate();
		surfaces.add(s);
		numAddedSurfaces++;
		return s;
	}
	
	/**
	 * Creates a Quad surface at X/Y with perspective transform. Res is the amount of subdivisioning. Returns the surface after it has been created.
	 * @param res
	 * @param x
	 * @param y
	 * @return
	 */
	public SuperSurface createQuadSurface(int res, int x, int y) {
		SuperSurface s = new SuperSurface(SuperSurface.QUAD, parent, this, x, y, res, numAddedSurfaces);
		if (ccolor.length > 0)
			s.setColor(ccolor[numAddedSurfaces % ccolor.length]);
		s.setModeCalibrate();
		surfaces.add(s);
		numAddedSurfaces++;
		return s;
	}
	
	/**
	 * Creates a Bezier surface with perspective transform. Res is the amount of subdivisioning. Returns the surface after it has been created.
	 * @param res
	 * @return
	 */
	public SuperSurface createBezierSurface(int res) {
		SuperSurface s = new SuperSurface(SuperSurface.BEZIER, parent, this, parent.mouseX, parent.mouseY, res, numAddedSurfaces);
		if (ccolor.length > 0)
			s.setColor(ccolor[numAddedSurfaces % ccolor.length]);
		s.setModeCalibrate();
		surfaces.add(s);
		numAddedSurfaces++;
		return s;
	}
	
	/**
	 * Creates a Bezier surface at X/Y with perspective transform. Res is the amount of subdivisioning. Returns the surface after it has been created.
	 * @param res
	 * @param x
	 * @param y
	 * @return
	 */
	public SuperSurface createBezierSurface(int res, int x, int y) {
		SuperSurface s = new SuperSurface(SuperSurface.BEZIER, parent, this, x, y, res, numAddedSurfaces);
		if (ccolor.length > 0)
			s.setColor(ccolor[numAddedSurfaces % ccolor.length]);
		s.setModeCalibrate();
		surfaces.add(s);
		numAddedSurfaces++;
		return s;
	}
	
	/**
	 * Get previous mouse position
	 * @return
	 */
	public PVector getPrevMouse() {
		return prevMouse;
	}
	
	/**
	 * Set previous mouse position
	 * @param x
	 * @param y
	 */
	public void setPrevMouse(float x, float y) {
		prevMouse = new PVector(x, y);
	}
	
	/**
	 * Set the selection tool
	 * @param r
	 */
	public void setSelectionTool(Rectangle r) {
		selectionTool = r;
	}
	
	/**
	 * Set the selection tool
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 */
	public void setSelectionTool(int x, int y, int width, int height) {
		selectionTool = new Rectangle(x, y, width, height);
	}
	
	/**
	 * Is the selection tool disabled?
	 * @return
	 */
	public boolean getDisableSelectionTool() {
		return disableSelectionTool;
	}
	
	/**
	 * Enable/disable selection tool
	 * @param disableSelectionTool
	 */
	public void setDisableSelectionTool(boolean disableSelectionTool) {
		this.disableSelectionTool = disableSelectionTool;
	}
	
	/**
	 * Is CTRL pressed? 
	 * @return
	 */
	public boolean isCtrlDown() {
		return ctrlDown;
	}
	
	/**
	 * Is ALT pressed?
	 * @return
	 */
	public boolean isAltDown(){
		return altDown;
	}
	
	/**
	 * @return
	 */
	public boolean isDragging() {
		return isDragging;
	}
	
	/**
	 * @param isDragging
	 */
	public void setIsDragging(boolean isDragging) {
		this.isDragging = isDragging;
	}
	
	/**
	 * Add a surface to selected surfaces
	 * @param cps
	 */
	public void addSelectedSurface(SuperSurface cps) {
		selectedSurfaces.add(cps);
	}

	/**
	 * Get the selected surfaces
	 * @return
	 */
	public ArrayList<SuperSurface> getSelectedSurfaces() {
		return selectedSurfaces;
	}
	
	/**
	 * Clears the arraylist of selected surfaces.
	 */
	public void clearSelectedSurfaces() {
		selectedSurfaces.clear();
	}
	
	/**
	 * Get all surfaces
	 * @return surfaces
	 */
	public ArrayList<SuperSurface> getSurfaces() {
		return surfaces;
	}
	
	/**
	 * Remove all surfaces
	 */
	public void clearSurfaces(){
		selectedSurfaces.clear();
		surfaces.clear();
	}

	/**
	 * Get surface by Id.
	 * @param id
	 * @return
	 */
	public SuperSurface getSurfaceById(int id) {
		SuperSurface cps = null;
		for (int i = 0; i < surfaces.size(); i++) {
			if (surfaces.get(i).getId() == id) {
				return surfaces.get(i);
			}
		}
		return cps;
	}
	
	/**
	 * Select the surface. Deselects all previously selected surfaces.
	 * @param SuperSurface
	 */
	public void setSelectedSurface(SuperSurface cps) {
		for (SuperSurface ss : selectedSurfaces) {
			ss.setSelected(false);
		}
		selectedSurfaces.clear();
		cps.setSelected(true);
		selectedSurfaces.add(cps);
	}

	/**
	 * Check if coordinates is inside any of the surfaces.
	 * @param mX
	 * @param mY
	 * @return
	 */
	public boolean findActiveSurface(float mX, float mY) {
		for (int i = 0; i < surfaces.size(); i++) {
			SuperSurface surface = surfaces.get(i);

			if (surface.isInside(mX, mY)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Check which mode is enabled (render or calibrate)
	 * @return
	 */
	public int getMode() {
		return this.MODE;
	}
	
	/**
	 * Set mode to calibrate
	 */
	public void setModeCalibrate() {
		this.MODE = SurfaceMapper.MODE_CALIBRATE;
		for (SuperSurface s : surfaces) {
			s.setModeCalibrate();
		}
	}
	
	/**
	 * Set mode to render
	 */
	public void setModeRender() {
		this.MODE = SurfaceMapper.MODE_RENDER;
		for (SuperSurface s : surfaces) {
			s.setModeRender();
		}
	}
	
	/**
	 * Toggle the mode
	 */
	public void toggleCalibration() {
		if (MODE == MODE_RENDER)
			MODE = MODE_CALIBRATE;
		else
			MODE = MODE_RENDER;

		for (SuperSurface s : surfaces) {
			if (MODE == MODE_CALIBRATE)
				s.setModeCalibrate();
			else
				s.setModeRender();
		}
	}

	/**
	 * Toggle if corner snapping is used
	 */
	public void toggleSnap() {
		snap = !snap;
	}
	
	/**
	 * See if snap mode is used
	 * @return
	 */
	public boolean getSnap() {
		return snap;
	}

	/**
	 * Manually set corner snap mode
	 * @param snap
	 */
	public void setSnap(boolean snap) {
		this.snap = snap;
	}

	/**
	 * See the snap distance
	 * @return
	 */
	public int getSnapDistance() {
		return snapDistance;
	}

	/**
	 * Set corner snap distance
	 * @param snapDistance
	 */
	public void setSnapDistance(int snapDistance) {
		this.snapDistance = snapDistance;
	}

	/**
	 * See if debug mode is on.
	 * @return
	 */
	public boolean getDebug() {
		return debug;
	}

	/**
	 * Manually set debug mode. (debug mode will print more to console)
	 * @param debug
	 */
	public void setDebug(boolean debug) {
		this.debug = debug;
	}

	public String version() {
		return VERSION;
	}

	/**
	 * Puts all projection mapping data in the XMLElement
	 * @param root
	 */
	public void save(XMLElement root) {
		root.setName("ProjectionMap");
		// create XML elements for each surface containing the resolution
		// and control point data
		for (SuperSurface s : surfaces) {
			XMLElement surf = new XMLElement();
			surf.setName("surface");
			surf.setInt("type", s.getSurfaceType());
			surf.setInt("id", s.getId());
			surf.setString("name", s.getSurfaceName());
			surf.setInt("res", s.getRes());
			surf.setBoolean("lock", s.isLocked());
			surf.setInt("horizontalForce", s.getHorizontalForce());
			surf.setInt("verticalForce", s.getVerticalForce());

			for (int i = 0; i < s.getCornerPoints().length; i++) {
				XMLElement cp = new XMLElement();
				cp.setName("cornerpoint");
				cp.setInt("i", i);
				cp.setFloat("x", s.getCornerPoint(i).x);
				cp.setFloat("y", s.getCornerPoint(i).y);
				surf.addChild(cp);

			}
			
			if(s.getSurfaceType() == SuperSurface.BEZIER){
				for(int i = 0; i < 8; i++){
					XMLElement bp = new XMLElement();
					bp.setName("bezierpoint");
					bp.setInt("i", i);
					bp.setFloat("x", s.getBezierPoint(i).x);
					bp.setFloat("y", s.getBezierPoint(i).y);
					surf.addChild(bp);
				}
			}
			root.addChild(surf);
		}
	}

	/**
	 * Save all projection mapping data to file
	 * @param filename
	 */
	public void save(String filename) {
		if (this.MODE == SurfaceMapper.MODE_CALIBRATE){
			XMLElement root = new XMLElement();
			this.save(root);
			try {
				OutputStream stream = parent.createOutput(parent.dataPath(filename));
				XMLWriter writer = new XMLWriter(stream);
				writer.write(root, true);
			} catch (Exception e) {
				PApplet.println(e.getStackTrace());
			}
		}
	}

	/**
	 * Load projection map from file
	 * @param filename
	 */
	public void load(String filename) {
		if (this.MODE == SurfaceMapper.MODE_CALIBRATE) {
			File f = new File(parent.dataPath(filename));
			if (f.exists()) {
				this.setGrouping(false);
				selectedSurfaces.clear();
				surfaces.clear();
				XMLElement root = new XMLElement(parent, parent.dataPath(filename));
				for (int i = 0; i < root.getChildCount(); i++) {
					SuperSurface loaded = new SuperSurface(root.getChild(i).getInt("type"), parent, this, root.getChild(i));
					loaded.setModeCalibrate();
					surfaces.add(loaded);
					if (loaded.getId() > numAddedSurfaces)
						numAddedSurfaces = loaded.getId() + 1;
				}
				if(this.getDebug()) PApplet.println("Projection layout loaded from " + filename + ". " + surfaces.size() + " surfaces were loaded!");
			} else {
				if(this.getDebug()) PApplet.println("ERROR loading XML! No projection layout exists!");
			}
		}

	}
	
	/**
	 * Move a point of a surface
	 * @param ss
	 * @param x
	 * @param y
	 */
	public void movePoint(SuperSurface ss, int x, int y){
		int index = ss.getSelectedCorner();
		
		ss.setCornerPoint(index, ss.getCornerPoint(index).x + x, ss.getCornerPoint(index).y + y);
		index = index*2;
		ss.setBezierPoint(index, ss.getBezierPoint(index).x + x, ss.getBezierPoint(index).y + y);
		index = index+1;
		ss.setBezierPoint(index, ss.getBezierPoint(index).x + x, ss.getBezierPoint(index).y + y);
	}
	
	/**
	 * Check if any user event is allowed
	 * @return
	 */
	public boolean isAllowUserInput() {
		return allowUserInput;
	}
	
	/**
	 * Set if any user event is allowed
	 * @param allowUserInput
	 */
	public void setAllowUserInput(boolean allowUserInput) {
		this.allowUserInput = allowUserInput;
	}
	
	/**
	 * Places the surface last in the surfaces array, i.e. on top.
	 * @param index
	 */
	public void bringSurfaceToFront(int index){
		SuperSurface s = surfaces.get(index);
		surfaces.remove(index);
		surfaces.add(s);
	}
	
	/**
	 * Check if multiple surfaces are being manipulated
	 * @return
	 */
	public boolean isGrouping(){
		return grouping;
	}
	
	/**
	 * Set if multiple surfaces are being manipulated
	 * @param grouping
	 */
	public void setGrouping(boolean grouping){
		this.grouping = grouping;
	}
	
	/**
	 * Handles Mouse Wheel input
	 * @param delta
	 */
	private void mouseWheelAction(int delta){
		if(allowUserInput && this.MODE == SurfaceMapper.MODE_CALIBRATE){
			if(delta < 0){
				if(ctrlDown){
					if(this.getSnapDistance() < 60){
						this.setSnapDistance(this.getSnapDistance()+2);
					}
				}else{
					if(this.getSelectionDistance() < 60)
						this.setSelectionDistance(this.getSelectionDistance()+2);
				}
			}
			if(delta > 0){
				if(ctrlDown){
					if(this.getSnapDistance() > 6){
						this.setSnapDistance(this.getSnapDistance()-2);
					}
				}else{
					if(this.getSelectionDistance() > 16)
						this.setSelectionDistance(this.getSelectionDistance()-2);
				}
			}
		}
	}
	
	/**
	 * MouseEvent method. Forwards the MouseEvent to ksMouseEvent if user input is allowed
	 * @param e
	 */
	public void mouseEvent(MouseEvent e) {
		if (allowUserInput) {
			ksMouseEvent(e);
		}
	}

	/**
	 * MouseEvent method.
	 * @param e
	 */
	public void ksMouseEvent(MouseEvent e) {
		if (this.MODE == SurfaceMapper.MODE_RENDER)
			return;

		int mX = e.getX();
		int mY = e.getY();

		switch (e.getID()) {
		case MouseEvent.MOUSE_PRESSED:
			if (this.MODE == SurfaceMapper.MODE_CALIBRATE) {
				startPos = new PVector(mX, mY);
				for (int i = surfaces.size() - 1; i >= 0; i--) {
					SuperSurface cps = surfaces.get(i);

					cps.setActivePoint(cps.getActiveCornerPointIndex(mX, mY));
					cps.setSelectedBezierControl(cps.getActiveBezierPointIndex(mX, mY));

					if (cps.getActivePoint() >= 0 || cps.getSelectedBezierControl() >= 0) {
						if(grouping && !ctrlDown){
							if(!cps.isSelected()){
								for (SuperSurface ss : selectedSurfaces) {
									ss.setSelected(false);
								}
								grouping = false;
								selectedSurfaces.clear();
							}
						}
						
						disableSelectionTool = true;
						if (ctrlDown && grouping) {
							boolean actionTaken = false;
							if(cps.isSelected()){
								cps.setSelected(false);
								for(int j = selectedSurfaces.size() - 1; j >= 0; j-- ){
									if(cps.getId() == selectedSurfaces.get(j).getId()) selectedSurfaces.remove(j);
								}
								actionTaken = true;
							}
							if(!cps.isSelected() && !actionTaken){
								cps.setSelected(true);
								selectedSurfaces.add(cps);
								removeDuplicates(selectedSurfaces);
							}
						} else {
							if (grouping == false) {
								for (SuperSurface ss : selectedSurfaces) {
									ss.setSelected(false);
								}
								selectedSurfaces.clear();
								cps.setSelected(true);
								selectedSurfaces.add(cps);
							}
						}
						
						// no need to loop through all surfaces unless multiple
						// surfaces has been selected
						if (!grouping)
							break;
					}
				}
				if (grouping) {
					int moveClick = 0;
					for (SuperSurface ss : selectedSurfaces) {
						if (ss.getActivePoint() == 2000)
							moveClick++;
					}
				//	PApplet.println(moveClick);
					if (moveClick > 0) {
						for (SuperSurface ss : selectedSurfaces) {
							ss.setActivePoint(2000);
					//		PApplet.println(ss.getActivePoint());
						}
					}
				}
				
			}

			break;

		case MouseEvent.MOUSE_DRAGGED:
			if (this.MODE == SurfaceMapper.MODE_CALIBRATE) {

				float deltaX = mX - prevMouse.x;
				float deltaY = mY - prevMouse.y;

				// Right mouse button drags very slowly.
				if (e.getButton() == MouseEvent.BUTTON3) {
					deltaX *= 0.1;
					deltaY *= 0.1;
				}
				
				boolean[] movingPolys = new boolean[surfaces.size()];
				int iteration = 0;
				for (SuperSurface ss : surfaces) {
					
					movingPolys[iteration] = false;
					// Don't allow editing of surface if it's locked!
					if (!ss.isLocked()) {
						if(ss.getSelectedBezierControl() != -1){
							ss.setBezierPoint(ss.getSelectedBezierControl(), ss.getBezierPoint(ss.getSelectedBezierControl()).x + deltaX, ss.getBezierPoint(ss.getSelectedBezierControl()).y + deltaY);
						}else if (ss.getActivePoint() != -1) {
							// special case.
							// index 2000 is the center point so move all four
							// corners.
							if (ss.getActivePoint() == 2000) {
								// If multiple surfaces are selected, ALT need
								// to be pressed in order to move them.
								if ((grouping && altDown) || selectedSurfaces.size() == 1) {
									for (int i = 0; i < 4; i++) {
										ss.setCornerPoint(i, ss.getCornerPoint(i).x + deltaX, ss.getCornerPoint(i).y + deltaY);
										ss.setBezierPoint(i, ss.getBezierPoint(i).x + deltaX, ss.getBezierPoint(i).y + deltaY);
										ss.setBezierPoint(i+4, ss.getBezierPoint(i+4).x + deltaX, ss.getBezierPoint(i+4).y + deltaY);
									}	
									movingPolys[iteration] = true;
								}
							} else {
								// Move a corner point.
								int index =  ss.getActivePoint();
								ss.setCornerPoint(index, ss.getCornerPoint(ss.getActivePoint()).x + deltaX, ss.getCornerPoint(ss.getActivePoint()).y + deltaY);
								index = index*2;
								ss.setBezierPoint(index, ss.getBezierPoint(index).x + deltaX, ss.getBezierPoint(index).y + deltaY);
								index = index+1;
								ss.setBezierPoint(index, ss.getBezierPoint(index).x + deltaX, ss.getBezierPoint(index).y + deltaY);
								movingPolys[iteration] = true;
							}
						}
						
					}
					iteration++;
				}

				for (int i = 0; i < movingPolys.length; i++) {
					if (movingPolys[i]) {
						disableSelectionTool = true;
						break;
					}
				}

				if (altDown)
					disableSelectionTool = true;

				if (!disableSelectionTool) {
					selectionTool = new Rectangle((int) startPos.x, (int) startPos.y, (int) (mX - startPos.x), (int) (mY - startPos.y));
					
					PVector sToolPos = new PVector(selectionTool.x, selectionTool.y);

					if (selectionTool.x < selectionTool.x - selectionTool.width) {
						sToolPos.set(sToolPos.x + selectionTool.width, sToolPos.y, 0);
					}
					if (selectionTool.y < selectionTool.y - selectionTool.height) {
						sToolPos.set(sToolPos.x, sToolPos.y + selectionTool.height, 0);
					}

					for (SuperSurface cps : surfaces) {
						java.awt.Polygon p = cps.getPolygon();

						if (p.intersects(sToolPos.x, sToolPos.y, Math.abs(selectionTool.width), Math.abs(selectionTool.height))) {
							cps.setSelected(true);
							selectedSurfaces.add(cps);
							removeDuplicates(selectedSurfaces);
							grouping = true;
						} else {
							if (!ctrlDown) {
								cps.setSelected(false);
								selectedSurfaces.remove(cps);
							}
						}
					}
				}
				isDragging = true;
			}

			break;

		case MouseEvent.MOUSE_RELEASED:
			if (this.MODE == SurfaceMapper.MODE_CALIBRATE) {
				if (snap) {
					for (SuperSurface ss : selectedSurfaces) {
						if (ss.getActivePoint() != 2000 && ss.getActivePoint() != -1) {
							int closestIndex = -1;
							int cornerIndex = -1;
							float closestDist = this.getSnapDistance()+1;
							for (int j = 0; j < surfaces.size(); j++) {
								if(surfaces.get(j).getId() != ss.getId()){
									for (int i = 0; i < surfaces.get(j).getCornerPoints().length; i++) {
										float dist = PApplet.dist(ss.getCornerPoint(ss.getActivePoint()).x, ss.getCornerPoint(ss.getActivePoint()).y, surfaces.get(j).getCornerPoint(i).x,
												surfaces.get(j).getCornerPoint(i).y);
										if (dist < this.getSnapDistance()) {
											if(dist < closestDist){ 
												closestDist = dist;
												closestIndex = j;
												cornerIndex = i;
											}
										}
									}
								}
							}
							if(closestDist > -1 && closestDist < this.getSnapDistance()){
								ss.setCornerPoint(ss.getActivePoint(), surfaces.get(closestIndex).getCornerPoint(cornerIndex).x, surfaces.get(closestIndex).getCornerPoint(cornerIndex).y);
							}
						}
					}
					int selection = 0;
					for (SuperSurface cps : surfaces) {
						cps.setActivePoint(-1);
						if (cps.getActiveCornerPointIndex(mX, mY) != -1)
							selection++;
					}
					
					if (isDragging)
						selection++;

					if (selection == 0) {
						for (SuperSurface ss : selectedSurfaces) {
							ss.setSelected(false);
						}
						grouping = false;
						selectedSurfaces.clear();
					}
				}
				
			}
			startPos = new PVector(0, 0);
			selectionTool = null;
			disableSelectionTool = false;
			isDragging = false;
			break;

		}
		prevMouse = new PVector(mX, mY, 0);
	}

	/**
	 * KeyEvent method
	 * @param k
	 */
	public void keyEvent(KeyEvent k) {
		if (MODE == MODE_RENDER)
			return; // ignore everything unless we're in calibration mode

		switch (k.getID()) {
		case KeyEvent.KEY_RELEASED:

			switch (k.getKeyCode()) {

			case KeyEvent.VK_CONTROL:
			case CMD:
				ctrlDown = false;
				break;

			case KeyEvent.VK_ALT:
				altDown = false;
				break;
			}
			break;

		case KeyEvent.KEY_PRESSED:

			switch (k.getKeyCode()) {
			case '1':
				if (selectedSurfaces.size() == 1)
					selectedSurfaces.get(0).setSelectedCorner(0);
				break;

			case '2':
				if (selectedSurfaces.size() == 1)
					selectedSurfaces.get(0).setSelectedCorner(1);
				break;

			case '3':
				if (selectedSurfaces.size() == 1)
					selectedSurfaces.get(0).setSelectedCorner(2);
				break;

			case '4':
				if (selectedSurfaces.size() == 1)
					selectedSurfaces.get(0).setSelectedCorner(3);
				break;

			case KeyEvent.VK_UP:
				for (SuperSurface ss : selectedSurfaces) {
					movePoint(ss, 0,-1);
				}
				break;

			case KeyEvent.VK_DOWN:
				for (SuperSurface ss : selectedSurfaces) {
					movePoint(ss, 0, 1);
				}
				break;

			case KeyEvent.VK_LEFT:
				for (SuperSurface ss : selectedSurfaces) {
					movePoint(ss, -1, 0);
				}
				break;

			case KeyEvent.VK_RIGHT:
				for (SuperSurface ss : selectedSurfaces) {
					movePoint(ss, 1, 0);
				}
				break;
				/*
			case KeyEvent.VK_O:
				for (SuperSurface ss : selectedSurfaces) {
					ss.increaseResolution();
				}
				break;

			case KeyEvent.VK_P:
				for (SuperSurface ss : selectedSurfaces) {
					ss.decreaseResolution();
				}
				break;
				
			case KeyEvent.VK_U:
				for (SuperSurface ss : selectedSurfaces) {
					ss.increaseHorizontalForce();
				}
				break;

			case KeyEvent.VK_I:
				for (SuperSurface ss : selectedSurfaces) {
					ss.decreaseHorizontalForce();
				}
				break;
			
			case KeyEvent.VK_J:
				for (SuperSurface ss : selectedSurfaces) {
					ss.increaseVerticalForce();
				}
				break;

			case KeyEvent.VK_K:
				for (SuperSurface ss : selectedSurfaces) {
					ss.decreaseVerticalForce();
				}
				break;

			case KeyEvent.VK_T:
				for (SuperSurface ss : selectedSurfaces) {
					ss.toggleLocked();
				}
				break;

			case KeyEvent.VK_BACK_SPACE:
				removeSelectedSurfaces();
				break;
			*/
			case KeyEvent.VK_CONTROL:
			case CMD:
				ctrlDown = true;
				grouping = true;
				break;

			case KeyEvent.VK_ALT:
				altDown = true;
				break;
			}
		}
	}
	
	/**
	 * Delete the selected surfaces 
	 */
	public void removeSelectedSurfaces(){
		for (SuperSurface ss : selectedSurfaces) {
			for (int i = surfaces.size() - 1; i >= 0; i--) {
				if (ss.getId() == surfaces.get(i).getId()) {
					if (ss.isLocked()) return;
					if (this.getDebug())
						PApplet.println("Keystone --> DELETED SURFACE with ID: #" + ss.getId());
					surfaces.remove(i);
				}
			}
		}
		this.setGrouping(false);
		selectedSurfaces.clear();
		if (surfaces.size() == 0)
			numAddedSurfaces = 0;
	}

	public static <T> void removeDuplicates(ArrayList<T> list) {
		int size = list.size();
		int out = 0;
		{
			final Set<T> encountered = new HashSet<T>();
			for (int in = 0; in < size; in++) {
				final T t = list.get(in);
				final boolean first = encountered.add(t);
				if (first) {
					list.set(out++, t);
				}
			}
		}
		while (out < size) {
			list.remove(--size);
		}
	}
}
