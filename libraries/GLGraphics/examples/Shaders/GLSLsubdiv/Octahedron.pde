void genOctahedron() {
  vertices = new ArrayList();
  normals = new ArrayList();

  addTriangle(0.0, 0.0, 1.0,
              1.0, 0.0, 0.0, 
              0.0, 1.0, 0.0);

  addTriangle(1.0, 0.0, 0.0,
              0.0, 0.0, -1.0, 
              0.0, 1.0, 0.0);

  addTriangle(0.0, 0.0, -1.0, 
              -1.0, 0.0, 0.0,
              0.0, 1.0, 0.0);

  addTriangle(-1.0, 0.0, 0.0,
              0.0, 0.0, 1.0,
              0.0, 1.0, 0.0);

  addTriangle(0.0, 0.0, 1.0,
              1.0, 0.0, 0.0,
              0.0, -1.0, 0.0);

  addTriangle(1.0, 0.0, 0.0,
              0.0, 0.0, -1.0,
              0.0, -1.0, 0.0);

  addTriangle(0.0, 0.0, -1.0,
              -1.0, 0.0, 0.0,
              0.0, -1.0, 0.0);

  addTriangle(-1.0, 0.0, 0.0,
              0.0, 0.0, 1.0,
              0.0, -1.0, 0.0);
}

void addTriangle(float x0, float y0, float z0,
                 float x1, float y1, float z1,
                 float x2, float y2, float z2) {
    PVector v0 = new PVector(x0, y0, z0);
    PVector v1 = new PVector(x1, y1, z1);    
    PVector v2 = new PVector(x2, y2, z2);
    
    PVector v01 = PVector.sub(v1, v0);
    PVector v02 = PVector.sub(v2, v0);    
    PVector tnorm = v01.cross(v02);
    
    vertices.add(v0);
    vertices.add(v1);    
    vertices.add(v2);
    
    normals.add(tnorm); 
    normals.add(tnorm);
    normals.add(tnorm);    
}

