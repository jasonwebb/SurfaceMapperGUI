/**
 * Part of the GLGraphics library: http://glgraphics.sourceforge.net/
 * Copyright (c) 2008-11 Andres Colubri 
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

package codeanticode.glgraphics;

import javax.media.opengl.*;

/**
 * @invisible Base class to define texture grids.
 */
abstract class GLTextureGrid implements GLConstants {
  protected GL gl;
  protected boolean usingSrcTexRes;
  protected int srcTexIdx;
    
  public GLTextureGrid(GL gl) {
    this.gl = gl;
    usingSrcTexRes = false;
    srcTexIdx = 0;
  }

  public void delete() {  
  }
  
  public void render(int sW, int sH, int dW, int dH, int l) {
    render(sW, sH, dW, dH, l, 
           0, 0, sW, sH);
  }
  
  abstract public void render(int sW, int sH, int dW, int dH, int l, 
                              int cX0, int cY0, int cX1, int cY1);

  public boolean isUsingSrcTexRes() {
    return usingSrcTexRes;
  }

  public int srcTexInUse() {
    return srcTexIdx;
  }
}
