#define TWO_PI 6.28318531
uniform sampler2D src_tex_unit0; 

uniform vec2 dest_tex_size;
uniform int dirs;

uniform float radio;
uniform float amp;

 
void main(void)
{
		
      
   	
 	vec2 tex_coords = gl_TexCoord[0].st;
 	vec4 orig ;
	vec4 sum = vec4(0.0)*0.01;
	
	//different distance for each color
	vec4 d=vec4(2,4,6,8);
	
   //iterate 9 times to get samples around the current point for median calculation
   for(int j=0; j<dirs; j++){
   	
   	//calculate the points for each distance
   float dir = float(j)*TWO_PI/float(dirs) + radio;
   	 
   	 //iterate each one of the colors
   for(int g=0; g<4;g++){
   	 		
		 float dx = (d[g] * cos(dir) * amp);
	     float dy = (d[g] * sin(dir) * amp);
	         
	  		vec2 point = (vec2(dx, dy)/dest_tex_size)+tex_coords;
	  		//calculate the median for 9
	  		sum[g] += texture2D(src_tex_unit0, point)[g]/8.;
	  		
	  		
	  		//feedback if it is bigger than one
	     	if(texture2D(src_tex_unit0, tex_coords)[g]>=1.){ 
	     			
	     		sum[g] = (texture2D(src_tex_unit0, tex_coords-4.)[g]+texture2D(src_tex_unit0, tex_coords+4.)[g])/16.;	  
	     		   				
	     		}
			
      	 	}
    
   
   }
   
   orig = sum;
	
   vec3 newColor  = orig.rgb;
   
   gl_FragColor = vec4(newColor, 1.);
   


}
