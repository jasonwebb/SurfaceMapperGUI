/**
 * Color particle shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL fragment shader updates the color of the particles.
 * It uses the image texture to get the color of the underlying
 * pixel. However, the color a particle keeps its color for a
 * certain amount of time (to create the flow effect), so there
 * is a counter variable, stored in an auxiliar texture, to keep
 * track of the time that each particle has remained with the same
 * color.
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

#extension GL_ARB_draw_buffers : enable

uniform sampler2D src_tex_unit0; // Image texture
uniform sampler2D src_tex_unit1; // New image texture
uniform sampler2D src_tex_unit2; // Color texture
uniform sampler2D src_tex_unit3; // Auxiliar color texture
uniform sampler2D src_tex_unit4; // Position texture
uniform sampler2D src_tex_unit5; // Counter texture

uniform vec2 src_tex_offset0;    // Inverse of canvas size

uniform int max_brush_len;       // Maximum brush length
uniform float new_img_coeff;     // New image coefficient
uniform float color_chg_frac;    // Color change fraction
uniform float color_chg_pow;     // Color change power

void main(void)
{
    vec2 pos_coord = gl_TexCoord[0].st;

    vec2 part_pos = texture2D(src_tex_unit4, pos_coord).xy;
    vec2 image_coord = vec2(part_pos.x * src_tex_offset0.x, part_pos.y * src_tex_offset0.y);
	
    vec3 image_color, final_color, newimage_color;
    float inv_nsteps, arg, frac;
    int lim;

    bool color_chg = (0.0 <= new_img_coeff) && (new_img_coeff <= 1.0);

    vec3 prev_color = texture2D(src_tex_unit2, pos_coord).rgb;
    vec3 aux_data = texture2D(src_tex_unit3, pos_coord).rgb;
	
    vec2 count_vec = texture2D(src_tex_unit5, pos_coord).xy;
    count_vec.y = 1.0;
    int count = int(count_vec.x);
    int max_count = int(count_vec.y * float(max_brush_len));
    if (max_count < 1) max_count = 1;
	
    if (count < max_count)
    {
        // The particle keeps the previous color.
        gl_FragData[0] = vec4(prev_color, 1.0);
        gl_FragData[1] = vec4(aux_data, 1.0);
	gl_FragData[2] = vec4(count + 1, count_vec.y, 0.0, 1.0);
    }
    else
    {
        // Getting new color for the particle.
        if (count == max_count)
        {
            image_color = texture2D(src_tex_unit0, image_coord).rgb;
        }
        else
        {
            image_color = aux_data;
        }

        if (color_chg)
        {
            newimage_color = texture2D(src_tex_unit1, image_coord).xyz;
            image_color = (1.0 - new_img_coeff) * image_color + new_img_coeff * newimage_color;
        }

        // Evaluating final color...
        // Continuous transition between prev_color and image_color.
        lim = int((1.0 + color_chg_frac) * float(max_count));
        if (lim < 10) lim = 0; // If the number of transition steps is too small, then there is no transition at all.
        if (count <= lim)
        {
            inv_nsteps = 1.0 / (color_chg_frac * float(max_count));
            arg = inv_nsteps * (float(count - max_count));
            frac = pow(arg, color_chg_pow);

            final_color = (1.0 - frac) * prev_color +  frac * image_color;
            count++;
        }
        else 
        {
            final_color = image_color;
            count = 0;
        }
		
        gl_FragData[0] = vec4(final_color, 1.0);
        gl_FragData[1] = vec4(image_color, 1.0);	
	gl_FragData[2] = vec4(count, count_vec.y, 0.0, 1.0);
    }
}
