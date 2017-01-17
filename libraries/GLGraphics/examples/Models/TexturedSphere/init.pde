float SINCOS_PRECISION = 0.5;
int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);  

void calculateEarthCoords()
{
    float[] cx, cz, sphereX, sphereY, sphereZ;
    float sinLUT[];
    float cosLUT[];
    float delta, angle_step, angle;
    int vertCount, currVert;
    float r, u, v;
    int v1, v11, v2, voff;
    float iu, iv;
      
    sinLUT = new float[SINCOS_LENGTH];
    cosLUT = new float[SINCOS_LENGTH];

    for (int i = 0; i < SINCOS_LENGTH; i++) 
    {
        sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
        cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
    }  
  
    delta = float(SINCOS_LENGTH / globeDetail);
    cx = new float[globeDetail];
    cz = new float[globeDetail];

    // Calc unit circle in XZ plane
    for (int i = 0; i < globeDetail; i++) 
    {
        cx[i] = -cosLUT[(int) (i * delta) % SINCOS_LENGTH];
        cz[i] = sinLUT[(int) (i * delta) % SINCOS_LENGTH];
    }

    // Computing vertexlist vertexlist starts at south pole
    vertCount = globeDetail * (globeDetail - 1) + 2;
    currVert = 0;
  
    // Re-init arrays to store vertices
    sphereX = new float[vertCount];
    sphereY = new float[vertCount];
    sphereZ = new float[vertCount];
    angle_step = (SINCOS_LENGTH * 0.5f) / globeDetail;
    angle = angle_step;
  
    // Step along Y axis
    for (int i = 1; i < globeDetail; i++) 
    {
        float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
        float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
        for (int j = 0; j < globeDetail; j++) 
        {
            sphereX[currVert] = cx[j] * curradius;
            sphereY[currVert] = currY;
            sphereZ[currVert++] = cz[j] * curradius;
        }
        angle += angle_step;
    }

    vertices = new ArrayList();
    texCoords = new ArrayList();
    normals = new ArrayList();

    r = globeRadius;
    r = (r + 240 ) * 0.33;

    iu = (float) (1.0 / (globeDetail));
    iv = (float) (1.0 / (globeDetail));
    
    // Add the southern cap    
    u = 0;
    v = iv;
    for (int i = 0; i < globeDetail; i++) 
    {
        addVertex(0.0, -r, 0.0, u, 0);
        addVertex(sphereX[i] * r, sphereY[i] * r, sphereZ[i] * r, u, v);        
        u += iu;
    }
    addVertex(0.0, -r, 0.0, u, 0);
    addVertex(sphereX[0] * r, sphereY[0] * r, sphereZ[0] * r, u, v);
  
    // Middle rings
    voff = 0;
    for (int i = 2; i < globeDetail; i++) 
    {
        v1 = v11 = voff;
        voff += globeDetail;
        v2 = voff;
        u = 0;    
        for (int j = 0; j < globeDetail; j++) 
        {
            addVertex(sphereX[v1] * r, sphereY[v1] * r, sphereZ[v1++] * r, u, v);
            addVertex(sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2++] * r, u, v + iv);
            u += iu;
        }
  
        // Close each ring
        v1 = v11;
        v2 = voff;
        addVertex(sphereX[v1] * r, sphereY[v1] * r, sphereZ[v1] * r, u, v);
        addVertex(sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2] * r, u, v + iv);
        
        v += iv;
    }
    u=0;
  
    // Add the northern cap
    for (int i = 0; i < globeDetail; i++) 
    {
        v2 = voff + i;
        
        addVertex(sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2] * r, u, v);
        addVertex(0, r, 0, u, v + iv);
   
        u+=iu;
    }
    addVertex(sphereX[voff] * r, sphereY[voff] * r, sphereZ[voff] * r, u, v);
}

void addVertex(float x, float y, float z, float u, float v)
{
    PVector vert = new PVector(x, y, z);
    PVector texCoord = new PVector(u, v);
    PVector vertNorm = PVector.div(vert, vert.mag()); 
    vertices.add(vert);
    texCoords.add(texCoord);
    normals.add(vertNorm);
}
