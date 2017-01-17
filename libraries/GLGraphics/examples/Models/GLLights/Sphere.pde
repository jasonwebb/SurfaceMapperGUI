float SINCOS_PRECISION = 0.5;
int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);  

GLModel createSphere(int detail, float radius)
{
    float[] cx, cz, sphereX, sphereY, sphereZ;
    float sinLUT[];
    float cosLUT[];
    float delta, angle_step, angle;
    int vertCount, currVert;
    float r;
    int v1, v11, v2, voff;    
    ArrayList vertices;
    ArrayList normals;    
      
    sinLUT = new float[SINCOS_LENGTH];
    cosLUT = new float[SINCOS_LENGTH];

    for (int i = 0; i < SINCOS_LENGTH; i++) 
    {
        sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
        cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
    }  
  
    delta = float(SINCOS_LENGTH / detail);
    cx = new float[detail];
    cz = new float[detail];

    // Calc unit circle in XZ plane
    for (int i = 0; i < detail; i++) 
    {
        cx[i] = -cosLUT[(int) (i * delta) % SINCOS_LENGTH];
        cz[i] = sinLUT[(int) (i * delta) % SINCOS_LENGTH];
    }

    // Computing vertexlist vertexlist starts at south pole
    vertCount = detail * (detail - 1) + 2;
    currVert = 0;
  
    // Re-init arrays to store vertices
    sphereX = new float[vertCount];
    sphereY = new float[vertCount];
    sphereZ = new float[vertCount];
    angle_step = (SINCOS_LENGTH * 0.5f) / detail;
    angle = angle_step;
  
    // Step along Y axis
    for (int i = 1; i < detail; i++) 
    {
        float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
        float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
        for (int j = 0; j < detail; j++) 
        {
            sphereX[currVert] = cx[j] * curradius;
            sphereY[currVert] = currY;
            sphereZ[currVert++] = cz[j] * curradius;
        }
        angle += angle_step;
    }

    vertices = new ArrayList();
    normals = new ArrayList();

    r = radius;

    // Add the southern cap    
    for (int i = 0; i < detail; i++) 
    {
        addVertex(vertices, normals, 0.0, -r, 0.0);
        addVertex(vertices, normals, sphereX[i] * r, sphereY[i] * r, sphereZ[i] * r);        
    }
    addVertex(vertices, normals, 0.0, -r, 0.0);
    addVertex(vertices, normals, sphereX[0] * r, sphereY[0] * r, sphereZ[0] * r);
  
    // Middle rings
    voff = 0;    
    for (int i = 2; i < detail; i++) 
    {
        v1 = v11 = voff;
        voff += detail;
        v2 = voff;
        for (int j = 0; j < detail; j++) 
        {
            addVertex(vertices, normals, sphereX[v1] * r, sphereY[v1] * r, sphereZ[v1++] * r);
            addVertex(vertices, normals, sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2++] * r);
        }
  
        // Close each ring
        v1 = v11;
        v2 = voff;
        addVertex(vertices, normals, sphereX[v1] * r, sphereY[v1] * r, sphereZ[v1] * r);
        addVertex(vertices, normals, sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2] * r);
    }
  
    // Add the northern cap
    for (int i = 0; i < detail; i++) 
    {
        v2 = voff + i;
        addVertex(vertices, normals, sphereX[v2] * r, sphereY[v2] * r, sphereZ[v2] * r);
        addVertex(vertices, normals, 0, r, 0);
    }
    addVertex(vertices, normals, sphereX[voff] * r, sphereY[voff] * r, sphereZ[voff] * r);
    

    GLModel model = new GLModel(this, vertices.size(), TRIANGLE_STRIP, GLModel.STATIC);
    
    // Sets the coordinates.
    model.updateVertices(vertices);    
    
    // Sets the normals.    
    model.initNormals();
    model.updateNormals(normals);    
    
    return model;
}

void addVertex(ArrayList vertices, ArrayList normals, float x, float y, float z)
{
    PVector vert = new PVector(x, y, z);
    PVector vertNorm = PVector.div(vert, vert.mag()); 
    vertices.add(vert);
    normals.add(vertNorm);
}
