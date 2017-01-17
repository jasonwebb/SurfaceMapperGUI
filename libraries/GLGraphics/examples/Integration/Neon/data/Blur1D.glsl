uniform sampler2D tex;
uniform vec2 offset;
uniform vec2 dir;

void main(void)
{
   vec2 dst[13];
   float kernel[13];

   dst[0] =  vec2(-6, -6) * offset * dir;
   dst[1] =  vec2(-5, -5) * offset * dir;
   dst[2] =  vec2(-4, -4) * offset * dir;
   dst[3] =  vec2(-3, -3) * offset * dir;
   dst[4] =  vec2(-2, -2) * offset * dir;
   dst[5] =  vec2(-1, -1) * offset * dir;
   dst[6] =  vec2( 0,  0) * offset * dir;
   dst[7] =  vec2(+1, +1) * offset * dir;
   dst[8] =  vec2(+2, +2) * offset * dir;
   dst[9] =  vec2(+3, +3) * offset * dir;
   dst[10] = vec2(+4, +4) * offset * dir;
   dst[11] = vec2(+5, +5) * offset * dir;
   dst[12] = vec2(+6, +6) * offset * dir;
 
   kernel[0] = 0.002216;
   kernel[1] = 0.008764;
   kernel[2] = 0.026995;
   kernel[3] = 0.064759;
   kernel[4] = 0.120985;
   kernel[5] = 0.176033;
   kernel[6] = 0.199471;
   kernel[7] = 0.176033;
   kernel[8] = 0.120985;
   kernel[9] = 0.064759;
   kernel[10] = 0.026995;
   kernel[11] = 0.008764;
   kernel[12] = 0.002216;

   vec2 st = gl_TexCoord[0].st;
   vec4 color = vec4(0, 0, 0, 0);

   // Apply 1D gaussian filter of width 13.
   for (int i = 0; i < 13; i++) 
   {
      color += texture2D(tex, st + dst[i]) * kernel[i];
   }

   gl_FragColor = color;
}

