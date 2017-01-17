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

import java.awt.Polygon;

import codeanticode.glgraphics.GLGraphicsOffScreen;
import codeanticode.glgraphics.GLTexture;
import processing.core.PApplet;
import processing.core.PVector;
import processing.xml.XMLElement;

public class SuperSurface {
	public final static int QUAD = 0;
	public final static int BEZIER = 1;
	
	private int type;
	
	QuadSurface quadSurface;
	BezierSurface bezierSurface;
	
	/**
	 * Constructor used to create a new Surface. This should always be used when creating a new surface.
	 * Type is either QUAD(0) or BEZIER(1). 
	 * @param type
	 * @param parent
	 * @param ks
	 * @param x
	 * @param y
	 * @param res
	 * @param id
	 */
	public SuperSurface(int type, PApplet parent, SurfaceMapper ks, float x, float y, int res, int id){
		this.type = type;
		
		switch(type){
		case QUAD:
			quadSurface = new QuadSurface(parent, ks, x, y, res, id);
			break;
			
		case BEZIER:
			if(res%2 != 0) res++;
			bezierSurface = new BezierSurface(parent, ks, x, y, res, id);
			break;
		}
	}
	
	/**
	 * Constructor for loading a surface from file
	 * @param type
	 * @param parent
	 * @param ks
	 * @param xml
	 */
	public SuperSurface(int type, PApplet parent, SurfaceMapper ks, XMLElement xml){
		this.type = type;
		
		switch(type){
		case QUAD:
			quadSurface = new QuadSurface(parent, ks, xml);
			break;
			
		case BEZIER:
			bezierSurface = new BezierSurface(parent, ks, xml);
			break;
		}
	}
	
	/**
	 * Sets the name of the surface
	 * @param name
	 */
	public void setSurfaceName(String name){
		switch(type){
		case QUAD:
			quadSurface.setSurfaceName(name);
			break;
		case BEZIER:
			bezierSurface.setSurfaceName(name);
		}
	}
	
	public String getSurfaceName(){
		switch(type){
		case QUAD:
			return quadSurface.getSurfaceName();
		case BEZIER:
			return bezierSurface.getSurfaceName();
		}
		return "";
	}
	
	/**
	 * Set the fill color of the surface in calibration mode
	 * @param ccolor
	 */
	public void setColor(int ccolor) {
		switch(type){
			case QUAD:
				quadSurface.setColor(ccolor);
				break;
			case BEZIER:
				bezierSurface.setColor(ccolor);	
				break;
		}
	}
	
	/**
	 * Get the surfaces current fill color in calibration mode
	 * @return
	 */
	public int getColor() {
		switch(type){
			case QUAD:
				return quadSurface.getColor();
			case BEZIER:
				return bezierSurface.getColor();	
		}
		return 0;
	}
	
	/**
	 * The the amount of subdivision currently used
	 * @return
	 */
	public int getRes(){	
		switch(type){
			case QUAD:
				return quadSurface.getRes();
			case BEZIER:
				return bezierSurface.getRes();	
		}
		return 0;
	}
	
	/**
	 * Increase the amount of subdivision
	 */
	public void increaseResolution(){
		switch(type){
			case QUAD:
				quadSurface.increaseResolution();
				break;
			case BEZIER:
				bezierSurface.increaseResolution();	
				break;
		}	
	}
	
	/**
	 * Decrease the amount of subdivision
	 */
	public void decreaseResolution(){
		switch(type){
			case QUAD:
				quadSurface.decreaseResolution();
				break;
			case BEZIER:
				bezierSurface.decreaseResolution();	
				break;
		}	
	}
	
	/**
	 * Increase the amount of horizontal displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void increaseHorizontalForce(){
		switch(type){
			case BEZIER:
				bezierSurface.increaseHorizontalForce();	
				break;
		}
	}
	
	/**
	 * Decrease the amount of horizontal displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void decreaseHorizontalForce(){
		switch(type){
			case BEZIER:
				bezierSurface.decreaseHorizontalForce();	
				break;
		}
	}
	
	/**
	 * Increase the amount of vertical displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void increaseVerticalForce(){
		switch(type){
			case BEZIER:
				bezierSurface.increaseVerticalForce();	
				break;
		}
	}
	
	/**
	 * Decrease the amount of horizontal displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void decreaseVerticalForce(){
		switch(type){
			case BEZIER:
				bezierSurface.decreaseVerticalForce();	
				break;
		}
	}
	
	/**
	 * Get the amount of horizontal displacement force used for spherical mapping for bezier surfaces.
	 */
	public int getHorizontalForce(){
		switch(type){
		case BEZIER:
				return bezierSurface.getHorizontalForce();
		}
		return 0;
	}
	
	/**
	 * Get the amount of vertical displacement force used for spherical mapping for bezier surfaces.
	 */
	public int getVerticalForce(){
		switch(type){
		case BEZIER:
				return bezierSurface.getVerticalForce();
		}
		return 0;
	}
	
	/**
	 * Set target corner point to coordinates
	 * @param pointIndex
	 * @param x
	 * @param y
	 */
	public void setCornerPoint(int pointIndex, float x, float y){
		switch(type){
			case QUAD:
				quadSurface.setCornerPoint(pointIndex, x, y);
				break;
			case BEZIER:
				bezierSurface.setCornerPoint(pointIndex, x, y);	
				break;
		}
	}
	
	/**
	 * Set if surface is hidden
	 * @param hide
	 */
	public void setHide(boolean hide){
		switch(type){
		case QUAD:
			quadSurface.setHide(hide);
			break;
		case BEZIER:
			bezierSurface.setHide(hide);
			break;
		}
	}
	
	/**
	 * See if surface is hidden
	 * @return
	 */
	public boolean isHidden(){
		switch(type){
		case QUAD:
			return quadSurface.isHidden();
		case BEZIER:
			return bezierSurface.isHidden();
		}
		return false;
	}
	
	/**
	 * Set the Z displacement for all coordinates of the surface
	 * @param z
	 */
	public void setZ(float z){
		switch(type){
		case QUAD:
			quadSurface.setZ(z);
			break;
		case BEZIER:
			bezierSurface.setZ(z);
			break;
		}
	}
	
	/**
	 * Set parameters for shaking the surface. Strength == max Z-displacement, Speed == vibration speed, FallOfSpeed 1-1000 == how fast strength is diminished
	 * @param strength
	 * @param speed
	 * @param fallOfSpeed
	 */
	public void setShake(int strength, int speed, int fallOfSpeed){
		if(fallOfSpeed < 1) fallOfSpeed = 1;
		if(fallOfSpeed > 1000) fallOfSpeed = 1000;
		switch(type){
		case QUAD:
			quadSurface.setShake(strength, speed, fallOfSpeed);
			break;
		case BEZIER:
			bezierSurface.setShake(strength, speed, fallOfSpeed);
			break;
		}
	}
	
	/**
	 * Tells surface to shake (will only do something if setShake has been called quite recently)
	 */
	public void shake(){
		switch(type){
		case QUAD:
			quadSurface.shake();
			break;
		case BEZIER:
			bezierSurface.shake();
			break;
		}
	}
	
	/**
	 * Set target bezier control point to coordinates
	 * @param pointIndex
	 * @param x
	 * @param y
	 */
	public void setBezierPoint(int pointIndex, float x, float y){
		switch(type){
			case BEZIER:
				bezierSurface.setBezierPoint(pointIndex, x, y);	
				break;
		}
	}
	
	/**
	 * Get target Bezier control point
	 * @param index
	 * @return
	 */
	public Point3D getBezierPoint(int index){
		switch(type){
			case BEZIER:
				return bezierSurface.getBezierPoint(index);
			}
		return new Point3D();
	}
	
	/**
	 * Set surface to calibration mode
	 */
	public void setModeCalibrate(){
		switch(type){
			case QUAD:
				quadSurface.setModeCalibrate();
				break;
			case BEZIER:
				bezierSurface.setModeCalibrate();	
				break;
		}
		
	}
	
	/**
	 * Set surface to render mode
	 */
	public void setModeRender(){
		switch(type){
			case QUAD:
				quadSurface.setModeRender();
				break;
			case BEZIER:
				bezierSurface.setModeRender();	
				break;
		}

	}
	
	/**
	 * Toggle surface mode
	 */
	public void toggleMode(){
		switch(type){
			case QUAD:
				quadSurface.toggleMode();
				break;
			case BEZIER:
				bezierSurface.toggleMode();	
				break;
		}
	}
	
	/**
	 * Get the index of active corner (or surface)
	 * @return
	 */
	public int getActivePoint(){
		switch(type){
			case QUAD:
				return quadSurface.getActivePoint();
			case BEZIER:
				return bezierSurface.getActivePoint();	
		}
		return 0;
	}
	
	/**
	 * Set index of which corner is active
	 * @param activePoint
	 */
	public void setActivePoint(int activePoint){
		switch(type){
			case QUAD:
				quadSurface.setActivePoint(activePoint);
				break;
			case BEZIER:
				bezierSurface.setActivePoint(activePoint);	
				break;
		}
	}
	
	/**
	 * Get the target corner point
	 * @param index
	 * @return
	 */
	public Point3D getCornerPoint(int index){
		switch(type){
			case QUAD:
				return quadSurface.getCornerPoint(index);
			case BEZIER:
				return bezierSurface.getCornerPoint(index);
		}
		return null;
	}
	
	/**
	 * Get all corner points
	 * @return
	 */
	public Point3D[] getCornerPoints(){
		switch(type){
			case QUAD:
				return quadSurface.getCornerPoints();
			case BEZIER:
				return bezierSurface.getCornerPoints();	
		}
		return null;
	}
	
	/**
	 * Rotate the corners of surface (0=ClockWise, 1=CounterClockWise)
	 * TODO Broken for Bezier Surfaces
	 * @param direction
	 */
	public void rotateCornerPoints(int direction){
		switch(type){
		case QUAD:
			quadSurface.rotateCornerPoints(direction);
			break;
		case BEZIER:
		//	bezierSurface.rotateCornerPoints(direction);
			break;

		}
	}
	
	/**
	 * Get the surfaces ID
	 * @return
	 */
	public int getId(){
		switch(type){
			case QUAD:
				return quadSurface.getId();
			case BEZIER:
				return bezierSurface.getId();	
		}
		return (Integer) null;
	}
	
	/**
	 * Toggle if surface is locked
	 */
	public void toggleLocked(){
		switch(type){
			case QUAD:
				quadSurface.toggleLocked();
				break;
			case BEZIER:
				bezierSurface.toggleLocked();	
				break;
		}
	}
	
	/**
	 * See if the surface is locked
	 * @return
	 */
	public boolean isLocked(){
		switch(type){
			case QUAD:
				return quadSurface.getLocked();
			case BEZIER:
				return bezierSurface.getLocked();	
		}
		return (Boolean) null;
	}
	
	/**
	 * Set if the surface is locked
	 * @param isLocked
	 */
	public void setLocked(boolean isLocked){
		switch(type){
			case QUAD:
				quadSurface.setLocked(isLocked);
				break;
			case BEZIER:
				bezierSurface.setLocked(isLocked);	
				break;
		}
	}
	
	/**
	 * See if the surface is selected
	 * @return
	 */
	public boolean isSelected(){
		switch(type){
			case QUAD:
				return quadSurface.isSelected();
			case BEZIER:
				return bezierSurface.isSelected();	
		}
		return (Boolean) null;
	}
	
	/**
	 * Set if the surface is selected
	 * @param selected
	 */
	public void setSelected(boolean selected){	
		switch(type){
			case QUAD:
				quadSurface.setSelected(selected);
				break;
			case BEZIER:
				bezierSurface.setSelected(selected);	
				break;
		}
	}
	
	/**
	 * Get the currently selected corner
	 * @return
	 */
	public int getSelectedCorner(){
		switch(type){
			case QUAD:
				return quadSurface.getSelectedCorner();
			case BEZIER:
				return bezierSurface.getSelectedCorner();	
		}
		return (Integer) null;
	}
	
	/**
	 * Set target corner to selected
	 * @param selectedCorner
	 */
	public void setSelectedCorner(int selectedCorner){
		switch(type){
			case QUAD:
				quadSurface.setSelectedCorner(selectedCorner);
				break;
			case BEZIER:
				bezierSurface.setSelectedCorner(selectedCorner);	
				break;
		}
	}
	
	/**
	 * Set target bezier control to selected
	 * @param selectedBezierControl
	 */
	public void setSelectedBezierControl(int selectedBezierControl) {
		switch(type){
			case BEZIER:
				bezierSurface.setSelectedBezierControl(selectedBezierControl);	
				break;
		}
	}

	/**
	 * Get the currently selected bezier control
	 * @return
	 */
	public int getSelectedBezierControl() {
		switch(type){
			case BEZIER:
				return bezierSurface.getSelectedBezierControl();	
		}
		return -1;
	}
	
	/**
	 * Returns index 0-3 if coordinates are near a corner or index -2 if on a surface
	 * @param mX
	 * @param mY
	 * @return
	 */
	public int getActiveCornerPointIndex(int mX, int mY){
		switch(type){
			case QUAD:
				return quadSurface.getActiveCornerPointIndex(mX, mY);
			case BEZIER:
				return bezierSurface.getActiveCornerPointIndex(mX, mY);	
		}
		return -1;
	}
	
	/**
	 * Returns index 0-7 if coordinates are on a bezier control
	 * @param mX
	 * @param mY
	 * @return
	 */
	public int getActiveBezierPointIndex(int mX, int mY){
		switch(type){
			case BEZIER:
				return bezierSurface.getActiveBezierPointIndex(mX, mY);	
		}
		return -1;
	}
	
	/**
	 * Returns true if coordinates are inside a surface
	 * @param mX
	 * @param mY
	 * @return
	 */
	public boolean isInside(float mX, float mY){
		switch(type){
			case QUAD:
				return quadSurface.isInside(mX, mY);
			case BEZIER:
				return bezierSurface.isInside(mX, mY);	
		}
		return false;
	}
	
	/**
	 * Get the surfaces polygon
	 * @return
	 */
	public Polygon getPolygon(){
		switch(type){
			case QUAD:
				return quadSurface.getPolygon();
			case BEZIER:
				return bezierSurface.getPolygon();	
		}
		return null;
	}
	
	/**
	 * Manually set coordinates for all corners of the surface
	 * @param x0
	 * @param y0
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 * @param x3
	 * @param y3
	 */
	public void setCornerPoints(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3){
		switch(type){
			case QUAD:
				quadSurface.setCornerPoints(x0, y0, x1, y1, x2, y2, x3, y3);
				break;
			case BEZIER:
				bezierSurface.setCornerPoints(x0, y0, x1, y1, x2, y2, x3, y3);	
				break;
		}
	}
	
	/**
	 * Get the average center point of the surface
	 * @return
	 */
	public Point3D getCenter(){
		switch(type){
			case QUAD:
				return quadSurface.getCenter();
			case BEZIER:
				return bezierSurface.getCenter();	
		}
		return null;
	}
	
	/**
	 * Translates a point on the screen into a point in the surface. (not implemented in Bezier Surfaces)
	 * @param x
	 * @param y
	 * @return
	 */
	public Point3D screenCoordinatesToQuad(float x, float y){
		switch(type){
			case QUAD:
				return quadSurface.screenCoordinatesToQuad(x, y);
			case BEZIER:
				return bezierSurface.screenCoordinatesToQuad(x, y);	
		}
		return null;
	}
	
	/**
	 * Renders the surface in calibration mode
	 * @param g
	 */
	public void render(GLGraphicsOffScreen g){
		switch(type){
			case QUAD:
				quadSurface.render(g);
				break;
			case BEZIER:
				bezierSurface.render(g);	
				break;
		}
	}
	
	/**
	 * Render the surface with texture
	 * @param g
	 * @param tex
	 */
	public void render(GLGraphicsOffScreen g, GLTexture tex){
		switch(type){
			case QUAD:
				quadSurface.render(g, tex);
				break;
			case BEZIER:
				bezierSurface.render(g, tex);	
				break;
		}
	}
	
	/**
	 * See which type this surface is
	 * @return
	 */
	public int getSurfaceType(){
		return type;
	}
}
