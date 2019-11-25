// CS6491 Fall 2019, Project 3
// Authors:
// Base-code: Jarek ROSSIGNAC
// Student 1: Harish Krupo KPS
// Student 2: Pranshu Gupta
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.util.Arrays;
import java.util.Random;

//**************************** global variables ****************************
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
int f=0, df=int(pow(2, refineCounter));
float ft=0;
PFont bigFont; // for showing large labels at corner
boolean
    showFine=false, 
    showTraceFromMouse=false, 
    showMesh=true, 
    showFirstField=false, 
    completeVectorField=false, 
    showTriangles=true, 
    showArrows=true, 
    showDenseMeshUI=false, 
    showFAM=false, 
    showCorners=true;

pts GRID = new pts();

int exitThrough=0;
MESH M = new MESH();
int cc=0; // current corner (saved, since we rebuild M at each frame)


void fillGrid(pts ps) {
    ps.declare();
    int inc = (int) Math.floor((width * height) / (2.0 * ps.maxnv));
    println("inc is " + inc);
    for (int i = 0; i < width; i += inc) {
        for (int j = height * 1/10; j < height; j += inc) {
            ps.addPt(P(i, j));
        }
    }
}

float[] calculateNBC(pt A, pt B, pt C, pt P) {
    float[] ret = new float[3];
    vec AP = V(A, P);
    vec AB = V(A, B);
    vec AC = V(A, C);
    float denominator =  det(AB, AC);

    // ret 0: A, 1: B, 2: C
    ret[1] = det(AP, AC) / denominator;
    ret[2] = det(AB, AP) / denominator;
    ret[0] = 1 - (ret[1] + ret[2]);
    return ret;
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
                found = true;
                break;
            }
        }

        if (found) {
            float[] nbc = calculateNBC(Pa, Pb, Pc, P);
            vec Pprime = nbcProduct(Va, Vb, Vc, nbc);
            Pprime = U(Pprime);
            noFill();
            strokeWeight(2);
            stroke(green);
            edge(P, P(P, 10, Pprime));
        }
    }
}

vec nbcProduct(vec Aprime, vec Bprime, vec Cprime, float[] nbc) {
    return V(nbc[0] * Aprime.x + nbc[1] * Bprime.x + nbc[2] * Cprime.x, 
        nbc[0] * Aprime.y + nbc[1] * Bprime.y + nbc[2] * Cprime.y);
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
    size(800, 800, P2D);            // window size
    //size(1200, 1200);            // window size
    //frameRate(30);             // render 30 frames per second
    smooth();                  // turn on antialiasing
    P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS
    // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas
    P.loadPts("data/pts");  // loads points form file saved with this program
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
        //pen(green, 2);
        //fill(green);
        //show(Ps, 6);
        int fbc = M.firstBorderCorner();
        pen(brown, 3);
        M.tracePathFromMidEdgeFacingCorner(fbc);

        if (completeVectorField) {
            M.generateConstrainedVectors();
            M.completeVectorField(100, 0.3);
        }
        if (showArrows) {
            pen(blue, 2);
            M.drawArrows();
        }
    }

    drawVectorField(GRID);

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
        pt traceMidPoints[] = null;
        if (corner != -1) {
            traceMidPoints = TraceMeshStartingFrom(corner);

            if (showLabels) showId(Pm, "M");
            noFill();

            stroke(red);
            M.showBorderEdges();
            if (showFAM) {
                for (int t= 0; t < M.nt; t++) {
                    pt[] Ps = fillPoints(3*t);
                    vec[] Vs = fillVectors(3*t);
                    pt mid = traceMidPoints[t];
                    vec midvec = getVector(mid, t);
                    pt[] Ms = new pt[3];
                    vec[] Mv = new vec[3];
                    Ms[0] = traceMidPoints[M.t(M.s(3*t))];
                    Mv[0] = getVector(Ms[0], M.t(M.s(3*t)));
                    Ms[1] = traceMidPoints[M.t(M.s(M.n(3*t)))];
                    Mv[1] = getVector(Ms[1], M.t(M.s(M.n(3*t))));
                    Ms[2] = traceMidPoints[M.t(M.s(M.p(3*t)))];
                    Mv[2] = getVector(Ms[2], M.t(M.s(M.p(3*t))));

                    if (mid != null) {
                        if (Ms[0] != null) {
                            //print(midvec, Mv[0], V(mid, Ms[0]));
                            pen(blue, getStrokeWeight(midvec, Mv[0], V(mid, Ms[0]), 0));
                            edge(mid, Ms[0]);
                        }
                        if (Ms[1] != null) {
                            //print(midvec, Mv[1], V(mid, Ms[1]));
                            pen(blue, getStrokeWeight(midvec, Mv[1], V(mid, Ms[1]), 0));
                            edge(mid, Ms[1]);
                        }
                        if (Ms[2] != null) {
                            //print(midvec, Mv[2], V(mid, Ms[2]));
                            pen(blue, getStrokeWeight(midvec, Mv[2], V(mid, Ms[2]),0));
                            edge(mid, Ms[2]);
                        }
                        pen(blue, getStrokeWeight(midvec, Vs[0], V(mid, Ps[0]), 1));
                        edge(mid, Ps[0]);
                        pen(blue, getStrokeWeight(midvec, Vs[1], V(mid, Ps[1]), 1));
                        edge(mid, Ps[1]);
                        pen(blue, getStrokeWeight(midvec, Vs[2], V(mid, Ps[2]), 1));
                        edge(mid, Ps[2]);
                    }
                }
            }
        }
    }


    // ==================== TRACING FIELD OF FIRST TRIANGLE ====================
    if (showFirstField)
    {
        ARROW A0 = Aring.A[0], A1 = Aring.A[1], A2 = Aring.A[2]; //First 3 arrows used to test tracing
        pt Pa = A0.P;
        vec Va = A0.V;
        pt Pb = A1.P;
        vec Vb = A1.V;
        pt Pc = A2.P;
        vec Vc = A2.V;
        pen(grey, 4);
        fill(yellow, 100);
        show(Pa, Pb, Pc);
        noFill();

        pt Ps=P(Pa, Pb);
        show(Ps, 6); // mid-edge point where trace starts
        if (showFine) // FOR ACCURACY COMPARISONS
        {
            pen(cyan, 2);
            drawTraceFrom(Ps, Pa, Va, Pb, Vb, Pc, Vc, 500, 0.005);
            pen(green, 2);
            drawTraceFrom(Ps, Pa, Va, Pb, Vb, Pc, Vc, 50, 0.05);
        }

        pen(green, 6);
        fill(green);
        show(Ps, 4); // start of trace
        noFill();
        pen(orange, 1);
        drawCorrectedTraceFrom(Ps, Pa, Va, Pb, Vb, Pc, Vc, 100, 0.1);
        pen(brown, 3);
        noFill();
        pt E = P();
        // exitThrough = drawCorrectedTraceInTriangleFrom(Ps, Pa, Va, Pb, Vb, Pc, Vc, 100, 0.1, E);
        pen(red, 6);
        if (exitThrough!=0) {
            fill(red);
            show(E, 4);
            noFill();
        }
        if (exitThrough==1) edge(Pb, Pc);
        if (exitThrough==2) edge(Pc, Pa);
        if (exitThrough==4) edge(Pa, Pb);
        if (exitThrough==3) show(Pc, 20);
        if (exitThrough==6) show(Pa, 20);
        if (exitThrough==5) show(Pb, 20);

        if (showArrow)
        {
            fill(red);
            stroke(red);
            arrow(Pa, Va);
            fill(dgreen);
            stroke(dgreen);
            arrow(Pb, Vb) ;
            fill(blue);
            pen(blue, 1);
            arrow(Pc, Vc);
        }

        noStroke();
        fill(red);
        show(Pa, 6);
        fill(dgreen);
        show(Pb, 6);
        fill(blue);
        show(Pc, 6);

        if (showLabels)
        {
            textAlign(CENTER, CENTER);
            pen(red, 1);
            showId(Pa, "A");
            pen(dgreen, 1);
            showId(Pb, "B");
            pen(blue, 1);
            showId(Pc, "C");
        }

        textAlign(LEFT, TOP);
        fill(black);
        scribeHeader("exitThrough code = "+exitThrough, 1);
        textAlign(CENTER, CENTER);
    }

    // ==================== SHOW POINTER AT MOUSE ====================
    pt End = P(Mouse(), 1, V(-2, 3)), Start = P(End, 20, V(-2, 3)); // show semi-opaque grey arrow pointing to mouse location (useful for demos and videos)
    strokeWeight(5);
    fill(grey, 70);
    stroke(grey, 70);
    arrow(Start, End);
    noFill();


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
