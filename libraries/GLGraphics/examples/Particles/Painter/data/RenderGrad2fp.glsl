/**
 * Render gradient to Floating Point texture shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL fragment shader calculates the gradient of the luminance
 * of the input image, by means of the Sobel gradient operator.
 * The resulting gradient vector is normalized as well.
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

#define KERNEL_SIZE 9

vec2 kernel[KERNEL_SIZE];

uniform sampler2D src_tex_unit0; // Image texture
uniform sampler2D src_tex_unit1; // Random texture

uniform vec2 src_tex_offset0;    // Texture scaling factor

vec2 offset[KERNEL_SIZE];

vec3 lum_coeff;

void main(void)
{
    float luminance;
    vec3 color;
    vec2 grad_sum;

    kernel[0] = vec2(-1.0, +1.0);   kernel[1] = vec2(0.0, +2.0);    kernel[2] = vec2(+1.0, +1.0);
    kernel[3] = vec2(-2.0,  0.0);   kernel[4] = vec2(0.0,  0.0);    kernel[5] = vec2(+2.0,  0.0);
    kernel[6] = vec2(-1.0, -1.0);   kernel[7] = vec2(0.0, -2.0);    kernel[8] = vec2(+1.0, -1.0);

    lum_coeff = vec3(0.299, 0.587, 0.114);

    offset[0] = vec2(-src_tex_offset0.s, -src_tex_offset0.t); 
    offset[1] = vec2(-src_tex_offset0.s, 0.0); 
    offset[2] = vec2(-src_tex_offset0.s, src_tex_offset0.t);
    
    offset[3] = vec2(0.0, -src_tex_offset0.t);          
    offset[4] = vec2(0.0, 0.0);          
    offset[5] = vec2(0.0, src_tex_offset0.t);
    
    offset[6] = vec2(src_tex_offset0.s, -src_tex_offset0.t);  
    offset[7] = vec2(src_tex_offset0.s, 0.0);  
    offset[8] = vec2(src_tex_offset0.s, src_tex_offset0.t);

    // Calculating gradient of the luminance at point (coord0.s, coord0.t) of the image.
    grad_sum = vec2(0.0, 0.0);
    for (int k = 0; k < KERNEL_SIZE; k++)
    {
        color = texture2D(src_tex_unit0, gl_TexCoord[0].st + offset[k]).rgb;
        luminance = dot(lum_coeff, color);
        grad_sum += luminance * kernel[k];
    }

    // Normalizing the gradient.
    float grad_norm = sqrt(grad_sum.x * grad_sum.x + grad_sum.y * grad_sum.y);
    if (0.0 < grad_norm) grad_sum /= grad_norm;
    else grad_sum = texture2D(src_tex_unit1, gl_TexCoord[0].st).xy;

    gl_FragColor = vec4(grad_sum.xy, 0.0, 1.0);
}
