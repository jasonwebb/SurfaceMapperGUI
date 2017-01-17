/**
 * Render brushes shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL vertex shader does vertex mapping displacement
 * by reading the position texture and using the fetched  
 * values to displace the input vertices to the correct
 * position that corresponds to the (x, y) location of
 * the particle.
 *
 */

/*
  Copyright (c) 2006 Andres Colubri

  This source is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This code is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  A copy of the GNU General Public License is available on the World
  Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also
  obtain it by writing to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

uniform sampler2D src_tex_unit3; // Position texture

uniform float brush_size;          // Brush size

void main(void)
{
    vec2 pos;
    vec4 newVertexPos;

    gl_TexCoord[0].xy = gl_MultiTexCoord0.xy;		
    gl_TexCoord[1].xy = gl_MultiTexCoord1.xy;	

    pos = texture2D(src_tex_unit3, gl_MultiTexCoord0.xy).xy;
	
    newVertexPos = vec4(pos + brush_size * gl_Vertex.xy, 0.0, gl_Vertex.w);
	
    gl_Position = gl_ModelViewProjectionMatrix * newVertexPos;
}
