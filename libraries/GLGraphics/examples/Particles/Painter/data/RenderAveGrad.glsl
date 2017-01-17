/**
 * Render brushes shader
 * by Andres Colubri. May 2008.
 * 
 * This GLSL fragment shader calculates the spatial average of the
 * luminance gradient in a 3x3 box around each pixel.
 * When the image is changing, the gradient of the new image is also
 * averaged and linearly combined with the old gradient, so that a
 * smooth transition is generated between the old and new gradient
 * fields.
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

uniform sampler2D src_tex_unit0; // Gradient texture
uniform sampler2D src_tex_unit1; // Random texture
uniform sampler2D src_tex_unit2; // New gradient texture

uniform vec2 src_tex_offset0;    // Texture scaling factor

uniform float new_grad_coeff;    // New gradient coefficient

void main(void)
{
    vec2 grad, newgrad, grad_sum, newgrad_sum, coord;
    float grad_length;

    vec2 coord0 = gl_TexCoord[0].st;

    grad_sum = vec2(0.0, 0.0);
    for (int i = -1; i <= +1; i++)
        for (int j = -1; j <= +1; j++)
        {
            coord = coord0 + vec2(src_tex_offset0.s * float(i), src_tex_offset0.t * float(j));
            grad = texture2D(src_tex_unit0, coord).xy;
            grad_sum += grad;
        }
    grad_sum /= 9.0;
    // Normalizing the gradient.
    grad_length = length(grad_sum);
    if (0.0 < grad_length) grad_sum /= grad_length;
    else grad_sum = texture2D(src_tex_unit1, coord0).xy;

    if ((0.0 <= new_grad_coeff) && (new_grad_coeff <= 1.0))
    {
        // Averaging new gradient.
        newgrad_sum = vec2(0.0, 0.0);
        for (int i = -1; i <= +1; i++)
            for (int j = -1; j <= +1; j++)
            {
                coord = coord0 + vec2(src_tex_offset0.s * float(i), src_tex_offset0.t * float(j));
                newgrad = texture2D(src_tex_unit2, coord).xy;
                newgrad_sum += newgrad;
            }
        newgrad_sum /= 9.0;
        // Normalizing the gradient.
        grad_length = length(newgrad_sum);
        if (0.0 < grad_length) newgrad_sum /= grad_length;
        else newgrad_sum = texture2D(src_tex_unit1, coord0).xy;

        // Calculating linear combination of old and new gradients.
        vec2 lc_grad = (1.0 - new_grad_coeff) * grad_sum + new_grad_coeff * newgrad_sum;
        grad_length = length(lc_grad);
        if (0.0 < grad_length) lc_grad /= grad_length;
        else lc_grad = texture2D(src_tex_unit1, coord0).xy;

        gl_FragData[0] = vec4(lc_grad.x, lc_grad.y, 0.0, 1.0);
        gl_FragData[1] = vec4(newgrad_sum.x, newgrad_sum.y, 0.0, 1.0);
    }
    else
        gl_FragData[0] = vec4(grad_sum.x, grad_sum.y, 0.0, 1.0);
}
