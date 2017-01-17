GLModel createTorus(float outerRad, float innerRad,
                    int numc, int numt, String texName) {
  GLModel model;  
  GLTexture tex;
  
  ArrayList vertices = new ArrayList();
  ArrayList normals = new ArrayList();  
  ArrayList texcoords = new ArrayList();
  
  float x, y, z, s, t, u, v;
  float nx, ny, nz;
  float aInner, aOuter;
  int idx = 0;
  for (int i = 0; i < numc; i++) {
    for (int j = 0; j <= numt; j++) {
      t = j;
      v = t / (float)numt;
      aOuter = v * TWO_PI;
      float cOut = cos(aOuter);
      float sOut = sin(aOuter);
      for (int k = 1; k >= 0; k--) {
         s = (i + k);
         u = s / (float)numc;
         aInner = u * TWO_PI;
         float cIn = cos(aInner);
         float sIn = sin(aInner);
         
         x = (outerRad + innerRad * cIn) * cOut;
         y = (outerRad + innerRad * cIn) * sOut;
         z = innerRad * sIn;
         
         nx = cIn * cOut; 
         ny = cIn * sOut;
         nz = sIn;
         
         vertices.add(new PVector(x, y, z));
         normals.add(new PVector(nx, ny, nz));         
         texcoords.add(new PVector(1.0-u, v));
      }
    }
  }
  
  model = new GLModel(this, vertices.size(), QUAD_STRIP, GLModel.STATIC);
  model.updateVertices(vertices);  
  
  tex = new GLTexture(this, texName);
  model.initTextures(1);
  model.setTexture(0, tex);
  model.updateTexCoords(0, texcoords);
  
  model.initNormals();
  model.updateNormals(normals);  

  return model;  
}
