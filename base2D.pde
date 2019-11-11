// Template for 2D projects
// Author: Jarek ROSSIGNAC
// CS6497: Computational Aesthetics, Fall 2019, Project 3
// Student: Jack Ross
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;

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
int f=0, df=int(pow(2,refineCounter));
float ft=0;
PFont bigFont; // for showing large labels at corner
boolean showFine=false, showTraceFromMouse=false, showMesh=true, showFirstField=false, showTriangles=true;
int exitThrough=0;
MESH M = new MESH();
int cc=0; // current corner (saved, since we rebuild M at each frame)

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
  //myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  myFace = loadImage("data/myface.jpg");
  textureMode(NORMAL);
  bigFont = createFont("AdobeFanHeitiStd-Bold-32", 20);
  textFont(bigFont);
  textAlign(CENTER, CENTER);
  } // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  background(white); // clear screen and paints white background

  // ==================== MAKE ARROWS ====================
  Aring.empty();
  for(int i=0; i<P.nv; i+=2) {Aring.addArrow(P.G[i],V(P.G[i],P.G[i+1]));}

  // ==================== ANIMATION ====================
  int tm=120;
  if(animate) f=(f+1)%(tm);
  else f=(floor(ft)+tm)%(tm);
  float tt = float(f)/tm;
  t=(1.-cos(tt*TWO_PI))/2;

  // ==================== TRIANGLE MESH ====================
  if(showMesh)
    {
    cc=M.c;
    M.reset();
    M.loadFromPTS(P); // loads vertices and field vectors from the sequence P of po=oints
   // pen(blue,2); M.drawArrows();
    M.triangulate();
    M.computeO();
    M.classifyVertices();
    noFill(); pen(black,2); M.showTriangles();
    stroke(red); M.showBorderEdges();
    M.c=cc;
    M.showCorners(3);
    noFill(); pen(black,2); M.showCurrentCorner(7);
    pt Ps=M.firstBorderEdgeMidPoint();  pen(green,2); fill(green); show(Ps,6);
    int fbc = M.firstBorderCorner();
    pen(brown,3); M.tracePathFromMidEdgeFacingCorner(fbc);
    }


  // ==================== TRACING FIELD OF FIRST TRIANGLE ====================
  if(showFirstField)
    {
    ARROW A0 = Aring.A[0], A1 = Aring.A[1], A2 = Aring.A[2]; //First 3 arrows used to test tracing
    pt Pa = A0.P; vec Va = A0.V;
    pt Pb = A1.P; vec Vb = A1.V;
    pt Pc = A2.P; vec Vc = A2.V;
    pen(grey,4); fill(yellow,100); show(Pa,Pb,Pc);
    noFill();

    pt Ps=P(Pa,Pb); show(Ps,6); // mid-edge point where trace starts
    if(showFine) // FOR ACCURACY COMPARISONS
      {
      pen(cyan,2); drawTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,500,0.005);
      pen(green,2); drawTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,50,0.05);
      }

    pen(green,6); fill(green); show(Ps,4); // start of trace
    noFill();
    pen(orange,1); drawCorrectedTraceFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,100,0.1);
    pt Q = P(); // exit point when exitThrough != 0
     pen(brown,3); noFill(); exitThrough = drawCorrectedTraceInTriangleFrom(Ps,Pa,Va,Pb,Vb,Pc,Vc,100,0.1,Q);
     pen(red,6);
     if(exitThrough!=0) {fill(red); show(Q,4); noFill();}
     if(exitThrough==1) edge(Pb,Pc);
     if(exitThrough==2) edge(Pc,Pa);
     if(exitThrough==4) edge(Pa,Pb);
     if(exitThrough==3) show(Pc,20);
     if(exitThrough==6) show(Pa,20);
     if(exitThrough==5) show(Pb,20);

    if(showTraceFromMouse)
       {
       pt Pm = Mouse();
       pen(black,1); drawCorrectedTraceFrom(Pm,Pa,Va,Pb,Vb,Pc,Vc,50,0.2);
       fill(brown); pen(brown,2);
       if(showArrow)
         {
         vec Vm = VecAt(Pm,Pa,Va,Pb,Vb,Pc,Vc); // velocity at current mouse position
         arrow(Pm,Vm);
         }
       pen(brown,1); show(Pm,6);
       if(showLabels) showId(Pm,"M");
       noFill();
       }

    if(showArrow)
      {
      fill(red); stroke(red); arrow(Pa,Va);
      fill(dgreen); stroke(dgreen); arrow(Pb,Vb) ;
      fill(blue); pen(blue,1); arrow(Pc,Vc);
      }

    noStroke();
    fill(red); show(Pa,6);
    fill(dgreen); show(Pb,6);
    fill(blue); show(Pc,6);

    if(showLabels)
      {
      textAlign(CENTER, CENTER);
      pen(red,1); showId(Pa,"A");
      pen(dgreen,1); showId(Pb,"B");
      pen(blue,1); showId(Pc,"C");
      }

    textAlign(LEFT, TOP); fill(black);
    scribeHeader("exitThrough code = "+exitThrough,1);
    textAlign(CENTER, CENTER);

    }

   // ==================== DRAW ARROWS BETWEEN CONSECUTIVE POINTS OF P ====================
  fill(black); stroke(black);
  if(showKeyArrow) P.drawArrows(); // draws all control arrows

  // ==================== SHOW POINTER AT MOUSE ====================
  pt End = P(Mouse(),1,V(-2,3)), Start = P(End,20,V(-2,3)); // show semi-opaque grey arrow pointing to mouse location (useful for demos and videos)
  strokeWeight(5);  fill(grey,70); stroke(grey,70); arrow(Start,End); noFill();


  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name

  if(filming && (animate || change)) snapFrameToTIF(); // saves image on canvas as movie frame
  if(snapTIF) snapPictureToTIF();
  if(snapJPG) snapPictureToJPG();
  if(scribeText) {background(255,255,200); displayMenu();}
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw

