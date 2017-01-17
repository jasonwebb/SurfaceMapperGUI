/**
 * Render brushes shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL fragment shader renders the brushes that correspond to
 * each particle. The brush texture is rotated according to the 
 * direction vector determined by the gradient texture.
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

uniform sampler2D src_tex_unit0; // Gradient texture
uniform sampler2D src_tex_unit1; // Brush texture
uniform sampler2D src_tex_unit2; // Color texture
uniform sampler2D src_tex_unit3; // Position texture

uniform vec2 src_tex_offset0;    // Inverse of canvas size

void main(void)
{
	vec2 pos_coord = gl_TexCoord[0].st;
    vec2 brush_coord = gl_TexCoord[1].st;	
	vec2 color_coord = pos_coord;
	
	vec2 part_pos = texture2D(src_tex_unit3, pos_coord).xy;
    vec2 grad_coord = vec2(part_pos.x * src_tex_offset0.x, part_pos.y * src_tex_offset0.y);

    vec2 dir_vector = texture2D(src_tex_unit0, grad_coord).xy;
    float c = dir_vector.x;
    float s = dir_vector.y;
	
    // Compute vertex rotation matrix.
    mat2 rotation = mat2(+c, -s,
                         +s, +c);

    vec2 center_point = vec2(0.5, 0.5);
    vec2 rotated_coord = center_point + rotation * (brush_coord - center_point);

    float brush_alpha = texture2D(src_tex_unit1, rotated_coord).a;
    vec3 image_color = texture2D(src_tex_unit2, color_coord).rgb;
	
    gl_FragColor = vec4(image_color, brush_alpha);
}
