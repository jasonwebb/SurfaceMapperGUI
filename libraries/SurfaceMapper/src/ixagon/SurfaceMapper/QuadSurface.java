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

//Derived from KeystoneP5 library
//and code from rrrufusss
//https://forum.processing.org/topic/compensating-for-keystone-distortion-or-creating-some-kind-of-homography-routine

import java.awt.Polygon;

import javax.media.jai.PerspectiveTransform;

import processing.core.PApplet;
import processing.xml.XMLElement;
import codeanticode.glgraphics.GLGraphicsOffScreen;
import codeanticode.glgraphics.GLTexture;

public class QuadSurface {

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

	// The four corners of the transformed quad (in 2d screen space)
	private Point3D[] cornerPoints;

	// The entire list of transformed grid points are stored in this array (from
	// left to right, top to bottom, like pixels..).
	// This list is updated whenever the updateTransform() method is invoked.
	private Point3D[] gridPoints;

	// The raw list of verticies to be pumped out each frame. This array
	// holds the pre-computed list, including duplicates, to save on computation
	// during rendering.
	private Point3D[][] vertexPoints;

	// The transform! Thank you Java Advanced Imaging, now I don't have to learn
	// a bunch of math..
	// Docs:
	// http://download.oracle.com/docs/cd/E17802_01/products/products/java-media/jai/forDevelopers/jai-apidocs/javax/media/jai/PerspectiveTransform.html
	private PerspectiveTransform transform;

	private int GRID_RESOLUTION;

	private int surfaceId;
	private String surfaceName;

	// Metrics for the projected texture..
	private float textureX = 0;
	private float textureY = 0;
	private float DEFAULT_SIZE = 100;

	private boolean isSelected;
	private boolean isLocked;
	private int selectedCorner;

	private int ccolor = 0;

	private Polygon poly = new Polygon();

	private float currentZ;
	private boolean shaking;
	private float shakeStrength;
	private int shakeSpeed;
	private float shakeAngle;
	private int fallOfSpeed;

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
	QuadSurface(PApplet parent, SurfaceMapper ks, float x, float y, int res, int id) {
		init(parent, ks, res, id, null);
		
		this.setCornerPoints(	(float) (x - (this.DEFAULT_SIZE * 0.5)), (float) (y - (this.DEFAULT_SIZE * 0.5)), 
								(float) (x + (this.DEFAULT_SIZE * 0.5)), (float) (y - (this.DEFAULT_SIZE * 0.5)), 
								(float) (x + (this.DEFAULT_SIZE * 0.5)), (float) (y + (this.DEFAULT_SIZE * 0.5)),
								(float) (x - (this.DEFAULT_SIZE * 0.5)), (float) (y + (this.DEFAULT_SIZE * 0.5)));
	}

	/**
	 * Constructor used when loading a surface from file
	 * @param parent
	 * @param ks
	 * @param xml
	 */
	QuadSurface(PApplet parent, SurfaceMapper ks, XMLElement xml) {

		init(parent, ks, xml.getInt("res"), xml.getInt("id"), xml.getString("name"));

		if (xml.getBoolean("lock"))
			this.setLocked(xml.getBoolean("lock"));

		this.setCornerPoints(	xml.getChild(0).getFloat("x"), xml.getChild(0).getFloat("y"), 
								xml.getChild(1).getFloat("x"), xml.getChild(1).getFloat("y"), 
								xml.getChild(2).getFloat("x"), xml.getChild(2).getFloat("y"),
								xml.getChild(3).getFloat("x"), xml.getChild(3).getFloat("y"));

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
		this.surfaceId = id;
		this.surfaceName = name;
		this.GRID_RESOLUTION = res + 1;
		this.updateCalibrateTexture();

		this.cornerPoints = new Point3D[4];

		for (int i = 0; i < this.cornerPoints.length; i++) {
			this.cornerPoints[i] = new Point3D();
		}

		GRID_LINE_COLOR = parent.color(128, 128, 128);
		GRID_LINE_SELECTED_COLOR = parent.color(160, 160, 160);
		SELECTED_OUTLINE_OUTER_COLOR = parent.color(255, 255, 255, 128);
		SELECTED_OUTLINE_INNER_COLOR = parent.color(255, 255, 255);
		CORNER_MARKER_COLOR = parent.color(255, 255, 255);
		SELECTED_CORNER_MARKER_COLOR = parent.color(255, 0, 0);

		this.initTransform();
	}

	/**
	 * Initializes the arrays used for transformation
	 */
	private void initTransform() {
		this.gridPoints = new Point3D[this.GRID_RESOLUTION * this.GRID_RESOLUTION];
		this.vertexPoints = new Point3D[this.GRID_RESOLUTION][this.GRID_RESOLUTION];

		for (int i = 0; i < this.gridPoints.length; i++) {
			this.gridPoints[i] = new Point3D();
		}

		for (int i = 0; i < this.GRID_RESOLUTION; i++) {
			for(int j = 0; j < this.GRID_RESOLUTION; j++)
			this.vertexPoints[i][j] = new Point3D();
		}
	}

	/**
	 * Used to update the calibration texture when a surface's settings have changed.
	 */
	private void updateCalibrateTexture() {
		/*
		if (calibrateTex == null)
			this.calibrateTex = new GLGraphicsOffScreen(parent, 600, 600);
		calibrateTex.beginDraw();
		if (ccolor == 0) {
			calibrateTex.clear(50, 80, 150);
		} else {
			calibrateTex.clear(ccolor);
		}
		calibrateTex.textFont(idFont);
		if (ccolor == 0) {
			calibrateTex.fill(255);
		} else {
			calibrateTex.fill(0);
		}

		calibrateTex.textAlign(PApplet.CENTER, PApplet.CENTER);
		calibrateTex.textSize(80);
		calibrateTex.text("" + surfaceId, (float) (calibrateTex.width * 0.5), (float) (calibrateTex.height * 0.5));
		if (isLocked) {
			calibrateTex.textSize(40);
			calibrateTex.text("Surface locked", (float) (calibrateTex.width * 0.5), (float) (calibrateTex.height * 0.7));
		}
		calibrateTex.endDraw();
		*/
	}

	/**
	 * Sets the fill color of the surface in calibration mode
	 * @param ccolor
	 */
	public void setColor(int ccolor) {
		this.ccolor = ccolor;
		updateCalibrateTexture();
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
		return GRID_RESOLUTION - 1;
	}

	/**
	 * Increase the subdivision
	 */
	public void increaseResolution() {
		this.GRID_RESOLUTION += 1;
		this.initTransform();
		this.updateTransform();
	}

	/**
	 * Decrease the subdivision
	 */
	public void decreaseResolution() {
		if ((this.GRID_RESOLUTION - 1) > 1) {
			this.GRID_RESOLUTION -= 1;
			this.initTransform();
			this.updateTransform();
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
			shakeAngle += (float)shakeSpeed/1000;
			shakeStrength *= ((float)this.fallOfSpeed/1000);
			float shakeZ = (float) (Math.sin(shakeAngle)*shakeStrength);
			this.setZ(shakeZ);
			if(shakeStrength < 1){
				shaking = false;
			}
		}
	}

	/**
	 *  Manually set coordinates for mapping the texture. This allows for easy cropping and 
	 *  enables a single texture to span more than one surface. CURRENTLY DISABLED!
	 */
	public void setTextureRect(float x, float y, float w, float h) {
		/*
		this.textureX = x;
		this.textureY = y;
		this.textureWidth = w;
		this.textureHeight = h;
		this.updateTransform();
		*/
	}

	/**
	 * Set the coordinates of one of the target corner points.
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

	public void setModeCalibrate() {
		this.MODE = this.MODE_CALIBRATE;
	}

	public void setModeRender() {
		this.MODE = this.MODE_RENDER;
	}

	public void toggleMode() {
		if (this.MODE == this.MODE_RENDER) {
			this.MODE = this.MODE_CALIBRATE;
		} else {
			this.MODE = this.MODE_RENDER;
		}
	}

	/**
	 * Get the index of the active corner
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
	 * Get all corners
	 * @return
	 */
	public Point3D[] getCornerPoints() {
		return this.cornerPoints;
	}

	/**
	 * Get a specific corner
	 * @param index
	 * @return
	 */
	public Point3D getCornerPoint(int index) {
		return this.cornerPoints[index];
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
	 * See if the surface is hidden
	 * @return
	 */
	public boolean isHidden() {
		return hidden;
	}

	/**
	 * Toggle if surface is locked (a locked surface cannot be moved or manipulated in calibration mode, but other surfaces still snap to it)
	 */
	public void toggleLocked() {
		this.isLocked = !this.isLocked;
		this.updateCalibrateTexture();
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
		this.updateCalibrateTexture();
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
	 * Set the currently selected corner
	 * @param selectedCorner
	 */
	public void setSelectedCorner(int selectedCorner) {
		this.selectedCorner = selectedCorner;
	}

	/**
	 * Get the surface as a polygon
	 * @return
	 */
	public Polygon getPolygon() {
		return poly;
	}

	/**
	 * Checks if the coordinates is close to any of the corners, and if not, checks if the coordinates are inside the surface.
	 * Returns the index of the corner (0,1,2,3) or (4) if coordinates was inside the surface 
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
	 * Check if coordinates are inside the surface
	 * @param mX
	 * @param mY
	 * @return
	 */
	public boolean isInside(float mX, float mY) {
		if (poly.contains(mX, mY))
			return true;
		return false;
	}

	/**
	 * Set all four corners of the surface
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
	 * Recalculates all coordinates using the perspective transform.
	 * Must be called whenever any change has been done to the surface.
	 */
	private void updateTransform() {
		// Update the PerspectiveTransform with the current width, height, and
		// destination coordinates.
		this.transform = PerspectiveTransform.getQuadToQuad(0, 0, this.DEFAULT_SIZE, 0, this.DEFAULT_SIZE, this.DEFAULT_SIZE, 0, this.DEFAULT_SIZE, 
															this.cornerPoints[0].x, this.cornerPoints[0].y, this.cornerPoints[1].x, this.cornerPoints[1].y, 
															this.cornerPoints[2].x, this.cornerPoints[2].y, this.cornerPoints[3].x, this.cornerPoints[3].y);

		// calculate the x and y interval to subdivide the source rectangle into
		// the desired resolution.
		float stepX = this.DEFAULT_SIZE / (float) (this.GRID_RESOLUTION - 1);
		float stepY = this.DEFAULT_SIZE / (float) (this.GRID_RESOLUTION - 1);

		// figure out the number of points in the whole grid.
		int numPoints = this.GRID_RESOLUTION * this.GRID_RESOLUTION;

		// create the array of floats (used for input into the transform method,
		// it requires a single array of floats)
		float[] srcPoints = new float[numPoints * 2];

		// calculate the source coordinates of the grid points, as well as the
		// texture coordinates of the destination points.
		int i = 0;
		for (int y = 0; y < this.GRID_RESOLUTION; y++) {
			for (int x = 0; x < this.GRID_RESOLUTION; x++) {
				float percentX = (x * stepX) / this.DEFAULT_SIZE;
				float percentY = (y * stepY) / this.DEFAULT_SIZE;

				this.gridPoints[x + y * this.GRID_RESOLUTION].u = this.DEFAULT_SIZE * percentX + this.textureX;
				this.gridPoints[x + y * this.GRID_RESOLUTION].v = this.DEFAULT_SIZE * percentY + this.textureY; // y
																													// *
																													// stepY;

				srcPoints[i++] = x * stepX;
				srcPoints[i++] = y * stepY;
			}
		}

		// create an array for the transformed points (populated by
		// PerspectiveTransform.transform())
		float[] transformed = new float[srcPoints.length];

		// perform the transformation.
		this.transform.transform(srcPoints, 0, transformed, 0, numPoints);

		// convert the array of float values back into x/y pairs in the Point3D
		// class for ease of use later.
		for (int p = 0; p < numPoints; p++) {
			this.gridPoints[p].x = transformed[p * 2];
			this.gridPoints[p].y = transformed[p * 2 + 1];
		}

		// Precompute the verticies for use in rendering.
		int offset = 0;
		int vertextIndex = 0;
		for (int x = 0; x < this.GRID_RESOLUTION - 1; x++) {
			for (int y = 0; y < this.GRID_RESOLUTION - 1; y++) {
				offset = x + y * this.GRID_RESOLUTION;

				this.vertexPoints[x][y].copyPoint(this.gridPoints[offset]);
				this.vertexPoints[x+1][y].copyPoint(this.gridPoints[offset + 1]);

				offset = x + (y + 1) * this.GRID_RESOLUTION;

				this.vertexPoints[x+1][y+1].copyPoint(this.gridPoints[offset + 1]);
				this.vertexPoints[x][y+1].copyPoint(this.gridPoints[offset]);
			}
		}

		// keep track of the four transformed corner points for use in
		// calibration mode.
		this.cornerPoints[0].x = this.gridPoints[0].x;
		this.cornerPoints[0].y = this.gridPoints[0].y;

		this.cornerPoints[1].x = this.gridPoints[this.GRID_RESOLUTION - 1].x;
		this.cornerPoints[1].y = this.gridPoints[this.GRID_RESOLUTION - 1].y;

		this.cornerPoints[2].x = this.gridPoints[this.gridPoints.length - 1].x;
		this.cornerPoints[2].y = this.gridPoints[this.gridPoints.length - 1].y;

		this.cornerPoints[3].x = this.gridPoints[this.gridPoints.length - this.GRID_RESOLUTION].x;
		this.cornerPoints[3].y = this.gridPoints[this.gridPoints.length - this.GRID_RESOLUTION].y;

		poly = new Polygon();

		poly.addPoint((int) cornerPoints[0].x, (int) cornerPoints[0].y);
		poly.addPoint((int) cornerPoints[1].x, (int) cornerPoints[1].y);
		poly.addPoint((int) cornerPoints[2].x, (int) cornerPoints[2].y);
		poly.addPoint((int) cornerPoints[3].x, (int) cornerPoints[3].y);
	}

	/**
	 *  Find the average position of all the control points, use that as the center point.
	 * @return
	 */
	public Point3D getCenter() {
		
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
	 * Translate a point on the screen into a point in the surface.
	 * @param x
	 * @param y
	 * @return
	 */
	public Point3D screenCoordinatesToQuad(float x, float y) {
		double[] srcPts = new double[2];
		srcPts[0] = x;
		srcPts[1] = y;

		double[] dstPts = new double[2];

		try {
			this.transform.inverseTransform(srcPts, 0, dstPts, 0, 1);
		} catch (Exception e) {
			return new Point3D(0, 0);
		}

		return new Point3D((float) dstPts[0], (float) dstPts[1]);
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
		this.renderQuad(g, tex);
	}

	/**
	 * Actual rendering of the QUAD. Is called from the render method.
	 * Should normally not be accessed directly.
	 * @param g
	 * @param tex
	 */
	private void renderQuad(GLGraphicsOffScreen g, GLTexture tex) {
		g.beginDraw();
		g.noStroke();
		g.beginShape(PApplet.QUADS);

		g.texture(tex);
		
		for (int i = 0; i < GRID_RESOLUTION-1; i++) {
			for (int j = 0; j < GRID_RESOLUTION-1; j++) {
				
				
				g.vertex(vertexPoints[i][j].x, 
						vertexPoints[i][j].y, 
						vertexPoints[i][j].z+currentZ,
						((float) i / (GRID_RESOLUTION-1)) * tex.width,
						((float) j / (GRID_RESOLUTION-1)) * tex.height);
				
				g.vertex(vertexPoints[i + 1][j].x, 
						vertexPoints[i + 1][j].y,
						vertexPoints[i + 1][j].z+currentZ, 
						(((float) i + 1) / (GRID_RESOLUTION-1)) * tex.width, 
						((float) j / (GRID_RESOLUTION-1)) * tex.height);
				
				g.vertex(vertexPoints[i + 1][j + 1].x, 
						vertexPoints[i + 1][j + 1].y,
						vertexPoints[i + 1][j + 1].z+currentZ, 
						(((float) i + 1) / (GRID_RESOLUTION-1)) * tex.width, 
						(((float) j + 1) / (GRID_RESOLUTION-1)) * tex.height);
				
				g.vertex(vertexPoints[i][j + 1].x, 
						vertexPoints[i][j + 1].y,
						vertexPoints[i][j + 1].z+currentZ, 
						((float) i / (GRID_RESOLUTION-1)) * tex.width,
						(((float) j + 1) / (GRID_RESOLUTION-1)) * tex.height);
				
				
			}
		}

		g.endShape(PApplet.CLOSE);
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
		g.beginShape(PApplet.QUADS);
		for(int i = 0; i < this.getCornerPoints().length; i++){
			g.vertex(this.getCornerPoint(i).x, this.getCornerPoint(i).y);
		}
		g.endShape();
		
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
		g.stroke(QuadSurface.GRID_LINE_COLOR);
		g.strokeWeight(2);
		if (isSelected)
			g.stroke(QuadSurface.GRID_LINE_SELECTED_COLOR);

		if (!isLocked) {
			// Draw vertial grid lines
			int rowOffset = (this.GRID_RESOLUTION * this.GRID_RESOLUTION) - this.GRID_RESOLUTION;
			for (int i = 0; i < this.GRID_RESOLUTION; i++) {
				g.line(this.gridPoints[i].x, this.gridPoints[i].y, this.gridPoints[i + rowOffset].x, this.gridPoints[i + rowOffset].y);
			}

			// Draw horezontal grid lines
			for (int y = 0; y < this.GRID_RESOLUTION; y++) {
				int row = this.GRID_RESOLUTION * y;
				g.line(this.gridPoints[row].x, this.gridPoints[row].y, this.gridPoints[row + this.GRID_RESOLUTION - 1].x, this.gridPoints[row + this.GRID_RESOLUTION - 1].y);
			}
		}

		if (isSelected) {
			g.stroke(SELECTED_OUTLINE_OUTER_COLOR);
			g.strokeWeight(5);
			g.line(cornerPoints[0].x, cornerPoints[0].y, cornerPoints[1].x, cornerPoints[1].y);
			g.line(cornerPoints[1].x, cornerPoints[1].y, cornerPoints[2].x, cornerPoints[2].y);
			g.line(cornerPoints[2].x, cornerPoints[2].y, cornerPoints[3].x, cornerPoints[3].y);
			g.line(cornerPoints[3].x, cornerPoints[3].y, cornerPoints[0].x, cornerPoints[0].y);
		}
		g.stroke(SELECTED_OUTLINE_INNER_COLOR);
		g.strokeWeight(1);
		g.line(cornerPoints[0].x, cornerPoints[0].y, cornerPoints[1].x, cornerPoints[1].y);
		g.line(cornerPoints[1].x, cornerPoints[1].y, cornerPoints[2].x, cornerPoints[2].y);
		g.line(cornerPoints[2].x, cornerPoints[2].y, cornerPoints[3].x, cornerPoints[3].y);
		g.line(cornerPoints[3].x, cornerPoints[3].y, cornerPoints[0].x, cornerPoints[0].y);

		if (!isLocked) {
			// Draw the control points.
			for (int i = 0; i < this.cornerPoints.length; i++) {
				this.renderCornerPoint(g, this.cornerPoints[i].x, this.cornerPoints[i].y, (this.activePoint == i), i);
			}

		}

		g.endDraw();
	}

	/**
	 * Draws the Cornerpoints
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
			g.stroke(QuadSurface.SELECTED_CORNER_MARKER_COLOR);
		} else {
			g.stroke(QuadSurface.CORNER_MARKER_COLOR);
		}
		if (cornerIndex == getSelectedCorner() && isSelected()) {
			g.fill(QuadSurface.SELECTED_CORNER_MARKER_COLOR, 100);
			g.stroke(QuadSurface.SELECTED_CORNER_MARKER_COLOR);
		}
		g.ellipse(x, y, 16, 16);
		g.line(x, y - 8, x, y + 8);
		g.line(x - 8, y, x + 8, y);
	}

	public void setSurfaceName(String surfaceName) {
		this.surfaceName = surfaceName;
	}

	public String getSurfaceName() {
		if(surfaceName == null) return String.valueOf(this.getId());
		return surfaceName;
	}


}