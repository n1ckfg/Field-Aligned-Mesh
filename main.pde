//  ******************* 2018 Project 3 basecde ***********************
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.util.Arrays;
import java.util.Random;

Boolean
    showFloor = true,
    showBalls = true,
    showPillars = false,
    animating = false,
    showEdges = true,
    showTriangles = true,
    showVoronoi = true,
    showArcs = true,
    showCorner = true,
    showVectors = true,
    showFAM = true,
    showTraces = false,
    showSTabs = true,
    paintStabbedFaces = true,
    subdivide = false,
    recomputeTrace = true,
    fatmComputed = false,
    live = true, // updates mesh at each frame

    step1 = false,
    step2 = false,
    step3 = false,
    step4 = false,
    step5 = false,
    step6 = false,
    step7 = false,
    step8 = false,
    step9 = false,
    step10 = false,

    PickedFocus = false,
    center = true,

    scribeText = false; // toggle for displaying of help text

float
    da = TWO_PI / 32, // facet count for fans, cones, caplets
    t = 0,
    s = 0,
    rb = 20, // radius of the balls 
    rt = rb / 2, // radius of tubes
    columnHeight = rb * 0.7,
    h_floor = 0, h_ceiling = 600, h = h_floor;

int
    mode = 3,
    f = 0,
    maxf = 2 * 30,
    level = 4,
    method = 5,
    PTris = 0,
    QTris = 0,
    subdivided = 0,
    tetCount = 0;

String SDA = "angle";

float defectAngle = 0;

pts P = new pts(); // polyloop in 3D
pts Q = new pts(); // second polyloop in 3D
pts R, S, T;
EdgeSet BP = new EdgeSet();
MESH M = new MESH();
tracer TRACER = new tracer();
subdivider SUBDIVIDER = new subdivider();
fieldMesh FMESH = new fieldMesh();
collapser COLLAPSER = new collapser();

void setup() {
    myFace = loadImage("data/pic.jpg"); // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
    textureMode(NORMAL);
    size(1000, 1000, P3D); // P3D means that we will do 3D graphics
    //size(600, 600, P3D); // P3D means that we will do 3D graphics
    P.declare();
    Q.declare(); // P is a polyloop in 3D: declared in pts
    //P.resetOnCircle(6,100); Q.copyFrom(P); // use this to get started if no model exists on file: move points, save to file, comment this line
    P.loadPts("data/pts");
    // Q.loadPts("data/pts2"); // loads saved models from file (comment out if they do not exist yet)
    P.loadVecs("data/fpts");
    noSmooth();
    //frameRate(30);
    sphereDetail(12);
    R = P;
    S = Q;
    println();
    println("_______ _______ _______ _______");
}

void draw() {
    background(255);
    hint(ENABLE_DEPTH_TEST);
    pushMatrix(); // to ensure that we can restore the standard view before writing on the canvas
    setView(); // see pick tab
    if (showFloor) showFloor(h); // draws dance floor as yellow mat
    doPick(); // sets Of and axes for 3D GUI (see pick Tab)
    R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)

    if (showBalls) {
        fill(red);
        R.drawBalls(rb);
        fill(black, 100);
        R.showPicked(rb + 5);
    }
    if (showPillars) {
        fill(green);
        R.drawColumns(rb, columnHeight);
        fill(black, 100);
        R.showPicked(rb + 5);
    }

    if (step1) {
        pushMatrix();
        translate(0, 0, 6);
        fill(cyan);
        stroke(yellow);
        if (live) {
            M.reset();
            M.loadVertices(R.G, R.nv);
            M.loadVectors(R.V, R.nv);
            M.triangulate();
        }
        if (subdivide) {
            SUBDIVIDER.subdivide(M);
            subdivide = false;
            live = false;
            subdivided ++;
        }
        if (showTriangles) M.showTriangles();
        noStroke();
        popMatrix();
    }

    if (step2) {
        fill(yellow);
        if (live) {
            M.computeO();
        }
        if (showEdges) {
            fill(grey);
            M.showSubdivisionEdges();
            fill(yellow);
            M.showNonBorderEdges();
            fill(red);
            M.showBorderEdges();
        }
        if (showVectors) {
            fill(blue);
            M.showFieldVectors();
        }
    }

    if (step3) {
        M.classifyVertices();
        showBalls = false;
        noStroke();
        M.showVertices(rb + 4);
    }

    if (step4) {
        for (int i = 0; i<10; i++) M.smoothenInterior();
        M.writeVerticesTo(R);
    }

    if (step5) {
        live = false;
        fill(magenta);
        if (showCorner) {
            M.showCurrentCorner(20);
        }
        if (recomputeTrace) {
            TRACER.getAllTraces();
            recomputeTrace = false;
        }
        if (showTraces) {
            TRACER.showAllTraces();
            if (showSTabs) {
                TRACER.showAllStabs();
            }
            if (showCorner) {
                TRACER.showStabsForCorner(M.c);
            }
            if (paintStabbedFaces) {
                TRACER.showStabbedTriangles();
            }
        }
        if (showFAM) {
            if (!fatmComputed) {
                FMESH.Compute();
                fatmComputed = true;
            }
            FMESH.Show();
        }
    }

    if (step6) {
        pushMatrix();
        translate(0, 0, 8);
        noFill();
        stroke(blue);
        if (showVoronoi) M.showVoronoi();
        stroke(blue);
        if (showVoronoi) M.showVoronoiEdges();
        stroke(red);
        if (showArcs) M.showArcs();
        noStroke();
        popMatrix();
    }

    if (step7) {
        CIRCLE C1 = Circ(R.G[0], rb), C2 = Circ(R.G[1], rb * 1.2), C3 = Circ(R.G[2], rb * 1.8);
        CIRCLE C = Apollonius(C1, C2, C3, -1, -1, -1);
        fill(red, 150);
        C1.showAsSphere();
        fill(green, 150);
        C2.showAsSphere();
        fill(blue, 150);
        C3.showAsSphere();
        fill(yellow, 200);
        C.showAsSphere();
    }
    if (step8) {
        fill(red);
        show(R.G[0], rb);
        fill(dgreen);
        show(R.G[1], rb);
        fill(blue);
        show(R.G[2], rb);
        if (ccw(R.G[0], R.G[1], R.G[2])) fill(yellow);
        else fill(magenta);
        show(R.G[0], R.G[1], R.G[2]);
    }

    if (step9) {
        fill(red);
        show(R.G[0], rb);
        fill(dgreen);
        show(R.G[1], rb);
        fill(blue);
        show(R.G[2], rb);
        pushMatrix();
        translate(0, 0, 3);
        stroke(magenta);
        strokeWeight(3);
        drawParabolaInHat(R.G[0], R.G[1], R.G[2], 5);
        popMatrix();
    }

    if (step10) {
        M.reset();
        M.loadVertices(R.G, R.nv);
        M.showVertices(40);
        M.triangulate();
        fill(yellow);
        M.showEdges();
        M.computeO();
        pushMatrix();
        translate(0, 0, 5);
        fill(cyan);
        M.showTriangles();
        translate(0, 0, 3);
        noFill();
        stroke(red);
        M.showArcs();
        noStroke();
        popMatrix();
    }

    popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
    hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible

    //*** TEAM: please fix these so that they provice the correct counts
    int line = 0;
    scribeHeader(" Project 3 for Rossignac's 2018 Graphics Course CS3451 / CS6491 by First LAST NAME ", line++);
    scribeHeader(P.count() + " vertices, " + M.nt + " triangles ", line++);
    if (live) scribeHeader("LIVE", line++);
    String ST = "";
    if (step1) ST = ST + "1";
    if (step2) ST = ST + "2";
    if (step3) ST = ST + "3";
    if (step4) ST = ST + "4";
    if (step5) ST = ST + "5";
    if (step6) ST = ST + "6";
    if (step7) ST = ST + "7";
    if (step8) ST = ST + "8";
    if (step9) ST = ST + "9";
    if (step10) ST = ST + "X";
    ST = ST + ".";
    scribeHeader(" STEPS: " + ST, line++);
    if (mode == 0) {
        scribeHeader("FAT MODE: Longer Edge", line++);
    } else if (mode == 1) {
        scribeHeader("FAT MODE: Shorter Edge", line++);
    } else if (mode == 2) {
        scribeHeader("FAT MODE: Trace ALigned Edge", line++);
    } else if (mode == 3) {
        scribeHeader("FAT MODE: Delaunay Edge", line++);
    }
    // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
    if (mousePressed) {
        stroke(cyan);
        strokeWeight(3);
        noFill();
        ellipse(mouseX, mouseY, 20, 20);
        strokeWeight(1);
    }
    if (keyPressed) {
        stroke(red);
        fill(white);
        ellipse(mouseX + 14, mouseY + 20, 26, 26);
        fill(red);
        text(key, mouseX - 5 + 14, mouseY + 4 + 20);
        strokeWeight(1);
    }
    if (scribeText) {
        fill(black);
        displayHeader();
    } // dispalys header on canvas, including my face
    if (scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
    if (filming && (animating || change)) {
        print(".");
        saveFrame("../MOVIE FRAMES (PLEASE DO NOT SUBMIT)/F" + nf(frameCounter++, 4) + ".tif");
        change = false;
    } // save next frame to make a movie
    if (filming && (animating || change)) {
        print(".");
        change = false;
    } // save next frame to make a movie
    //change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
    //change=true;
}