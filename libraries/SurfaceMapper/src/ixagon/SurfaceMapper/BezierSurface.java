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
import processing.core.PApplet;
import processing.xml.XMLElement;
import codeanticode.glgraphics.GLGraphicsOffScreen;
import codeanticode.glgraphics.GLTexture;

//Parts derived from MappingTools library

public class BezierSurface {
	
	private PApplet parent;

	private SurfaceMapper sm;

	final private int MODE_RENDER = 0;
	final private int MODE_CALIBRATE = 1;

	private int MODE = MODE_RENDER;
	
	

	private int activePoint = -1; // Which corner point is selected?

	static private int GRID_LINE_COLOR;
	static private int GRID_LINE_SELECTED_COLOR;
	static private int SELECTED_OUTLINE_OUTER_COLOR;
	static private int CORNER_MARKER_COLOR;
	static private int SELECTED_OUTLINE_INNER_COLOR;
	static private int SELECTED_CORNER_MARKER_COLOR;

	// Corners of the Surface
	private Point3D[] cornerPoints;

	// Contains all coordinates
	private Point3D[][] vertexPoints;

	// Coordinates of the bezier vectors
	private Point3D[] bezierPoints;
	
	// Displacement forces

	private int horizontalForce = 0;
	private int verticalForce = 0;

	private int GRID_RESOLUTION;
	private int DEFAULT_SIZE = 100;

	private int surfaceId;

	private boolean isSelected;
	private boolean isLocked;
	private int selectedCorner;
	private int selectedBezierControl;
	
	private int ccolor = 0; 
	
	private String surfaceName;
	
	private Polygon poly = new Polygon();

	private float currentZ;
	private boolean shaking;
	private float shakeStrength;
	private int shakeSpeed;
	private int fallOfSpeed;
	private float shakeAngle;
	
	private boolean hidden = false;
	
	/**
	 * Constructor for creating a new surface at X,Y with RES subdivision.
	 * @param parent
	 * @param ks
	 * @param x
	 * @param y
	 * @param res
	 * @param id
	 */
	BezierSurface(PApplet parent, SurfaceMapper ks, float x, float y, int res, int id) {
		init(parent, ks, res, id, null);

		this.cornerPoints[0].x = (float) (x - (this.DEFAULT_SIZE * 0.5));
		this.cornerPoints[0].y = (float) (y - (this.DEFAULT_SIZE * 0.5));

		this.cornerPoints[1].x = (float) (x + (this.DEFAULT_SIZE * 0.5));
		this.cornerPoints[1].y = (float) (y - (this.DEFAULT_SIZE * 0.5));

		this.cornerPoints[2].x = (float) (x + (this.DEFAULT_SIZE * 0.5));
		this.cornerPoints[2].y = (float) (y + (this.DEFAULT_SIZE * 0.5));

		this.cornerPoints[3].x = (float) (x - (this.DEFAULT_SIZE * 0.5));
		this.cornerPoints[3].y = (float) (y + (this.DEFAULT_SIZE * 0.5));
		
		//bezier points init
		
		this.bezierPoints[0].x = (float) (this.cornerPoints[0].x + (this.DEFAULT_SIZE * 0.0));
		this.bezierPoints[0].y = (float) (this.cornerPoints[0].y + (this.DEFAULT_SIZE * 0.3));

		this.bezierPoints[1].x = (float) (this.cornerPoints[0].x + (this.DEFAULT_SIZE * 0.3));
		this.bezierPoints[1].y = (float) (this.cornerPoints[0].y + (this.DEFAULT_SIZE * 0.0));

		this.bezierPoints[2].x = (float) (this.cornerPoints[1].x - (this.DEFAULT_SIZE * 0.3));
		this.bezierPoints[2].y = (float) (this.cornerPoints[1].y + (this.DEFAULT_SIZE * 0.0));

		this.bezierPoints[3].x = (float) (this.cornerPoints[1].x - (this.DEFAULT_SIZE * 0.0));
		this.bezierPoints[3].y = (float) (this.cornerPoints[1].y + (this.DEFAULT_SIZE * 0.3));
		
		this.bezierPoints[4].x = (float) (this.cornerPoints[2].x - (this.DEFAULT_SIZE * 0.0));
		this.bezierPoints[4].y = (float) (this.cornerPoints[2].y - (this.DEFAULT_SIZE * 0.3));

		this.bezierPoints[5].x = (float) (this.cornerPoints[2].x - (this.DEFAULT_SIZE * 0.3));
		this.bezierPoints[5].y = (float) (this.cornerPoints[2].y - (this.DEFAULT_SIZE * 0.0));

		this.bezierPoints[6].x = (float) (this.cornerPoints[3].x + (this.DEFAULT_SIZE * 0.3));
		this.bezierPoints[6].y = (float) (this.cornerPoints[3].y + (this.DEFAULT_SIZE * 0.0));

		this.bezierPoints[7].x = (float) (this.cornerPoints[3].x - (this.DEFAULT_SIZE * 0.0));
		this.bezierPoints[7].y = (float) (this.cornerPoints[3].y - (this.DEFAULT_SIZE * 0.3));

		this.updateTransform();
	}

	/**
	 * Constructor used when loading a surface from file
	 * @param parent
	 * @param ks
	 * @param xml
	 */
	BezierSurface(PApplet parent, SurfaceMapper ks, XMLElement xml) {

		init(parent, ks, (xml.getInt("res")), xml.getInt("id"), xml.getString("name"));

		if (xml.getBoolean("lock"))
			this.toggleLocked();

		// reload the Corners
		for (int i = 0; i < xml.getChildCount(); i++) {
			XMLElement point = xml.getChild(i);
			if(point.getName().equals("cornerpoint"))
				setCornerPoint(point.getInt("i"), point.getFloat("x"), point.getFloat("y"));
			if(point.getName().equals("bezierpoint"))
				this.setBezierPoint(point.getInt("i"), point.getFloat("x"), point.getFloat("y"));
		}
		
		horizontalForce = xml.getInt("horizontalForce");
		verticalForce = xml.getInt("verticalForce");

		this.updateTransform();
	}

	/**
	 * Convenience method used by the constructors.
	 * @param parent
	 * @param ks
	 * @param res
	 * @param id
	 */
	private void init(PApplet parent, SurfaceMapper ks, int res, int id, String name) {
		this.parent = parent;
		this.sm = ks;
		this.surfaceName = name;
		this.surfaceId = id;
		this.GRID_RESOLUTION = res;
		this.horizontalForce = 0;
		this.verticalForce = 0;
		this.selectedBezierControl = -1;

		this.cornerPoints = new Point3D[4];
		this.bezierPoints = new Point3D[8];
		this.vertexPoints = new Point3D[this.GRID_RESOLUTION+1][this.GRID_RESOLUTION+1];

		for (int i = 0; i < this.cornerPoints.length; i++) {
			this.cornerPoints[i] = new Point3D();
		}

		for (int i = 0; i < this.bezierPoints.length; i++) {
			this.bezierPoints[i] = new Point3D();
		}
		
		GRID_LINE_COLOR = parent.color(128, 128, 128);
		GRID_LINE_SELECTED_COLOR = parent.color(160, 160, 160);
		SELECTED_OUTLINE_OUTER_COLOR = parent.color(255, 255, 255, 128);
		SELECTED_OUTLINE_INNER_COLOR = parent.color(255, 255, 255);
		CORNER_MARKER_COLOR = parent.color(255, 255, 255);
		SELECTED_CORNER_MARKER_COLOR = parent.color(255, 0, 0);

		this.updateTransform();
	}
	
	/**
	 * Sets the fill color of the surface in calibration mode
	 * @param ccolor
	 */
	public void setColor(int ccolor) {
		this.ccolor = ccolor;
	}
	
	/**
	 * Get the fill color of the surface in calibration mode
	 * @return
	 */
	public int getColor() {
		return ccolor;
	}

	/**
	 * Get the amount of subdivision used in the surface
	 * @return
	 */
	public int getRes() {
		// The actual resolution is the number of tiles, not the number of mesh
		// points
		return GRID_RESOLUTION;
	}

	/**
	 * Increase the subdivision
	 */
	public void increaseResolution() {
		this.GRID_RESOLUTION += 2;
		this.vertexPoints = new Point3D[this.GRID_RESOLUTION+1][this.GRID_RESOLUTION+1];
		this.updateTransform();
	}

	/**
	 * Decrease the subdivision
	 */
	public void decreaseResolution() {
		if ((this.GRID_RESOLUTION - 1) > 2) {
			this.GRID_RESOLUTION -= 2;
			this.vertexPoints = new Point3D[this.GRID_RESOLUTION+1][this.GRID_RESOLUTION+1];
			this.updateTransform();
		}
	}
	
	/**
	 * Increase the amount of horizontal displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void increaseHorizontalForce(){
		this.horizontalForce += 2;
		this.updateTransform();
	}
	
	/**
	 * Decrease the amount of horizontal displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void decreaseHorizontalForce(){
		this.horizontalForce -= 2;
		this.updateTransform();
	}
	
	/**
	 * Increase the amount of vertical displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void increaseVerticalForce(){
		this.verticalForce += 2;
		this.updateTransform();
	
	}
	
	/**
	 * Decrease the amount of vertical displacement force used for spherical mapping for bezier surfaces. (using orthographic projection)
	 */
	public void decreaseVerticalForce(){
		this.verticalForce -= 2;
		this.updateTransform();
	}
	
	/**
	 * Get the amount of horizontal displacement force used for spherical mapping for bezier surfaces.
	 * @return
	 */
	public int getHorizontalForce(){
		return horizontalForce;
	}
	
	/**
	 * Get the amount of vertical displacement force used for spherical mapping for bezier surfaces.
	 * @return
	 */
	public int getVerticalForce(){
		return verticalForce;
	}
	
	/**
	 * Set parameters for shaking the surface. Strength == max Z-displacement, Speed == vibration speed, FallOfSpeed 1-1000 == how fast strength is diminished
	 * @param strength
	 * @param speed
	 * @param fallOfSpeed
	 */
	public void setShake(int strength, int speed, int fallOfSpeed){
		shaking = true;
		this.shakeStrength = strength;
		this.shakeSpeed = speed;
		this.fallOfSpeed = 1000-fallOfSpeed;
		shakeAngle = 0;
	}
	
	/**
	 * Tells surface to shake (will only do something if setShake has been called quite recently)
	 */
	public void shake(){
		if(shaking){
			shakeAngle += (float)(shakeSpeed/1000);
			shakeStrength *= ((float)this.fallOfSpeed/1000);
			float shakeZ = (float) (Math.sin(shakeAngle)*shakeStrength);
			this.setZ(shakeZ);
			if(shakeStrength < 1){
				shaking = false;
			}
		}
	}
	
	/**
	 * Set Z-displacement for all coordinates of surface
	 * @param currentZ
	 */
	public void setZ(float currentZ){
		this.currentZ = currentZ;
	}

	/**
	 * Set target corner point to coordinates
	 * @param pointIndex
	 * @param x
	 * @param y
	 */
	public void setCornerPoint(int pointIndex, float x, float y) {
		this.cornerPoints[pointIndex].x = x;
		this.cornerPoints[pointIndex].y = y;
		this.updateTransform();
	}
	
	/**
	 * Set target bezier control point to coordinates
	 * @param pointIndex
	 * @param x
	 * @param y
	 */
	public void setBezierPoint(int pointIndex, float x, float y) {
		this.bezierPoints[pointIndex].x = x;
		this.bezierPoints[pointIndex].y = y;
		this.updateTransform();
	}
	
	/**
	 * Set surface to calibration mode
	 */
	public void setModeCalibrate() {
		this.MODE = this.MODE_CALIBRATE;
	}

	/**
	 * Set surface to render mode
	 */
	public void setModeRender() {
		this.MODE = this.MODE_RENDER;
	}

	/**
	 * Toggle surface mode
	 */
	public void toggleMode() {
		if (this.MODE == this.MODE_RENDER) {
			this.MODE = this.MODE_CALIBRATE;
		} else {
			this.MODE = this.MODE_RENDER;
		}
	}

	/**
	 * Get the index of active corner (or surface)
	 * @return
	 */
	public int getActivePoint() {
		return this.activePoint;
	}

	/**
	 * Set index of which corner is active
	 * @param activePoint
	 */
	public void setActivePoint(int activePoint) {
		this.activePoint = activePoint;
	}
	
	/**
	 * Get all corner points
	 * @return
	 */
	public Point3D[] getCornerPoints(){
		return this.cornerPoints;
	}

	/**
	 * Get the target corner point
	 * @param index
	 * @return
	 */
	public Point3D getCornerPoint(int index) {
		return this.cornerPoints[index];
	}
	
	/**
	 * Rotate the cornerpoints in direction (0=ClockWise 1=CounterClockWise)
	 * @param direction
	 */
	public void rotateCornerPoints(int direction){
		Point3D[] sourcePoints = cornerPoints.clone();
		switch(direction){
		case 0:
			cornerPoints[0] = sourcePoints[1];
			cornerPoints[1] = sourcePoints[2];
			cornerPoints[2] = sourcePoints[3];
			cornerPoints[3] = sourcePoints[0];
			this.updateTransform();
			break;
		case 1:
			cornerPoints[0] = sourcePoints[3];
			cornerPoints[1] = sourcePoints[0];
			cornerPoints[2] = sourcePoints[1];
			cornerPoints[3] = sourcePoints[2];
			this.updateTransform();
			break;
		}
	}
	
	/**
	 * Get all bezier points
	 * @return
	 */
	public Point3D[] getBezierPoints() {
		return this.bezierPoints;
	}

	/**
	 * Get the target bezier point
	 * @param index
	 * @return
	 */
	public Point3D getBezierPoint(int index) {
		return this.bezierPoints[index];
	}

	/**
	 * Get the surfaces ID
	 * @return
	 */
	public int getId() {
		return this.surfaceId;
	}

	/**
	 * Set if the surface should be hidden
	 * @param hidden
	 */
	public void setHide(boolean hidden) {
		this.hidden = hidden;
	}

	/**
	 * See if surface is hidden
	 * @return
	 */
	public boolean isHidden() {
		return hidden;
	}

	/**
	 * Toggle if surface is locked
	 */
	public void toggleLocked() {
		this.isLocked = !this.isLocked;
	}

	/**
	 * See if the surface is locked
	 * @return
	 */
	public boolean getLocked() {
		return this.isLocked;
	}

	/**
	 * Set if the surface is locked
	 * @param isLocked
	 */
	public void setLocked(boolean isLocked) {
		this.isLocked = isLocked;
	}
	
	/**
	 * See if the surface is selected
	 * @return
	 */
	public boolean isSelected() {
		return this.isSelected;
	}

	/**
	 * Set if the surface is selected
	 * @param selected
	 */
	public void setSelected(boolean selected) {
		this.isSelected = selected;
	}
	
	/**
	 * Get the currently selected corner
	 * @return
	 */
	public int getSelectedCorner() {
		return this.selectedCorner;
	}

	/**
	 * Set target corner to selected
	 * @param selectedCorner
	 */
	public void setSelectedCorner(int selectedCorner) {
		this.selectedCorner = selectedCorner;
	}

	/**
	 * Set target bezier control to selected
	 * @param selectedBezierControl
	 */
	public void setSelectedBezierControl(int selectedBezierControl) {
		this.selectedBezierControl = selectedBezierControl;
	}

	/**
	 * Get the currently selected bezier control
	 * @return
	 */
	public int getSelectedBezierControl() {
		return selectedBezierControl;
	}

	/**
	 * Get the surfaces polygon
	 * @return
	 */
	public Polygon getPolygon(){
		return poly;
	}
	
	/**
	 * Returns index 0-3 if coordinates are near a corner or index 4 if on a surface
	 * @param mX
	 * @param mY
	 * @return
	 */
	public int getActiveCornerPointIndex(int mX, int mY) {
		for (int i = 0; i < this.cornerPoints.length; i++) {
			if (PApplet.dist(mX, mY, this.cornerPoints[i].x, this.cornerPoints[i].y) < sm.getSelectionDistance()) {
				setSelectedCorner(i);
				return i;
			}
		}
		if (this.isInside(mX, mY))
			return 2000;
		return -1;
	}
	
	/**
	 * Returns index 0-7 if coordinates are on a bezier control
	 * @param mX
	 * @param mY
	 * @return
	 */
	public int getActiveBezierPointIndex(int mX, int mY){
		for(int i = 0; i < this.bezierPoints.length; i++){
			if(PApplet.dist(mX, mY, this.bezierPoints[i].x, this.bezierPoints[i].y) < sm.getSelectionDistance()){
				this.setSelectedBezierControl(i);
				return i;
			}
		}
		return -1;
	}

	/**
	 * Returns true if coordinates are inside a surface
	 * @param mX
	 * @param mY
	 * @return
	 */
	public boolean isInside(float mX, float mY) {
		if(poly.contains(mX, mY)) return true;
		return false;
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
	public void setCornerPoints(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3) {
		this.cornerPoints[0].x = x0;
		this.cornerPoints[0].y = y0;

		this.cornerPoints[1].x = x1;
		this.cornerPoints[1].y = y1;

		this.cornerPoints[2].x = x2;
		this.cornerPoints[2].y = y2;

		this.cornerPoints[3].x = x3;
		this.cornerPoints[3].y = y3;

		this.updateTransform();
	}

	/**
	 * Recalculates all coordinates of the surface.
	 * Must be called whenever any change has been done to the surface.
	 */
	public void updateTransform(){
		
		for (int i = 0; i <= GRID_RESOLUTION; i++) {
			for (int j = 0; j <= GRID_RESOLUTION; j++) {
				
		        float start_x = parent.bezierPoint(cornerPoints[0].x, bezierPoints[0].x, bezierPoints[7].x, cornerPoints[3].x, (float)j/GRID_RESOLUTION);
		        float end_x = parent.bezierPoint(cornerPoints[1].x, bezierPoints[3].x, bezierPoints[4].x, cornerPoints[2].x, (float)j/GRID_RESOLUTION);

		        float start_y = parent.bezierPoint(cornerPoints[0].y, bezierPoints[0].y, bezierPoints[7].y, cornerPoints[3].y, (float)j/GRID_RESOLUTION);
		        float end_y = parent.bezierPoint(cornerPoints[1].y, bezierPoints[3].y, bezierPoints[4].y, cornerPoints[2].y, (float)j/GRID_RESOLUTION);

		        float x = parent.bezierPoint(start_x, ((bezierPoints[1].x - bezierPoints[6].x) * (1.0f - (float)j/GRID_RESOLUTION)) + bezierPoints[6].x, ((bezierPoints[2].x - bezierPoints[5].x) * (1.0f - (float)j/GRID_RESOLUTION)) + bezierPoints[5].x, end_x, (float)i/GRID_RESOLUTION);
		        float y = parent.bezierPoint(start_y, ((bezierPoints[1].y - bezierPoints[6].y) * (1.0f - (float)j/GRID_RESOLUTION)) + bezierPoints[6].y, ((bezierPoints[2].y - bezierPoints[5].y) * (1.0f - (float)j/GRID_RESOLUTION)) + bezierPoints[5].y, end_y, (float)i/GRID_RESOLUTION);

		        //the formula for Orthographic Projection
		        //x = cos(latitude) * sin(longitude-referenceLongitude);
		        //y = cos(referenceLatitude)*sin(latitude)-sin(referenceLatitude)*cos(latitude)*cos(longitude-referenceLongitude);
		        //http://mathworld.wolfram.com/OrthographicProjection.html
		        
		        float pi1 = (float) ((Math.PI)/GRID_RESOLUTION);
		        
		        float xfix = (float)(Math.cos((j-(GRID_RESOLUTION/2))*pi1)*Math.sin((i*pi1)-((float)(GRID_RESOLUTION/2)*pi1)))*horizontalForce;
		        float yfix = (float)(Math.cos((float)(GRID_RESOLUTION/2)*pi1)*Math.sin(j*pi1)-Math.sin((float)(GRID_RESOLUTION/2)*pi1)*Math.cos(j*pi1)*Math.cos((i*pi1)-((float)(GRID_RESOLUTION/2)*pi1)))*verticalForce;
		        
		        vertexPoints[i][j] = new Point3D(x+xfix, y+yfix, 0);
			}
		}	
		
		poly = new Polygon();
		for(int w = 0; w < 4; w++){
			for(int i = 0; i < GRID_RESOLUTION; i++){
				switch(w){
				case 0:
					poly.addPoint((int)vertexPoints[i][0].x, (int)vertexPoints[i][0].y);
					break;
					
				case 1:
					poly.addPoint((int)vertexPoints[GRID_RESOLUTION][i].x, (int)vertexPoints[GRID_RESOLUTION][i].y);
					break;
					
				case 2:
					poly.addPoint((int)vertexPoints[GRID_RESOLUTION-i][GRID_RESOLUTION].x, (int)vertexPoints[GRID_RESOLUTION-i][GRID_RESOLUTION].y);
					break;
					
				case 3:
					poly.addPoint((int)vertexPoints[0][GRID_RESOLUTION-i].x, (int)vertexPoints[0][GRID_RESOLUTION-i].y);
					break;
				}
			}
		}
	}

	/**
	 * Get the average center point of the surface
	 * @return
	 */
	public Point3D getCenter() {
		// Find the average position of all the control points, use that as the
		// center point.
		float avgX = 0;
		float avgY = 0;
		for (int c = 0; c < 4; c++) {
			avgX += this.cornerPoints[c].x;
			avgY += this.cornerPoints[c].y;
		}
		avgX /= 4;
		avgY /= 4;

		return new Point3D(avgX, avgY);
	}

	/**
	 * Translates a point on the screen into a point in the surface. (not implemented in Bezier Surfaces yet)
	 * @param x
	 * @param y
	 * @return
	 */
	public Point3D screenCoordinatesToQuad(float x, float y) {
		//TODO :: maybe add this code
		return null;
	}

	/**
	 * Render method for rendering while in calibration mode
	 * @param g
	 */
	public void render(GLGraphicsOffScreen g) {
		if (this.MODE == this.MODE_CALIBRATE && !this.isHidden()) {
			this.renderGrid(g);
		}
	}

	/**
	 * Render method for rendering in RENDER mode. 
	 * Takes one GLGraphicsOffScreen and one GLTexture. The GLTexture is the texture used for the surface, and is drawn to the offscreen buffer.
	 * @param g
	 * @param tex
	 */
	public void render(GLGraphicsOffScreen g, GLTexture tex) {
		if(this.isHidden()) return;
		this.renderSurface(g, tex);
	}

	/**
	 * Actual rendering of the surface. Is called from the render method.
	 * Should normally not be accessed directly.
	 * @param g
	 * @param tex
	 */
	private void renderSurface(GLGraphicsOffScreen g, GLTexture tex) {
		g.beginDraw();
		//g.hint(PApplet.DISABLE_DEPTH_TEST); //this is probably needed, but could cause problems with surfaces adjacent to each other
		g.noStroke();
		
		for (int i = 0; i < GRID_RESOLUTION; i++) {
			for (int j = 0; j < GRID_RESOLUTION; j++) {
				
				g.beginShape();
				g.texture(tex);
				g.vertex(vertexPoints[i][j].x, 
						vertexPoints[i][j].y, 
						vertexPoints[i][j].z+currentZ,
						((float) i / GRID_RESOLUTION) * tex.width,
						((float) j / GRID_RESOLUTION) * tex.height);
				
				g.vertex(vertexPoints[i + 1][j].x, 
						vertexPoints[i + 1][j].y,
						vertexPoints[i + 1][j].z+currentZ, 
						(((float) i + 1) / GRID_RESOLUTION) * tex.width, 
						((float) j / GRID_RESOLUTION) * tex.height);
				
				g.vertex(vertexPoints[i + 1][j + 1].x, 
						vertexPoints[i + 1][j + 1].y,
						vertexPoints[i + 1][j + 1].z+currentZ, 
						(((float) i + 1) / GRID_RESOLUTION) * tex.width, 
						(((float) j + 1) / GRID_RESOLUTION) * tex.height);
				
				g.vertex(vertexPoints[i][j + 1].x, 
						vertexPoints[i][j + 1].y,
						vertexPoints[i][j + 1].z+currentZ, 
						((float) i / GRID_RESOLUTION) * tex.width,
						(((float) j + 1) / GRID_RESOLUTION) * tex.height);
				g.endShape();
				
			}
		}
		
		g.endDraw();
	}

	/**
	 * Renders the grid in the surface. (useful in calibration mode)
	 * @param g
	 */
	private void renderGrid(GLGraphicsOffScreen g) {
		g.beginDraw();
		
		if (ccolor == 0) {
			g.fill(50, 80, 150);
		} else {
			g.fill(ccolor);
		}
		g.noStroke();
		for (int i = 0; i < GRID_RESOLUTION; i++) {
			for (int j = 0; j < GRID_RESOLUTION; j++) {
				
				g.beginShape();
				g.vertex(vertexPoints[i][j].x, vertexPoints[i][j].y);
				g.vertex(vertexPoints[i + 1][j].x, vertexPoints[i + 1][j].y);
				g.vertex(vertexPoints[i + 1][j + 1].x, vertexPoints[i + 1][j + 1].y);
				g.vertex(vertexPoints[i][j + 1].x, vertexPoints[i][j + 1].y);	
				g.endShape();
				
			}
		}
		
		g.textFont(sm.getIdFont());
		if (ccolor == 0) {
			g.fill(255);
		} else {
			g.fill(0);
		}

		g.textAlign(PApplet.CENTER, PApplet.CENTER);
		g.textSize(40);
		g.text("" + surfaceId, (float) (this.getCenter().x), (float) this.getCenter().y);
		if (isLocked) {
			g.textSize(12);
			g.text("Surface locked", (float) this.getCenter().x, (float) this.getCenter().y+26);
		}
		

		g.noFill();
		g.stroke(BezierSurface.GRID_LINE_COLOR);
		g.strokeWeight(2);
		if (isSelected)
			g.stroke(BezierSurface.GRID_LINE_SELECTED_COLOR);

		if (!isLocked) {
			for(int i = 0; i <= GRID_RESOLUTION; i++){
				for(int j = 0; j <= GRID_RESOLUTION; j++){
					g.point(vertexPoints[i][j].x, vertexPoints[i][j].y, vertexPoints[i][j].z);
				}
			}
		}
		
		if (isSelected) {
			g.strokeWeight(4);
			g.stroke(BezierSurface.GRID_LINE_SELECTED_COLOR);
			
			//draw the outline here
			for(int i = 0; i < poly.npoints-1; i++){
				g.line(poly.xpoints[i], poly.ypoints[i], poly.xpoints[i+1], poly.ypoints[i+1]);
				if(i == poly.npoints-2) g.line(poly.xpoints[i+1], poly.ypoints[i+1], poly.xpoints[0], poly.ypoints[0]);
			}
		}
		
		g.strokeWeight(1);
		g.stroke(SELECTED_OUTLINE_INNER_COLOR);
		//draw the outline here
		for(int i = 0; i < poly.npoints-1; i++){
			g.line(poly.xpoints[i], poly.ypoints[i], poly.xpoints[i+1], poly.ypoints[i+1]);
			if(i == poly.npoints-2) g.line(poly.xpoints[i+1], poly.ypoints[i+1], poly.xpoints[0], poly.ypoints[0]);
		}

		
		
		if (!isLocked) {
			// Draw the control points.
			for (int i = 0; i < this.cornerPoints.length; i++) {
				this.renderCornerPoint(g, this.cornerPoints[i].x, this.cornerPoints[i].y, (this.activePoint == i), i);
				
			}
			
			for(int i = 0; i < this.bezierPoints.length; i++){
				this.renderBezierPoint(g, this.bezierPoints[i].x, this.bezierPoints[i].y, (this.selectedBezierControl == i), i);
				g.strokeWeight(1);
				g.stroke(255);
				g.line(this.bezierPoints[i].x, this.bezierPoints[i].y, this.cornerPoints[(int)(i/2)].x, this.cornerPoints[(int)(i/2)].y);
			}
			
		}

		g.endDraw();
	}

	/**
	 * Draws the Corner points
	 * @param g
	 * @param x
	 * @param y
	 * @param selected
	 * @param cornerIndex
	 */
	private void renderCornerPoint(GLGraphicsOffScreen g, float x, float y, boolean selected, int cornerIndex) {
		g.noFill();
		g.strokeWeight(2);
		if (selected) {
			g.stroke(BezierSurface.SELECTED_CORNER_MARKER_COLOR);
		} else {
			g.stroke(BezierSurface.CORNER_MARKER_COLOR);
		}
		if (cornerIndex == getSelectedCorner() && isSelected()) {
			g.fill(BezierSurface.SELECTED_CORNER_MARKER_COLOR, 100);
			g.stroke(BezierSurface.SELECTED_CORNER_MARKER_COLOR);
		}
		g.ellipse(x, y, 16, 16);
		g.line(x, y - 8, x, y + 8);
		g.line(x - 8, y, x + 8, y);
	}
	
	/**
	 * Draws the bezier points
	 * @param g
	 * @param x
	 * @param y
	 * @param selected
	 * @param cornerIndex
	 */
	private void renderBezierPoint(GLGraphicsOffScreen g, float x, float y, boolean selected, int cornerIndex) {
		g.noFill();
		g.strokeWeight(1);
		if (selected) {
			g.stroke(BezierSurface.SELECTED_CORNER_MARKER_COLOR);
		} else {
			g.stroke(BezierSurface.CORNER_MARKER_COLOR);
		}
		if (cornerIndex == getSelectedBezierControl() && isSelected()) {
			g.fill(BezierSurface.SELECTED_CORNER_MARKER_COLOR, 100);
			g.stroke(BezierSurface.SELECTED_CORNER_MARKER_COLOR);
		}
		g.ellipse(x, y, 10, 10);
		g.line(x, y - 5, x, y + 5);
		g.line(x - 5, y, x + 5, y);
	}

	public void setSurfaceName(String surfaceName) {
		this.surfaceName = surfaceName;
	}

	public String getSurfaceName() {
		if(surfaceName == null) return String.valueOf(this.getId());
		return surfaceName;
	}
}
