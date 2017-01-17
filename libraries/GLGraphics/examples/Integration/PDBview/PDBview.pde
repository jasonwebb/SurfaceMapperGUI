// Simple sketch to display protein 3D structure in PDB format.
// It uses Proscene for view manipulation. Download Proscene from:
// http://code.google.com/p/proscene/
// By Andres Colubri

import processing.opengl.*;
import codeanticode.glgraphics.*;
import remixlab.proscene.*;

String PDB_FILE = "abh0.pdb"; // PDB file to read.

// Some parameters to control the visual appearance:
float scaleFactor = 5;        // Size scale factor.
int renderMode = 1;           // 0 = lines, 1 = flat ribbons
int ribbonDetail = 1;         // Ribbon detail: from 1 (highest) to 10 (lowest).
float helixWidth = 10;        // Controls the helix diameter.

ArrayList models;

BSpline splineSide1;
BSpline splineCenter;
BSpline splineSide2;
PVector flipTestV;
int[] ribbonWidth;

float avex, avey, avez;
int natoms;

Scene scene;
InteractiveFrame frame;

int HELIX = 0;
int STRAND = 1;
int COIL = 2;
int LHANDED = -1;
int RHANDED = 1;

void setup() {
  size(800, 600, GLConstants.GLGRAPHICS);

  scene = new Scene(this);     
  //scene.setGridIsDrawn(true);
  scene.setAxisIsDrawn(false);
  scene.setRadius(100);
  scene.showAll();  

  frame = new InteractiveFrame(scene);
  frame.setPosition(new PVector(0, 0, 0));

  splineSide1 = new BSpline(false);
  splineCenter = new BSpline(false);
  splineSide2 = new BSpline(false);

  ribbonWidth = new int[3];
  ribbonWidth[HELIX] = 10;
  ribbonWidth[STRAND] = 7;  
  ribbonWidth[COIL] = 2;
  flipTestV = new PVector();

  loadPDB(PDB_FILE);
}

void draw() {
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL(); 
  
  background(0);

  pointLight(250, 250, 250, 0, 0, 400);

  GLModel model;
  for (int i = 0; i < models.size(); i++) {
    model = (GLModel)models.get(i);

    // Paints structure red or blue depending on
    // whether the mouse is hovering over the 
    // center of the structure.
    pushMatrix();
    frame.applyTransformation(this);
    if (frame.grabsMouse()) model.setTint(200, 50, 50, 230);
    else model.setTint(50, 50, 200, 230);
    popMatrix();

    renderer.model(model);
  }

  renderer.endGL();      
}

void loadPDB(String filename) {
  String strLines[];

  String xstr, ystr, zstr;
  float x, y, z;
  int res, res0;
  int nmdl;
  String atstr, resstr;

  HashMap residue;
  ArrayList residues;
  ArrayList atoms;
  GLModel model;
  PVector v;
  String s;
  strLines = loadStrings(filename);

  models = new ArrayList();

  avex = avey = avez = 0;
  natoms = 0;

  boolean readingModel = false;
  atoms = null;
  residues = null;
  res0 = -1;    
  nmdl = -1;
  residue = null;
  model = null;
  for (int i = 0; i < strLines.length; i++) {
    s = strLines[i];

    if (s.startsWith("MODEL") || (s.startsWith("ATOM") && nmdl == -1)) {
      nmdl++;

      residue = null;
      res0 = -1;

      atoms = new ArrayList();
      residues = new ArrayList();
    }

    if (s.startsWith("ATOM")) {
      atstr = s.substring(12, 15);
      atstr = atstr.trim();
      resstr = s.substring(22, 26);
      resstr = resstr.trim();
      res = parseInt(resstr);

      xstr = s.substring(30, 37);
      xstr = xstr.trim();
      ystr = s.substring(38, 45);
      ystr = ystr.trim();            
      zstr = s.substring(46, 53);
      zstr = zstr.trim();

      x = scaleFactor * parseFloat(xstr);
      y = scaleFactor * parseFloat(ystr);
      z = scaleFactor * parseFloat(zstr);            
      v = new PVector(x, y, z);

      avex += x;
      avey += y;
      avez += z;
      natoms++;

      atoms.add(v);

      if (res0 != res) {
        if (residue != null) residues.add(residue);            
        residue = new HashMap();
      }
      residue.put(atstr, v);

      res0 = res;
    }

    if (s.startsWith("ENDMDL")) {
      if (residue != null) residues.add(residue);

      createRibbonModel(residues, model, models);
      float rgyr = calculateGyrRadius(atoms);

      residue = null;  
      atoms = null;
      residues = null;
    }
  }

  if (residue != null) {
    if (residue != null) residues.add(residue);

    createRibbonModel(residues, model, models);
    float rgyr = calculateGyrRadius(atoms);

    atoms = null;
    residues = null;
  }

  // Centering model.  
  avex /= natoms;
  avey /= natoms;
  avez /= natoms;
  for (int i = 0; i < models.size(); i++) {
    model = (GLModel)models.get(i);
    model.beginUpdateVertices();
    for (int k = 0; k < model.getSize(); k++) {
      model.displaceVertex(k, -avex, -avey, -avez);
    }
    model.endUpdateVertices();
  }

  println("Loaded PDB file with " + models.size() + " models.");
}

void createRibbonModel(ArrayList residues, GLModel model, ArrayList trj) {
  ArrayList vertices;
  ArrayList normals;
  vertices = new ArrayList();
  normals = new ArrayList();

  int[] ss = new int[residues.size()];
  int[] handness = new int[residues.size()];

  calculateSecStr(residues, ss, handness);   

  for (int i = 0; i < residues.size(); i++) {
    constructControlPoints(residues, i, ss[i], handness[i]);

    if (renderMode == 0) {
      generateSpline(0, vertices);
      generateSpline(1, vertices);        
      generateSpline(2, vertices);        
    } 
    else generateFlatRibbon(vertices, normals);
  }  

  if (renderMode == 0) { 
    model = new GLModel(this, vertices.size(), LINES, GLModel.STATIC);
    model.updateVertices(vertices);
    model.initColors();
    model.setColors(255, 100);      
  } else {
    model = new GLModel(this, vertices.size(), QUADS, GLModel.STATIC);
    model.updateVertices(vertices);
    model.initNormals();
    model.updateNormals(normals);
  }

  trj.add(model);

  println("Adding new model with " + vertices.size() + " vertices.");
}

float calculateGyrRadius(ArrayList atoms)
{
  PVector ati, atj;
  float dx, dy, dz;    
  float r = 0;
  for (int i = 0; i < atoms.size(); i++) {
    ati = (PVector)atoms.get(i);
    for (int j = i + 1; j < atoms.size(); j++) {  
      atj = (PVector)atoms.get(j);

      dx = ati.x - atj.x;
      dy = ati.y - atj.y;
      dz = ati.z - atj.z;
      r +=  dx * dx + dy * dy + dz * dz;
    }
  }
  return sqrt(r) / (atoms.size() + 1);
}

void calculateSecStr(ArrayList residues, int[] ss, int[] handness) {
  PVector c0, n1, ca1, c1, n2;
  HashMap res0, res1, res2;
  int n = residues.size();

  float[] phi = new float[n];
  float[] psi = new float[n];

  for (int i = 0; i < n; i++) {
    if (i == 0 || i == n - 1) {
      phi[i] = 90;
      psi[i] = 90;              
    } else {
      res0 = (HashMap)residues.get(i - 1);
      res1 = (HashMap)residues.get(i);
      res2 = (HashMap)residues.get(i + 1);

      c0 = (PVector)res0.get("C");
      n1 = (PVector)res1.get("N");
      ca1 = (PVector)res1.get("CA"); 
      c1 = (PVector)res1.get("C");
      n2 = (PVector)res2.get("N");

      phi[i] = calculateTorsionalAngle(c0, n1, ca1, c1);
      psi[i] = calculateTorsionalAngle(n1, ca1, c1, n2);
    }
  }  

  int firstHelix = 0;
  int nconsRHelix = 0;
  int nconsLHelix = 0;
  int firstStrand = 0;
  int nconsStrand = 0;
  for (int i = 0; i < n; i++) {
    // Right-handed helix      
    if ((dist(phi[i], psi[i], -60, -45) < 30) && (i < n - 1)) {
      if (nconsRHelix == 0) firstHelix = i;
      nconsRHelix++;
    } 
    else {
      if (3 <= nconsRHelix) {
        for (int k = firstHelix; k < i; k++) {
          ss[k] = HELIX;
          handness[k] = RHANDED;                  
        }
      }
      nconsRHelix = 0;
    }

    // Left-handed helix
    if ((dist(phi[i], psi[i], +60, +45) < 30) && (i < n - 1)) {
      if (nconsLHelix == 0) firstHelix = i;
      nconsLHelix++;

    } else {
      if (3 <= nconsLHelix) {
        for (int k = firstHelix; k < i; k++) {
          ss[k] = HELIX;
          handness[k] = LHANDED;
        }
      }
      nconsLHelix = 0;
    }

    // Strand
    if ((dist(phi[i], psi[i], -110, +130) < 30) && (i < n - 1)) {
      if (nconsStrand == 0) firstStrand = i;
      nconsStrand++;
    } else {
      if (2 <= nconsStrand) {
        for (int k = firstStrand; k < i; k++) {
          ss[k] = STRAND;
          handness[k] = RHANDED;

        }
      }
      nconsStrand = 0;
    }        

    ss[i] = COIL;
    handness[i] = RHANDED;
  }
}

float calculateTorsionalAngle(PVector at0, PVector at1, PVector at2, PVector at3) {
  PVector r01 = PVector.sub(at0, at1);
  PVector r32 = PVector.sub(at3, at2);
  PVector r12 = PVector.sub(at1, at2);

  PVector p = r12.cross(r01);
  PVector q = r12.cross(r32);
  PVector r = r12.cross(q);

  float u = q.dot(q);
  float v = r.dot(r);    

  float a;
  if (u <= 0.0 || v <= 0.0) {
    a = 360.0;
  } else {
    float u1 = p.dot(q); // u1 = p * q
    float v1 = p.dot(r); // v1 = p * r

      u = u1 / sqrt(u);
    v = v1 / sqrt(v);

    if (abs(u) > 0.01 || abs(v) > 0.01) a = degrees(atan2(v, u));
    else a = 360.0;
  }    
  return a;
}


void generateSpline(int n, ArrayList vertices) {
  int ui;
  float u;
  PVector v0, v1;

  v0 = new PVector();
  v1 = new PVector();

  if (n == 0) splineSide1.feval(0, v1); 
  else if (n == 1) splineCenter.feval(0, v1);
  else splineSide2.feval(0, v1);

  for (ui = 1; ui <= 10; ui ++) {
    if (ui % ribbonDetail == 0) {
      u = 0.1 * ui; 
      v0.set(v1);

      if (n == 0) splineSide1.feval(u, v1); 
      else if (n == 1) splineCenter.feval(u, v1); 
      else splineSide2.feval(u, v1);

      vertices.add(new PVector(v0.x, v0.y, v0.z));
      vertices.add(new PVector(v1.x, v1.y, v1.z));            
    }
  }
}

void generateFlatRibbon(ArrayList vertices, ArrayList normals) {
  PVector CentPoint0, CentPoint1;
  PVector Sid1Point0, Sid1Point1;
  PVector Sid2Point0, Sid2Point1;
  PVector Transversal, Tangent;
  PVector Normal0, Normal1;
  int ui;
  float u;

  CentPoint0 = new PVector();
  CentPoint1 = new PVector();
  Sid1Point0 = new PVector();
  Sid1Point1 = new PVector();
  Sid2Point0 = new PVector();
  Sid2Point1 = new PVector();
  Transversal = new PVector();
  Tangent = new PVector();
  Normal0 = new PVector();
  Normal1 = new PVector();

  // The initial geometry is generated.
  splineSide1.feval(0, Sid1Point1);
  splineCenter.feval(0, CentPoint1);
  splineSide2.feval(0, Sid2Point1);

  // The tangents at the three previous points are the same.
  splineSide2.deval(0, Tangent);

  // Vector transversal to the ribbon.    
  Transversal = PVector.sub(Sid1Point1, Sid2Point1);

  //println("Transversal: " + Transversal);    
  //println("Tangent: " + Tangent);

  // The normal is calculated.
  Normal1 = Transversal.cross(Tangent);
  Normal1.normalize();
  //println("Normal1 0:" + Normal1);

  for (ui = 1; ui <= 10; ui ++) {
    if (ui % ribbonDetail == 0) {
      u = 0.1 * ui;

      // The geometry of the previous iteration is saved.
      Sid1Point0.set(Sid1Point1);
      CentPoint0.set(CentPoint1);
      Sid2Point0.set(Sid2Point1);
      Normal0.set(Normal1);

      // The new geometry is generated.
      splineSide1.feval(u, Sid1Point1);
      splineCenter.feval(u, CentPoint1);
      splineSide2.feval(u, Sid2Point1);

      // The tangents at the three previous points are the same.
      splineSide2.deval(u, Tangent);
      // Vector transversal to the ribbon.
      Transversal = PVector.sub(Sid1Point1, Sid2Point1);
      // The normal is calculated.
      Normal1 = Transversal.cross(Tangent);
      Normal1.normalize();

      // The (Sid1Point0, Sid1Point1, MiddPoint0, MiddPoint1) face is drawn.
      vertices.add(new PVector(Sid1Point0.x, Sid1Point0.y, Sid1Point0.z));
      normals.add(new PVector(Normal0.x, Normal0.y, Normal0.z));

      vertices.add(new PVector(Sid1Point1.x, Sid1Point1.y, Sid1Point1.z));
      normals.add(new PVector(Normal1.x, Normal1.y, Normal1.z));

      vertices.add(new PVector(CentPoint1.x, CentPoint1.y, CentPoint1.z));
      normals.add(new PVector(Normal1.x, Normal1.y, Normal1.z));

      vertices.add(new PVector(CentPoint0.x, CentPoint0.y, CentPoint0.z));
      normals.add(new PVector(Normal0.x, Normal0.y, Normal0.z));            

      // (MiddPoint0, MiddPoint1, Sid2Point0, Sid2Point1) plane is drawn.
      vertices.add(new PVector(Sid2Point0.x, Sid2Point0.y, Sid2Point0.z));
      normals.add(new PVector(Normal0.x, Normal0.y, Normal0.z));

      vertices.add(new PVector(Sid2Point1.x, Sid2Point1.y, Sid2Point1.z));
      normals.add(new PVector(Normal1.x, Normal1.y, Normal1.z));                        

      vertices.add(new PVector(CentPoint1.x, CentPoint1.y, CentPoint1.z));
      normals.add(new PVector(Normal1.x, Normal1.y, Normal1.z));            

      vertices.add(new PVector(CentPoint0.x, CentPoint0.y, CentPoint0.z));
      normals.add(new PVector(Normal0.x, Normal0.y, Normal0.z));            

      //println("Normal0: " + ui + " " + Normal0);
      //println("Normal1: " + ui + " " + Normal1);            
    }
  }
}


/******************************************************************************
 * The code in the following three functions was based in the theory presented in
 * the following article:
 * "Algorithm for ribbon models of proteins."
 * Authors: Mike Carson and Charles E. Bugg
 * University of Alabama at Birmingham, Comprehensive Cancer Center
 * 252 BHS, THT 79, University Station, Birmingham, AL 35294, USA
 * Published in: J.Mol.Graphics 4, pp. 121-122 (1986)
 ******************************************************************************/

// Shifts the control points one place to the left.
void shiftControlPoints() {
  splineSide1.shiftBSplineCPoints();
  splineCenter.shiftBSplineCPoints();
  splineSide2.shiftBSplineCPoints();
}

// Adds a new control point to the arrays CPCenter, CPRight and CPLeft
void addControlPoints(PVector ca0, PVector ox0, PVector ca1, int ss, int handness) {
  PVector A, B, C, D, p0, cpt0, cpt1, cpt2;

  A = PVector.sub(ca1, ca0);
  B = PVector.sub(ox0, ca0);

  // Vector normal to the peptide plane (pointing outside in the case of the
  // alpha helix).
  C = A.cross(B);

  // Vector contained in the peptide plane (perpendicular to its direction).
  D = C.cross(A);

  // Normalizing vectors.
  C.normalize();
  D.normalize();

  // Flipping test (to avoid self crossing in the strands).
  if ((ss != HELIX) && (90.0 < degrees(PVector.angleBetween(flipTestV, D)))) {
    // Flip detected. The plane vector is inverted.
    D.mult(-1.0);
  }

  // The central control point is constructed.
  cpt0 = linearComb(0.5, ca0, 0.5, ca1);
  splineCenter.setCPoint(3, cpt0);

  if (ss == HELIX) {
    // When residue i is contained in a helix, the control point is moved away
    // from the helix axis, along the C direction. 
    p0 = new PVector();
    splineCenter.getCPoint(3, p0);
    cpt0 = linearComb(1.0, p0, handness * helixWidth, C);
    splineCenter.setCPoint(3, cpt0);
  }

  // The control points for the side ribbons are constructed.
  cpt1 = linearComb(1.0, cpt0, +ribbonWidth[ss], D);
  splineSide1.setCPoint(3, cpt1);

  cpt2 = linearComb(1.0, cpt0, -ribbonWidth[ss], D);
  splineSide2.setCPoint(3, cpt2);

  // Saving the plane vector (for the flipping test in the next call).
  flipTestV.set(D);
}

void constructControlPoints(ArrayList residues, int res, int ss, int handness) {
  PVector ca0, ox0, ca1;
  PVector p0, p1, p2, p3;

  p1 = new PVector();        
  p2 = new PVector();
  p3 = new PVector();

  HashMap res0, res1;

  res0 = res1 = null;
  if (res == 0) {
    // The control points 2 and 3 are created.
    flipTestV.set(0, 0, 0);

    res0 = (HashMap)residues.get(res);
    res1 = (HashMap)residues.get(res + 1);
    ca0 = (PVector)res0.get("CA");
    ox0 = (PVector)res0.get("O");
    ca1 = (PVector)res1.get("CA");        
    addControlPoints(ca0, ox0, ca1, ss, handness);
    splineSide1.copyCPoints(3, 2);
    splineCenter.copyCPoints(3, 2);
    splineSide2.copyCPoints(3, 2);        

    res0 = (HashMap)residues.get(res + 1);
    res1 = (HashMap)residues.get(res + 2);
    ca0 = (PVector)res0.get("CA");
    ox0 = (PVector)res0.get("O");
    ca1 = (PVector)res1.get("CA"); 
    addControlPoints(ca0, ox0, ca1, ss, handness);

    // We still need the two first control points.
    // Moving backwards along the cp_center[2] - cp_center[3] direction.
    splineCenter.getCPoint(2, p2);
    splineCenter.getCPoint(3, p3);

    p1 = linearComb(2.0, p2, -1, p3);
    splineCenter.setCPoint(1, p1);        
    splineSide1.setCPoint(1, linearComb(1.0, p1, +ribbonWidth[ss], flipTestV)); 
    splineSide2.setCPoint(1, linearComb(1.0, p1, -ribbonWidth[ss], flipTestV));        

    p0 = linearComb(2.0, p1, -1, p2);
    splineCenter.setCPoint(0, p0);
    splineSide1.setCPoint(0, linearComb(1.0, p0, +ribbonWidth[ss], flipTestV));
    splineSide2.setCPoint(0, linearComb(1.0, p0, -ribbonWidth[ss], flipTestV));
  } else {
    shiftControlPoints();
    if ((residues.size() - 1 == res) || (residues.size() - 2 == res)) { 
      // Moving forward along the cp_center[1] - cp_center[2] direction.
      splineCenter.getCPoint(1, p1);             
      splineCenter.getCPoint(2, p2);

      p3 = linearComb(2.0, p2, -1, p1);
      splineCenter.setCPoint(3, p3);
      splineSide1.setCPoint(3, linearComb(1.0, p3, +ribbonWidth[ss], flipTestV));
      splineSide2.setCPoint(3, linearComb(1.0, p3, -ribbonWidth[ss], flipTestV));
    } else {
      res0 = (HashMap)residues.get(res + 1);
      res1 = (HashMap)residues.get(res + 2);
      ca0 = (PVector)res0.get("CA");
      ox0 = (PVector)res0.get("O");
      ca1 = (PVector)res1.get("CA");        
      addControlPoints(ca0, ox0, ca1, ss, handness);
    }
  }
  splineSide1.updateMatrix3();
  splineCenter.updateMatrix3();
  splineSide2.updateMatrix3();
}

PVector linearComb(float scalar0, PVector vector0, float scalar1, PVector vector1) {
  return PVector.add(PVector.mult(vector0, scalar0), PVector.mult(vector1, scalar1));
}
