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

public class Point3D {
	public float x = 0;
	public float y = 0;
	public float z = 0;

	public float u = 0;
	public float v = 0;
	
	public Point3D(float x, float y, float z){
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public Point3D(float x, float y){
		this.x = x;
		this.y = y;
		this.z = 0;
	}
	
	public Point3D(){
		this.x = 0;
		this.y = 0;
		this.z = 0;
	}

	void copyPoint(Point3D other) {
		this.x = other.x;
		this.y = other.y;
		this.z = other.z;
		this.v = other.v;
		this.u = other.u;
	}
}