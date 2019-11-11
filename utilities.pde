// LecturesInGraphics: utilities
// Author: Jarek ROSSIGNAC, last edited on August, 2016


PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder

// ************************************************************************ COLORS
//color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
//   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, grey=#5F5F5F;
//color dgreen=#166C03;
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, dgreen=#026F0A, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, orange=#FCA41F,
   brown=#AF6E0B, grey=#5F5F5F;


// ************************************************************************ GRAPHICS
void pen(color c, float w) {stroke(c); strokeWeight(w);}
void showDisk(float x, float y, float r) {ellipse(x,y,r*2,r*2);}

// ************************************************************************ SAVING INDIVIDUAL IMAGES OF CANVAS
int pictureCounter=0;

// these three save number image files with the canvas image at the end of draw

boolean recordingPDF=false; // most compact and great, but does not always work
void startRecordingPDF() {beginRecord(PDF,"IMAGES/PICTURES_PDF/P"+nf(pictureCounter++,3)+".pdf"); }
void endRecordingPDF() {endRecord(); recordingPDF=false;}

boolean snapJPG=false;
void snapPictureToJPG() {saveFrame("IMAGES/PICTURES_JPG/P"+nf(pictureCounter++,3)+".jpg"); snapJPG=false;}

boolean snapTIF=false;
void snapPictureToTIF() {saveFrame("IMAGES/PICTURES_TIF/P"+nf(pictureCounter++,3)+".tif"); snapTIF=false;}


//***************************************************************************************** MAKING A MOVIE
boolean filming=false;  // when true frames are captured in FRAMES for a movie
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture
int frameCounter=0;
void snapFrameToTIF()
  {
  //println("     snapFrameToTIF:     frameCounter="+frameCounter);
  saveFrame("IMAGES/MOVIE_FRAMES_TIF/F"+nf(frameCounter++,4)+".tif");
  }
/*
To make a movie :
reduce canvas size to produce smaller size movie file, for example size(400, 400) if more resolution is not needed
Press '~' to start filming,
act the movie or start an animation,
press '~' to pause/stop (you can restart to add frames)
Then, from within your Processing sketch,
from the processing menu, select Tools > Movie Maker.
Click on Choose… Navigate to your Sketch Folder.
Select, but do not open, the FRAMES folder.
Press Create Movie,
Select the parameters you want.

May not work for a large canvas!
MAKE SURE THAT YOU DELETE THE FRAMES_TIF folder in the IMAGES folder of your sketch!
*/

// ************************************************************************ TEXT
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) { text(S,10,i*20); noFill();} // writes black at line i
//void scribeHeaderRight(String S) {fill(0); text(S,width-7.5*S.length(),0); noFill();} // writes black on screen top, right-aligned
void scribeHeaderRight(String S) {fill(0); text(S,width-5,0); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void scribeMouseCoordinates() {fill(black); text("("+mouseX+","+mouseY+")",mouseX+7,mouseY+25); noFill();}
void displayHeader()  // Displays title and authors face on screen
    {
    textAlign(LEFT, TOP);
    scribeHeader(title,0);
    scribeHeader(subtitle,1);
    image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2);
    textAlign(RIGHT, TOP);
    scribeHeaderRight(name);
    textAlign(CENTER, CENTER);
    }
void displayFooter()  // Displays help text at the bottom
    {
    textAlign(LEFT, TOP);
    scribeFooter(guide,1);
    scribeFooter(menu,0);
    textAlign(CENTER, CENTER);
    }

void displayMenu()
  {
  textAlign(LEFT, TOP);
  float dx=10, dy=30;
  int k=1;
  scribe("Field-aligned triangle mesh",dx,dy*k++);
  scribe("Jarek Rossignac, Georgia Tech, 2019",dx,dy*k++);
  scribe(" ------------------------------",dx,dy*k++);
  scribe("MENU       Press SPACE to hide/show this menu",dx,dy*k++);
  scribe("Notation   *:mouseClick, _:mouseDrag",dx,dy*k++);
  scribe("ARROWS     m*_m*:append, d*:delete, K:showControl, A:showAll, S:save, L:load",dx,dy*k++);
  scribe("ANIMATION  a:start/stop, [:quad, ", dx,dy*k++);
  scribe("SUBDIVISION  q:quintic/linear, s:spiral/LERP", dx,dy*k++);
  scribe("TILES      #:checkerboard, >/<:more/fewer, ):isoCurves, B:border, O:oval", dx,dy*k++);
  scribe("PATTERN    T:texture, X:stars, D:dsks, H:hubs, o:circles", dx,dy*k++);
  scribe("IMAGES     ~/!/@:pdf/jpg/tif, `:(start/stop) filming",dx,dy*k++);
  scribe("", dx,dy*k++);
  textAlign(CENTER, CENTER);
  }
