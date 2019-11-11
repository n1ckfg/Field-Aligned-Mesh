// Primitives for VECTOR FIELD tracing
// vector at P of field interpolating 3 arrows: (Pa,Va), (Pb,Vb), (Pc,Vc)
vec VecAt(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc)
  {
  return Va;
      // STUDENT:CHANGE THIS CODE
  }

// draw trace in field from Q, using k points with parameter spacing s
void drawTraceFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s)
    {
    pt P=P(Q);
    beginShape();
    v(P);
    for(int i=0; i<k; i++)
      {
      vec V = V(50,20);
      P=P(P,s,V);
      // STUDENT:CHANGE THIS CODE
      v(P);
      }
    endShape(POINTS);
    }

void drawCorrectedTraceFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s)
    {
    pt P=P(Q);
    beginShape();
    v(P);
    for(int i=0; i<k; i++)
      {
      vec V = V(50,20);
      pt Pf=P(P,s,V);
      // STUDENT:CHANGE THIS CODE
      P=Pf;
      v(P);
      }
    endShape(POINTS);
    }

// returns 0 if trace lies inside triangle, 1 if exited via (B,C), 2 if exited via (C,A), 3 if exited via (A,B),
int drawCorrectedTraceInTriangleFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s, pt E)
    {
    pt P=P(Q);
    beginShape();
    v(P);
    int i=0;
    boolean inTriangle=true;
    int r=0;
    while(i<k && inTriangle)
      {
      // STUDENT:CHANGE THIS CODE
      vec V = V(20,5);
      pt Pn=P(P,s,V);
      v(Pn);
      P=Pn;
      i++;
      }
    endShape(POINTS);
    return r;
    }
