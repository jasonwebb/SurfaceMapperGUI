/**
 * Move particle shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL fragment shader updates the position of the particles.
 * It uses the texture with the gradient of the luminance of the 
 * image to get the direction along which the particle has to
 * move in this iteration.
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

#define TWO_PI 6.28318531

uniform sampler2D src_tex_unit0; // Position texture
uniform sampler2D src_tex_unit1; // Gradient texture
uniform sampler2D src_tex_unit2; // Velocity texture
uniform sampler2D src_tex_unit3; // Noise texture

uniform vec2 max_pos;            // Maximum position
uniform int follow_grad;         // Follow gradient
uniform float mean_vel;          // Mean velocity
uniform float noise_mag;         // Noise magnitude

float wrap_coord(float v, float maxv)
{
    float f, fracf;
    int intf;

    f = v / maxv;
    intf = int(f);
    fracf = f - float(intf);
    if (f < 0.0) return (1.0 + fracf) * maxv;
    else if (1.0 < f) return fracf * maxv;
    else return v;
}

void main(void)
{
    vec2 tex_coord = gl_TexCoord[0].st;

    // Updating particle position.
    vec2 old_pos = texture2D(src_tex_unit0, tex_coord).xy;
    vec2 new_pos;
    
    if (bool(follow_grad))
    {
        vec2 norm_old_pos = vec2(old_pos.x / max_pos.x, old_pos.y / max_pos.y);	
        vec2 velocity = texture2D(src_tex_unit1, norm_old_pos).xy;
        float vcoeff = texture2D(src_tex_unit2, tex_coord).x;
        new_pos = old_pos + vcoeff * mean_vel * velocity;
    }
    else new_pos = old_pos;

    vec2 noise = texture2D(src_tex_unit3, tex_coord).xy;
    new_pos += noise_mag * noise;

    // Wrapping position around the edges...
    new_pos.x = wrap_coord(new_pos.x, max_pos.x); 
    new_pos.y = wrap_coord(new_pos.y, max_pos.y); 

    gl_FragColor = vec4(new_pos, 0.0, 1.0);
}
