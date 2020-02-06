// Primitives for VECTOR FIELD tracing
// vector at P of field interpolating 3 arrows: (Pa,Va), (Pb,Vb), (Pc,Vc)
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

vec nbcProduct(vec Aprime, vec Bprime, vec Cprime, float[] nbc) {
    return V(nbc[0] * Aprime.x + nbc[1] * Bprime.x + nbc[2] * Cprime.x, 
        nbc[0] * Aprime.y + nbc[1] * Bprime.y + nbc[2] * Cprime.y);
}

vec computeVectorField(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc) {
    float[] nbc = calculateNBC(Pa, Pb, Pc, P);
    return nbcProduct(Va, Vb, Vc, nbc);
}

vec getVector(pt P, int t) {
    pt[] Ps = fillPoints(3*t);
    vec[] Vs = fillVectors(3*t);
    return computeVectorField(P, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2]);
}

int getStrokeWeight(vec v1, vec v2, vec v3, int type) {
    float s = dot(U(v1), U(v3));
    float e = dot(U(v2), U(v3));
    if (type == 0 && (s > 0.8 || e > 0.8)) {
        return 5;
    } 
    return 2;
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

pt[] getSubDivision(int i) {
    pt[] subPoints = new pt[3];
    pt c1 = M.g(3*i);
    pt c2 = M.g(M.n(3*i));
    pt c3 = M.g(M.n(M.n(3*i)));
    subPoints[0] = P(c1, c2);
    subPoints[1] = P(c2, c3);
    subPoints[2] = P(c3, c1);
    return subPoints;
}

void showSubdivision() {
    for (int i = 0; i < M.nt; i++) {
        pt[] subPoints = getSubDivision(i);
        strokeWeight(2);
        stroke(blue);
        edge(subPoints[0], subPoints[1]);
        edge(subPoints[1], subPoints[2]);
        edge(subPoints[2], subPoints[0]);        
    }
}

int isInsideSubTriangle(int t, pt P) {
    pt[] subPoints = getSubDivision(t);
    pt A = M.g(3*t);
    pt B = M.g(M.n(3*t));
    pt C = M.g(M.n(M.n(3*t)));
    // println(A); println(B); println(C); 
    if (isInsideTriangle(P, A, B, C)) {
        if (isInsideTriangle(P, subPoints[0], subPoints[1], subPoints[2])) {
            return 0;
        } else if (isInsideTriangle(P, A, subPoints[0], subPoints[2])) {
            return 1;
        } else if (isInsideTriangle(P, B, subPoints[1], subPoints[0])) {
            return 2;
        } else if (isInsideTriangle(P, C, subPoints[2], subPoints[1])) {
            return 3;
        }
    }
    return -1;
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

pt getStartingPoint(int corner, int face) {
    pt ret = P();
    if (face == 0) {
        ret = P(M.g(corner), M.g(M.n(corner)), M.g(M.n(M.n(corner))));
    } else {
        pt[] subPoints = getSubDivision(M.t(corner));
        if (face == 1) {
            ret = P(M.g(corner), subPoints[0], subPoints[2]);
        } else if (face == 2) {
            ret = P(M.g(M.n(corner)), subPoints[1], subPoints[0]);
        } else if (face == 3) {
            ret = P(M.g(M.n(M.n(corner))), subPoints[2], subPoints[1]);
        }
    }
    return ret;
}

// returns 0 if trace lies inside triangle, 1 if exited via (B,C), 2 if exited via (C,A), 3 if exited via (A,B),
int[] drawCorrectedTraceInTriangleFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, int k, float s, pt E, pt MT, color c, boolean[][] visitedT, int t) {
    // Initialie the points array for the trace
    ArrayList<pt> tracePoints = new ArrayList<pt>();

    // Begin the shape marker for tracing
    pt P = P(Q); 
    beginShape();
    v(P);
    tracePoints.add(P);

    int i = 0;
    boolean inTriangle = true; // flag that the trace point is inside the triangle
    int r = 0;
    while (i < k && inTriangle)
    {
        vec V = computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
        pt Pn = P(P, s, V);
        inTriangle = isOnTriangleFace(Pn, Pa, Pb, Pc);
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
        } else {
            int subtIndex1 = isInsideSubTriangle(t, P);
            visitedT[t][subtIndex1] = true;
            int subtIndex2 = isInsideSubTriangle(t, Pn);
            if ((subtIndex2 != subtIndex1) && visitedT[t][subtIndex2]) {
                inTriangle = false;
                // get the intersection of the line segment made by the previous point
                pt[] subPoints = getSubDivision(t);
                pt sa, sb, sc;
                if (subtIndex2 == 0) {
                    sa = subPoints[0];
                    sb = subPoints[1];
                    sc = subPoints[2];
                } else if (subtIndex2 == 1) {
                    sa = Pa;
                    sb = subPoints[0];
                    sc = subPoints[2];
                } else if (subtIndex2 == 2) {
                    sa = subPoints[1];
                    sb = Pb;
                    sc = subPoints[0];
                } else {
                    sa = subPoints[1];
                    sb = subPoints[2];
                    sc = Pc;
                }
                pt E1 = getIntersection(P, Pn, sb, sc);
                pt E2 = getIntersection(P, Pn, sc, sa);
                pt E3 = getIntersection(P, Pn, sa, sb);
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
        }
        strokeWeight(2);
        stroke(c);
        v(Pn);
        tracePoints.add(Pn);
        P = Pn;
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

int TraceInDirection(int cor, int face, pt[] traceMidPoints, boolean[][] visitedT, boolean positive, int traceCount) {
    // Initialize exit and step counts
    int[] e = {-1, -1};

    // Initialize End point, mid point and start of the trace
    pt E = P(), MT = P();
    pt S = getStartingPoint(cor, face);

    // Mark the start of the trace
    label(S, str(traceCount));
    ellipse(S.x, S.y, 20, 20);
    strokeWeight(1);


    int corner = cor;
    int orig_corner = cor;
    pt[] Ps = fillPoints(corner);
    vec[] Vs = fillVectors(corner);
    float step = 0.1;
    int iterations = 5000;
    if (!positive)
        step = -step;

    color col = #4dac26;
    if (!positive)
        col = #d01c8b;

    while(true) {
        MT = P();

        // trace in this triangle
        e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, step, E, MT, col, visitedT, M.t(corner));

        // storing the midpoint of the trace for this triangle
        if (e[1] > 1 && !MT.equals(P())) {
            traceMidPoints[M.t(corner)] = P(MT);
        } else {
            traceMidPoints[M.t(corner)] = P(S);
        }
        if (corner == orig_corner) {
            traceMidPoints[M.t(corner)] = P(S);
        }

        // get to the exit corner
        int c = corner;
        if (e[0] == 1) {//b
            c = M.n(corner);
        } else if (e[0] == 2) {//c
            c = M.p(corner);
        }

        corner = M.u(c); //unswing into the next triangle

        int subtIndex = isInsideSubTriangle(M.t(corner), E);
        // pt xa = M.g(corner);
        // pt xb = M.g(M.n(corner));
        // pt xc = M.g(M.n(M.n(corner)));
        // println("distance:", d(xa, E) + d(E, xc), d(xa, xc));
        // println(turnAngle(xa, xb, E), turnAngle(xb, xc, E), turnAngle(xc, xa, E));
        // println(E);
        show(E, 5);

        if (M.t(corner) == M.t(c)) { 
            // the triangle lies on the boundary
            // println(traceCount, "the triangle lies on the boundary");
            return orig_corner;
        }
        if (e[0] == 0) {
            // looping inside the triangle
            // println(traceCount, "looping inside the triangle");
            return orig_corner;
        } 
        if (M.exterior[M.t(corner)]) {
            // this triangle is marked as exterior
            // println(traceCount, "this triangle is marked as exterior");
            return orig_corner;
        }
        if (subtIndex < 0 || visitedT[M.t(corner)][subtIndex]) {
            // Check if we have already been in this triangle
            // println(subtIndex, corner, "we have already been in this triangle");
            return orig_corner;
        }

        
        // println(corner, E);

        // initiate the next traingle start point and vectors
        Ps = fillPoints(corner);
        Vs = fillVectors(corner);
        S = E;
    }
}

pt[] TraceMeshStartingFrom(int corner) {
    int face = 0;
    // Initialize all triangles and their subdivisions as unvisited
    boolean visitedT[][] = new boolean[M.nt][4];
    for (int i = 0; i < M.nt; i++) {
        Arrays.fill(visitedT[i], false);
    }

    // Create an array to store the trace midpoints
    pt traceMidPoints[] = new pt[M.nt];
    
    // If this triangle is marked as exterior, return
    if (M.exterior[M.t(corner)]) {
        return traceMidPoints;
    }

    // Begin tracing
    int traceCount = 0;
    while(true) {
        traceCount += 1;
    
        TraceInDirection(corner, face, traceMidPoints, visitedT, true, traceCount); // Forward pass
        TraceInDirection(corner, face, traceMidPoints, visitedT, false, traceCount); // Backward pass

        // find the next unvisited triangle
        boolean found = false;
        for (int i = 0; i < M.nt; i++) {
            if (M.exterior[i] == false) {
                if (visitedT[i][0] == false) {
                    corner = 3 * i;
                    face = 0;
                    found = true;
                    break;
                } else if (visitedT[i][1] == false) {
                    corner = 3 * i;
                    face = 1;
                    found = true;
                    break;
                } else if (visitedT[i][2] == false) {
                    corner = 3 * i;
                    found = true;
                    face = 2;
                    break;
                } else if (visitedT[i][3] == false) {
                    corner = 3 * i;
                    face = 3;
                    found = true;
                    break;
                }
            }
        }

        if (!found) {
            break;
        }   
    }

    return traceMidPoints;
}
