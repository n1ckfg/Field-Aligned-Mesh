//**************************** user actions ****************************
void keyPressed()  // executed each time a key is pressed: sets the Boolean "keyPressed" till it is released
    // sets  char "key" state variables till another key is pressed or released
{

    if (key=='~') recordingPDF=true; // to snap an image of the canvas and save as zoomable a PDF, compact and great quality, but does not always work
    if (key=='!') snapJPG=true; // make a .PDF picture of the canvas, compact, poor quality
    if (key=='@') snapTIF=true; // make a .TIF picture of the canvas, better quality, but large file
    if (key=='#') showTiles=!showTiles;
    if (key=='$') ;
    if (key=='%') ;
    if (key=='^') ;
    if (key=='&') ;
    if (key=='*') ;
    if (key=='(') ;
    if (key==')') showIsoCurves=!showIsoCurves;
    if (key=='_') ;
    if (key=='+') refineCounter++;

    if (key=='`') filming=!filming;  // filming on/off capture frames into folder IMAGES/MOVIE_FRAMES_TIF/
    if (key=='1') ;               // toggles what should be displayed at each fram
    if (key=='2') ;
    if (key=='3') ;
    if (key=='4') ;
    if (key=='5') ;
    if (key=='6') ;
    if (key=='7') ;
    if (key=='8') ;
    if (key=='9') ;
    if (key=='0') resetBranching=true;
    if (key=='-') refineCounter=max(0, refineCounter-1);
    if (key=='=') ;

    if (key=='a') ;// used to insert one more arrow //{animate=!animate; if(!animate) ft=f;}
    if (key=='b') ;
    if (key=='c') cubic=!cubic;
    if (key=='d') ;
    if (key=='e') showFine=!showFine;
    if (key=='f') showFirstField=!showFirstField;
    if (key=='g') showGrid=!showGrid;
    if (key=='h') completeVectorField=!completeVectorField;
    if (key=='i') ;
    if (key=='j') ;
    if (key=='k') ;
    if (key=='l') showLabels=!showLabels;
    if (key=='m') showTraceFromMouse = !showTraceFromMouse;
    if (key=='n') M.next();
    if (key=='o') M.opposite();
    if (key=='p') M.previous();
    if (key=='q') quintic=!quintic;
    if (key=='r') ; // used in mouseDrag to rotate the control points
    if (key=='s') M.swing();
    if (key=='t') ; // used in mouseDrag to translate the control points
    if (key=='p') ;
    if (key=='v') ;
    if (key=='w') ;
    if (key=='x') ; // drag frame count
    if (key=='y') ;
    if (key=='z') ; // used in mouseDrag to scale the control points

    if (key=='A') showArrow=!showArrow;
    if (key=='B') showBorder=!showBorder;
    if (key=='C') showCOTS=!showCOTS;
    if (key=='D') showDisks=!showDisks;
    if (key=='E') spiralAverage=!spiralAverage;
    if (key=='F') showFixedPoint=!showFixedPoint;
    if (key=='G') showDenseMeshUI=!showDenseMeshUI;
    if (key=='H') showHubs=!showHubs;
    if (key=='I') showArrows=!showArrows;
    if (key=='J') showCorners=!showCorners;
    if (key=='K') showKeyArrow=!showKeyArrow;
    if (key=='L') {
        P.loadPts("data/pts");
        newCOTS=true;
    } // load current positions of control points from file
    if (key=='M') showMesh=!showMesh;
    if (key=='N') showFAM=!showFAM;
    if (key=='O') showCircumCircle=!showCircumCircle;
    if (key=='P') showCircumCircles=!showCircumCircles;
    if (key=='Q') ;  // quit application
    if (key=='R') {
        P.resetOnCircle(P.nv);
        newCOTS=true;
    };
    ;
    if (key=='S') P.savePts("data/pts");    // save current positions of control points on file
    if (key=='T') showTextured=!showTextured;
    if (key=='U') ;
    if (key=='V') ;
    if (key=='W') ;
    if (key=='X') showStars=!showStars;
    if (key=='Y') ;
    if (key=='Z') ;

    if (key=='{') ;
    if (key=='}') ;
    if (key=='|') ;

    if (key=='[') showQuad=!showQuad;
    if (key==']') P.fitToCanvas();
    if (key=='\\') ;

    if (key==':') ;
    if (key=='"') ;

    if (key==';') ;
    if (key=='\'');

    if (key=='<') ne=max(2, ne-1);
    if (key=='>') ne++;
    if (key=='?') ; // toggle display of help text and authors picture

    if (key==',') df=max(0, df-1);
    if (key=='.') df++;
    if (key=='/') ;

    if (key==' ') scribeText=!scribeText;

    if (key == CODED)
    {
        String pressed = "Pressed coded key ";
        if (keyCode == UP) {
            pressed="UP";
        }
        if (keyCode == DOWN) {
            pressed="DOWN";
        };
        if (keyCode == LEFT) {
            pressed="LEFT";
        };
        if (keyCode == RIGHT) {
            pressed="RIGHT";
        };
        if (keyCode == ALT) {
            pressed="ALT";
        };
        if (keyCode == CONTROL) {
            pressed="CONTROL";
        };
        if (keyCode == SHIFT) {
            pressed="SHIFT";
        };
        println("Pressed coded key = "+pressed);
    }

    change=true; // to make sure that we save a movie frame each time something changes
    println("key pressed = "+key);
}

void mousePressed()   // executed when the mouse is pressed
{
    P.pickClosest(Mouse()); // pick vertex closest to mouse: sets pv ("picked vertex") in pts
    if (keyPressed)
    {
        if (key=='a')  P.addPt(Mouse()); // appends vertex after the last one
        if (key=='i')  P.insertClosestProjection(Mouse()); // inserts vertex at closest projection of mouse
        if (key=='d')  P.deletePickedPt(); // deletes vertex closeset to mouse
    }
    change=true;
}

void mouseDragged() // executed when the mouse is dragged (while mouse buttom pressed)
{
    if (!keyPressed || (key=='m')|| (key=='i')) P.dragPicked();   // drag selected point with mouse
    if (keyPressed) {
        if (key=='x') ft+=100.*float(mouseX-pmouseX)/width;  // adjust current frame
        if (key=='t') P.dragAll(); // move all vertices
        if (key=='r') P.rotateAllAroundCentroid(Mouse(), Pmouse()); // turn all vertices around their center of mass
        if (key=='z') P.scaleAllAroundCentroid(Mouse(), Pmouse()); // scale all vertices with respect to their center of mass
    }
    change=true;
}

void mouseWheel(MouseEvent event) { // reads mouse wheel and uses to zoom
    float s = event.getAmount();
    P.scaleAllAroundCentroid(s/100);
    change=true;
}

//**************************** text for name, title and help  ****************************
String title ="Field-Aligned Triangle-Mesh", name ="Harish Krupo KPS, Pranshu Gupta",
    subtitle = "",

    menu="?:(show/hide) help, ~/!/@:snap pdf/jpg/fif, `:(start/stop) recording, ^=mousePress",
    guide="^:pick&drag, d:delete, a+^+^:add, t:moveAll, m:traceFromMouse, f:filed, M:mesh, r:Turn, z:zoom, S/L:save/load"; // help info
