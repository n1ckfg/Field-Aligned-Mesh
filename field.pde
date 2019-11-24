// Primitives for VECTOR FIELD tracing
// vector at P of field interpolating 3 arrows: (Pa,Va), (Pb,Vb), (Pc,Vc)
vec VecAt(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc)
{
    return computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
}

vec getVector(pt P, int t) {
    pt[] Ps = fillPoints(3*t);
    vec[] Vs = fillVectors(3*t);
    return VecAt(P, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2]);
}

int getStrokeWeight(vec v1, vec v2, vec v3, int type) {
    float s = dot(U(v1), U(v3));
    float e = dot(U(v2), U(v3));
    if (type == 0 && (s > 0.8 || e > 0.8)) {
        return 5;
    } 
    if (type == 1 && s > 0.9 && e > 0.9) {
        return 5;
    }
    return 2;
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

void showDenseMesh(pt start, pt end, pt mid, pt a, pt b, pt c) {
    strokeWeight(5);
    stroke(blue);
    edge(start, mid);
    edge(mid, end);
    strokeWeight(2);
    stroke(blue);
    edge(mid, a);
    edge(mid, b);
    edge(mid, c);
}

// returns 0 if trace lies inside triangle, 1 if exited via (B,C), 2 if exited via (C,A), 3 if exited via (A,B),
int[] drawCorrectedTraceInTriangleFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s, pt E, pt MT)
{
    ArrayList<pt> tracePoints = new ArrayList<pt>();
    pt P=P(Q);
    beginShape();
    v(P);
    tracePoints.add(P);
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
            if (E1 != null) {
                r = 1;
                E.x = E1.x; 
                E.y = E1.y;
            } else if (E2 != null) {
                r = 2;
                E.x = E2.x; 
                E.y = E2.y;
            } else if (E3 != null) {
                r = 3;
                E.x = E3.x; 
                E.y = E3.y;
            }
            Pn = E;
        }
        strokeWeight(2);
        stroke(brown);
        v(Pn);
        tracePoints.add(P);
        P=Pn;
        i++;
    }

    int[] ret = new int[2];
    ret[0] = r;
    ret[1] = i;

    endShape(POINTS);
    //println(r, "field");

    if (ret[1] > 1) {
        pt sp = tracePoints.get(0);
        pt ep = tracePoints.get(tracePoints.size()-1);
        pt mp = tracePoints.get(tracePoints.size()/2);

        MT.x = mp.x; 
        MT.y = mp.y;

        if (showDenseMeshUI) {
            showDenseMesh(sp, ep, mp, Pa, Pb, Pc);
        }
    }

    return ret;
}

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

pt[] TraceMeshStartingFrom(int corner) {
    boolean visitedT[] = new boolean[M.nt];
    boolean TrueT[] = new boolean[M.nt];
    pt traceMidPoints[] = new pt[M.nt];
    int iterations = 100;
    Arrays.fill(visitedT, false);
    Arrays.fill(TrueT, true);

    int[] e = {-1, -1};
    pt S = null, E = P(), MT = P();
    pt[] Ps = fillPoints(corner);
    vec[] Vs = fillVectors(corner);

    S = midOfNext(corner);
    for (int tr = 0; tr < M.nt; tr++) {
        MT = P();

        e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E, MT);
        if (e[1] > 1) {// we ran for more than iteration
            visitedT[M.t(corner)] = true;
        } else {
            corner = M.n(corner);
            S = midOfNext(corner);
            Ps = fillPoints(corner);
            Vs = fillVectors(corner);
            e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E, MT);
            if (e[1] > 1) {// we ran for more than iteration
                visitedT[M.t(corner)] = true;
            } else {

                corner = M.n(corner);
                S = midOfNext(corner);
                Ps = fillPoints(corner);
                Vs = fillVectors(corner);
                e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, 0.2, E, MT);

                if (e[1] < 2) {
                    MT = null;
                }
                visitedT[M.t(corner)] = true;
            }
        }

        traceMidPoints[M.t(corner)] = MT;

        int c = corner;
        if (e[0] == 1) {//b
            c = M.n(corner);
        } else if (e[0] == 2) {//c
            c = M.p(corner);
        }

        corner = M.u(c); //unswing into the next triangle
        if ((M.t(corner) == M.t(c)) ||
            (e[0] == 0) ||
            (visitedT[M.t(corner)])) { // check if outside
            for (int i = 0; i < M.nt; i++) {
                if (visitedT[i] == false) {
                    corner = 3 * i;
                    break;
                }
            }

            E = midOfNext(corner);
        }

        Ps = fillPoints(corner);
        Vs = fillVectors(corner);

        S = E;
    }

    return traceMidPoints;
}
