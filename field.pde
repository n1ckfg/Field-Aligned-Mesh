// Primitives for VECTOR FIELD tracing
// vector at P of field interpolating 3 arrows: (Pa,Va), (Pb,Vb), (Pc,Vc)
vec VecAt(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc)
{
    return computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
    // STUDENT:CHANGE THIS CODE
}

// draw trace in field from Q, using k points with parameter spacing s
void drawTraceFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s)
{
    pt P=P(Q);
    beginShape();
    v(P);
    for (int i=0; i<k; i++)
    {
        vec V = V(50, 20);
        P=P(P, s, V);
        // STUDENT:CHANGE THIS CODE
        v(P);
    }
    endShape(POINTS);
}

vec computeVectorField(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc) {
    float[] nbc = calculateNBC(Pa, Pb, Pc, P);
    return nbcProduct(Va, Vb, Vc, nbc);
}

void drawCorrectedTraceFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s)
{
    pt P=P(Q);
    beginShape();
    v(P);
    for (int i=0; i<k; i++)
    {
        vec V = computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
        pt Pf=P(P, s, V);
        strokeWeight(2); 
        stroke(red);
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
    while (i<k && inTriangle)
    {
        // STUDENT:CHANGE THIS CODE
        vec V = computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
        pt Pn=P(P, s, V);
        inTriangle = isInsideTriangle(Pn, Pa, Pb, Pc);
        if (!inTriangle) {
            // get the intersection of the line segment made by the previous point 
            pt E1 = getIntersection(P, Pn, Pb, Pc);
            pt E2 = getIntersection(P, Pn, Pc, Pa);
            pt E3 = getIntersection(P, Pn, Pa, Pb);
            if (E1 != null && E2 == null && E3 == null) {
                r = 1;
                E = E1;
            } else if (E2 != null && E3 == null && E1 == null) {
                r = 2;
                E = E2;
            } else if (E3 != null && E1 == null && E2 == null) {
                r = 3;
                E = E3;
            }
            if (E != null) {
                v(E);
            }
            break;
        }
        v(Pn);
        P=Pn;
        i++;
    }
    endShape(POINTS);
    return r;
}
