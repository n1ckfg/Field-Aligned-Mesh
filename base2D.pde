// CS6491 Fall 2019, Project 3
// Authors:
// Base-code: Jarek ROSSIGNAC
// Student: Pranshu Gupta
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.util.Arrays;
import java.util.Random;

//**************************** global variables ****************************
String pointsFile = "data/pts";
pts P = new pts(); // class containing array of points, used to manipulate arrows
float t=0.5;
boolean animate=false, fill=false, timing=false;
boolean showArrow=true, showKeyArrow=true; // toggles to display vector interpoations
int ms=0, me=0; // milli seconds start and end for timing
int npts=20000; // number of points
boolean spiralAverage=true, quintic=true, cubic=true;
ARROWRING Aring = new ARROWRING();
ARROWRING RefinedAring = new ARROWRING();
ARROWRING TempAring = new ARROWRING();
int refineCounter = 6;
int maxTraceCount = 1;
float step = 0.1;
int iterations = 5000;

int f=0, df=int(pow(2, refineCounter));
float ft=0;
PFont bigFont; // for showing large labels at corner
boolean
    showFine=false, 
    showTraceFromMouse=false, 
    showMesh=true, 
    completeVectorField=false, 
    showTriangles=true, 
    showArrows=true, 
    showDenseMeshUI=false, 
    showFAM=false, 
    showGrid=false, 
    showSubDivision=false,
    showCorners=true;

boolean shown = false;

pts GRID = new pts();

int exitThrough=0;
MESH M = new MESH();
int cc=0; // current corner (saved, since we rebuild M at each frame)


void fillGrid(pts ps) {
    ps.declare();
    int inc = (int) Math.floor((width * height) / (4.0 * ps.maxnv));
    for (int i = 0; i < width; i += inc) {
        for (int j = 0; j < height; j += inc) {
            ps.addPt(P(i, j));
        }
    }
}

void drawVectorField(pts grid) {
    for (int i = 0; i < grid.nv; i++) {

        pt Pa = null, Pb = null, Pc = null;
        vec Va = null, Vb = null, Vc = null;
        boolean found = false;

        pt P = grid.G[i];
        for (int t = 0; t < M.nc; t++) {
            // Get the three vertices for the triangle
            int cor = t;
            pt a = M.g(cor);
            pt b = M.g(M.n(cor));
            pt c = M.g(M.n(M.n(cor)));
            if (isInsideTriangle(P, a, b, c)) {
                Pa = a;
                Pb = b;
                Pc = c;
                Va = M.f(cor);
                Vb = M.f(M.n(cor));
                Vc = M.f(M.n(M.n(cor)));
                if (!M.exterior[M.t(cor)]) {
                    found = true;
                }
                break;
            }
        }

        if (found) {
            float[] nbc = calculateNBC(Pa, Pb, Pc, P);
            vec Pprime = nbcProduct(Va, Vb, Vc, nbc);
            Pprime = S(min(2, n(Pprime)), U(Pprime));
            noFill();
            strokeWeight(2);
            stroke(green);
            arrow(P, P(P, 10, Pprime));
        }
    }
}

void traceOverField(pts control, pt startPoint) {
    pt currentPoint = P(startPoint);
    pt A = control.G[0];
    pt B = control.G[2];
    pt C = control.G[4];
    vec Aprime = V(A, control.G[1]);
    vec Bprime = V(B, control.G[3]);
    vec Cprime = V(C, control.G[5]);
    for (int i = 0; i < 1000; i++) {
        float[] nbc = calculateNBC(A, B, C, currentPoint);
        vec Pprime = nbcProduct(Aprime, Bprime, Cprime, nbc);
        pt nextPoint = P(currentPoint, 0.01, Pprime);
        noFill();
        strokeWeight(2);
        stroke(green);
        edge(currentPoint, nextPoint);
        currentPoint = nextPoint;
    }
}

//**************************** initialization ****************************
void setup()               // executed once at the begining
{
    //size(1000, 1000, P2D);            // window size
    size(1200, 1200);            // window size
    frameRate(30);             // render 30 frames per second
    smooth();                  // turn on antialiasing
    P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS
    // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas
    P.loadPts(pointsFile);  // loads points form file saved with this program
    Aring.declare();
    RefinedAring.declare();
    TempAring.declare();
    myFace = loadImage("data/photo.jpg");
    textureMode(NORMAL);
    bigFont = createFont("AdobeFanHeitiStd-Bold-32", 20);
    textFont(bigFont);
    textAlign(CENTER, CENTER);
    fillGrid(GRID);
} // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
{
    shown = false;
    if (recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
    background(white); // clear screen and paints white background

    // ==================== MAKE ARROWS ====================
    Aring.empty();
    for (int i=0; i<P.nv; i+=2) {
        Aring.addArrow(P.G[i], V(P.G[i], P.G[i+1]));
    }

    // ==================== ANIMATION ====================
    int tm=120;
    if (animate) f=(f+1)%(tm);
    else f=(floor(ft)+tm)%(tm);
    float tt = float(f)/tm;
    t=(1.-cos(tt*TWO_PI))/2;

    // ==================== TRIANGLE MESH ====================
    if (showGrid) {
        drawVectorField(GRID);
    }
    if (showMesh)
    {
        cc=M.c;
        M.reset();
        M.loadFromPTS(P); // loads vertices and field vectors from the sequence P of po=oints
        M.triangulate();
        M.computeO();
        M.classifyVertices();
        noFill();
        pen(black, 2);
        M.showTriangles();
        stroke(red);
        M.showBorderEdges();
        M.c=cc;
        if (showCorners) {
            M.showCorners(3);
        }
        noFill();
        pen(black, 2);
        M.showCurrentCorner(7);
        pt Ps=M.firstBorderEdgeMidPoint();
        pen(green, 2);
        fill(green);
        show(Ps, 6);

        if (completeVectorField) {
            M.generateConstrainedVectors();
            M.completeVectorField(1000, 0.5);
        }
        if (showArrows) {
            pen(blue, 2);
            M.drawArrows();
        }

        if (showSubDivision) {
            showSubdivision();
        }
    }

    // ==================== TRACING FIELD ====================
    if (showTraceFromMouse) {

        pt Pm = Mouse();

        int corner = -1;
        for (int t = 0; t < M.nc; t++) {
            // Get the three vertices for the triangle
            pt a = M.g(t);
            pt b = M.g(M.n(t));
            pt c = M.g(M.n(M.n(t)));
            if (isInsideTriangle(Pm, a, b, c)) {
                corner = t;
                break;
            }
        }
        ArrayList<TracePoint> tracePoints[][] = null;
        if (corner != -1) {
            tracePoints = TraceMeshStartingFrom(corner);
            if (showLabels) showId(Pm, "M");
            noFill();
            if (showFAM) {
                ShowFieldAlignedMesh(tracePoints);
            }
        }
    }

    // ==================== SHOW POINTER AT MOUSE ====================
    pt End = P(Mouse(), 1, V(-2, 3)), Start = P(End, 20, V(-2, 3)); // show semi-opaque grey arrow pointing to mouse location (useful for demos and videos)
    strokeWeight(5);
    fill(grey, 70);
    stroke(grey, 70);
    arrow(Start, End);
    noFill();

    // used for demos to show red circle when mouse/key is pressed and what key.
    if (mousePressed) {
      stroke(cyan);
      strokeWeight(3);
      noFill();
      ellipse(mouseX, mouseY, 20, 20);
      strokeWeight(1);
    }

    if (keyPressed) {
      stroke(red);
      // fill(white);
      // ellipse(mouseX+14, mouseY+20, 25, 25);
      fill(red);
      text(key, mouseX-5+14, mouseY+4+20);
      strokeWeight(1);
    }


    if (recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

    fill(black);
    displayHeader(); // displays header
    if (scribeText && !filming) displayFooter(); // shows title, menu, and my face & name

    if (filming && (animate || change)) snapFrameToTIF(); // saves image on canvas as movie frame
    if (snapTIF) snapPictureToTIF();
    if (snapJPG) snapPictureToJPG();
    if (scribeText) {
        background(255, 255, 200);
        displayMenu();
    }
    change=false; // to avoid capturing movie frames when nothing happens
}  // end of draw
