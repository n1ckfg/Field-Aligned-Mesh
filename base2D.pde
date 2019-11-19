// CS6491 Fall 2019, Project 3
// Authors:
// Base-code: Jarek ROSSIGNAC
// Student 1: Harish Krupo KPS
// Student 2: Pranshu Gupta
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.util.Arrays;

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
boolean showFine=false, showTraceFromMouse=false, showMesh=true, showFirstField=false, showTriangles=true;
int exitThrough=0;
MESH M = new MESH();
int cc=0; // current corner (saved, since we rebuild M at each frame)


void fillGrid(pts ps) {
    ps.declare();
    int inc = width * height / ps.maxnv;
    for (int i = 0; i < width; i += inc) {
        for (int j = height * 1/5; j < height * 4 / 5; j += inc) {
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

void drawVectorField(pts control, pts grid) {
    for (int i = 0; i < grid.nv; i++) {
        pt A = control.G[0];
        pt B = control.G[2];
        pt C = control.G[4];
        pt P = grid.G[i];
        float[] nbc = calculateNBC(A, B, C, P);
        vec Aprime = V(A, control.G[1]);
        vec Bprime = V(B, control.G[3]);
        vec Cprime = V(C, control.G[5]);
        vec Pprime = nbcProduct(Aprime, Bprime, Cprime, nbc);
        Pprime = U(Pprime);
        noFill();
        strokeWeight(2);
        stroke(green);
        edge(P, P(P, 10, Pprime));
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
} // end of setup

pt[] fillPoints(int corner) {
    pt[] ret = new pt[3];
    ret[0] = M.g(corner);
    ret[1] = M.g(M.n(corner));
    ret[2] = M.g(M.p(corner));
    return ret;
}

vec[] fillVectors(int corner) {
    vec[] ret = new vec[3];
    ret[0] = M.f(corner);
    ret[1] = M.f(M.n(corner));
    ret[2] = M.f(M.p(corner));
    return ret;
}

pt midOfNext(int corner) {
    pt ret = P(M.g(corner), M.g(M.n(corner)));
    return ret;
}
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
        // pen(blue,2); M.drawArrows();
        M.triangulate();
        M.computeO();
        M.classifyVertices();
        noFill();
        pen(black, 2);
        M.showTriangles();
        stroke(red);
        M.showBorderEdges();
        M.c=cc;
        M.showCorners(3);
        noFill();
        pen(black, 2);
        M.showCurrentCorner(7);
        pt Ps=M.firstBorderEdgeMidPoint();
        pen(green, 2);
        fill(green);
        show(Ps, 6);
        int fbc = M.firstBorderCorner();
        pen(brown, 3);
        M.tracePathFromMidEdgeFacingCorner(fbc);
    }

    // ==================== TRACING FIELD ====================
    if (showTraceFromMouse)
    {
        int iterations = 100;
        pt Pm = Mouse();

        pt Pa = M.g(0);
        pt Pb = M.g(1);
        pt Pc = M.g(2);
        vec Va = M.f(0);
        vec Vb = M.f(1);
        vec Vc = M.f(2);

        int corner = -1;
        for (int t = 0; t < M.nc; t++) {
            // Get the three vertices for the triangle
            int cor = t;
            pt a = M.g(cor);
            pt b = M.g(M.n(cor));
            pt c = M.g(M.n(M.n(cor)));
            if (isInsideTriangle(Pm, a, b, c)) {
                Pa = a;
                Pb = b;
                Pc = c;
                corner = t;
                Va = M.f(cor);
                Vb = M.f(M.n(cor));
                Vc = M.f(M.n(M.n(cor)));
                break;
            }
        }

        println("=====================================");
        boolean visitedT[] = new boolean[M.nt];
        boolean TrueT[] = new boolean[M.nt];
        Arrays.fill(visitedT, false);
        Arrays.fill(TrueT, true);
        if (corner != -1) {
            int[] e = {-1, -1};
            pt S = null, E = P();
            pt[] Ps = fillPoints(corner);
            vec[] Vs = fillVectors(corner);
            

            S = midOfNext(corner);
            fill(green);
            show(S, 14);
            noFill();
            for (int tr = 0; tr < M.nt; tr++) {
                println("picked corner ", corner);

                e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E);

                if (e[1] > 1) {// we ran for more than iteration
                    visitedT[M.t(corner)] = true;
                } else {
                    corner = M.n(corner);
                    S = midOfNext(corner);
                    Ps = fillPoints(corner);
                    Vs = fillVectors(corner);
                    e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E);
                    if (e[1] > 1) {// we ran for more than iteration
                        visitedT[M.t(corner)] = true;
                    } else {

                        corner = M.n(corner);
                        S = midOfNext(corner);
                        Ps = fillPoints(corner);
                        Vs = fillVectors(corner);
                        e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E);

                        visitedT[M.t(corner)] = true;
                    }
                }


                int c = corner;
                if (e[0] == 1) {//b
                    c = M.n(corner);
                } else if (e[0] == 2) {//c
                    c = M.p(corner);
                }

                corner = M.u(c); //swing in to the next triangle
                //println("new corner ", corner);
                if ((M.t(corner) == M.t(c)) || 
                    (e[0] == 0) ||
                    (visitedT[M.t(corner)])) { // check if outside 
                    for (int i = 0; i < M.nt; i++) {
                        if (visitedT[i] == false) {
                            corner = 3 * i;
                            break;
                        }
                    }
                    
                    E = midOfNext(corner);;
                }

                Ps = fillPoints(corner);
                Vs = fillVectors(corner);

                S = E;
                if (e[0] != 0) {
                    fill(red);
                    show(E, 4);
                    noFill();
                }
            }

            if (showLabels) showId(Pm, "M");
            noFill();
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

    // ==================== DRAW ARROWS BETWEEN CONSECUTIVE POINTS OF P ====================
    fill(black);
    stroke(black);
    if (showKeyArrow) P.drawArrows(); // draws all control arrows

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
