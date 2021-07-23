class TracePoint {
    public pt point;
    public int traceId;

    TracePoint(pt point, int traceId) {
        this.point = point;
        this.traceId = traceId;
    }
}

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

pt[] getSubDivisionK(int i, int k) {
    pt[] subPoints = new pt[3];
    pt c1 = M.g(3*i);
    pt c2 = M.g(M.n(3*i));
    pt c3 = M.g(M.n(M.n(3*i)));
    if (k == 1) {
        subPoints[0] = P(c1, c2);
        subPoints[1] = P(c1);
        subPoints[2] = P(c3, c1); 
    } else if (k == 2) {
        subPoints[0] = P(c1, c2);
        subPoints[1] = P(c2, c3);
        subPoints[2] = P(c2); 
    } else if (k == 3){
        subPoints[0] = P(c3);
        subPoints[1] = P(c2, c3);
        subPoints[2] = P(c3, c1); 
    } else {
        subPoints[0] = P(c1, c2);
        subPoints[1] = P(c2, c3);
        subPoints[2] = P(c3, c1); 
    }
    return subPoints;  
}

void selectSubTriangle () {
    pt Pm = Mouse();
    for (int t = 0; t < M.nc; t++) {
        int x = isInsideSubTriangle(t, Pm);
        if (x != -1) {
            ct = t;
            cs = x;
            break;
        }
    }
}

void showSubdivision() {
    for (int i = 0; i < M.nt; i++) {
        pt[] subPoints = getSubDivision(i);
        strokeWeight(2);
        stroke(#0571b0);
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
int[] drawCorrectedTraceInTriangleFrom(pt Q, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc, pt E, color c, boolean[][] visitedT, int t, int traceId, ArrayList<TracePoint>[][] tracePoints, boolean first) {
    
    ArrayList<pt> points = new ArrayList<pt>();
    ArrayList<Integer> subtriangles = new ArrayList<Integer>();

    // Begin the shape marker for tracing
    pt P = P(Q);

    int subtIndex = isInsideSubTriangle(t, P);
    if (!first) {
        tracePoints[t][subtIndex].add(new TracePoint(P, traceId));
    }

    points.add(P(P));

    int i = 0;
    boolean inTriangle = true; // flag that the trace point is inside the triangle
    int r = 0;
    while (i < iterations && inTriangle)
    {
        int subtIndex1 = isInsideSubTriangle(t, P);

        vec V = computeVectorField(P, Pa, Va, Pb, Vb, Pc, Vc);
        pt Pn = P(P, step, V);
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
            tracePoints[t][subtIndex1].add(new TracePoint(P(E), traceId));
            Pn = E;
        } else {
            int subtIndex2 = isInsideSubTriangle(t, Pn);
            
            visitedT[t][subtIndex1] = true;
            subtriangles.add(subtIndex1);

            if (subtIndex2 != subtIndex1) {
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
                // get the intersection of the line segment made by the previous point
                pt E1 = getIntersection(P, Pn, sb, sc);
                pt E2 = getIntersection(P, Pn, sc, sa);
                pt E3 = getIntersection(P, Pn, sa, sb);
                if (E1 != null) {
                    // show(E1, 5);
                    tracePoints[t][subtIndex1].add(new TracePoint(P(E1), traceId));
                    tracePoints[t][subtIndex2].add(new TracePoint(P(E1), traceId));
                } else if (E2 != null) {
                    // show(E2, 5);
                    tracePoints[t][subtIndex1].add(new TracePoint(P(E2), traceId));
                    tracePoints[t][subtIndex2].add(new TracePoint(P(E2), traceId));
                } else if (E3 != null) {
                    // show(E3, 5);
                    tracePoints[t][subtIndex1].add(new TracePoint(P(E3), traceId));
                    tracePoints[t][subtIndex2].add(new TracePoint(P(E3), traceId));
                }
                if (visitedT[t][subtIndex2]) {
                    inTriangle = false;
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
        }
        points.add(P(Pn));
        P = Pn;
        i++;
    }

    int[] ret = new int[2];
    ret[0] = r;
    ret[1] = i;

    // fill the triangles
    for (int q = 0; q < subtriangles.size(); q++) {
        // display the subtriangle in yellow
        pt[] verts = getSubDivisionK(t, subtriangles.get(q));
        fill(yellow);
        noStroke();
        beginShape(TRIANGLES);
        for (int s = 0; s < 3; s++) {
            vertex(verts[s].x, verts[s].y);
        }
        endShape();
        noFill();    
    }

    // draw the trace 
    beginShape();
    strokeWeight(2);
    stroke(c);
    for (int q = 0; q < points.size(); q++) {
        v(points.get(q));
    }
    endShape();

    return ret;
}

int TraceInDirection(int cor, int face, ArrayList<TracePoint>[][] tracePoints, boolean[][] visitedT, boolean positive, int traceCount) {
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

    color col = #4dac26;
    if (!positive) {
        step = -abs(step);
        col = #d01c8b;
    } else {
        step = abs(step);
        col = #4dac26; 
    }

    boolean first = true;
    while(true) {

        // trace in this triangle
        e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], E, col, visitedT, M.t(corner), traceCount, tracePoints, first);
        first = false;

        // get to the exit corner
        int c = corner;
        if (e[0] == 1) {//b
            c = M.n(corner);
        } else if (e[0] == 2) {//c
            c = M.p(corner);
        }

        corner = M.u(c); //unswing into the next triangle

        // show(E, 5);

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
        int subtIndex = isInsideSubTriangle(M.t(corner), E);
        if (subtIndex < 0 || visitedT[M.t(corner)][subtIndex]) {
            // Check if we have already been in this triangle
            // println(subtIndex, corner, "we have already been in this triangle");
            return orig_corner;
        }

        // initiate the next traingle start point and vectors
        Ps = fillPoints(corner);
        Vs = fillVectors(corner);
        S = E;
    }
}

ArrayList<TracePoint>[][] TraceMeshStartingFrom(int corner) {
    int face = 0;
    // Initialize all triangles and their subdivisions as unvisited
    boolean visitedT[][] = new boolean[M.nt][4];
    for (int i = 0; i < M.nt; i++) {
        Arrays.fill(visitedT[i], false);
    }

    // ArrayList of points to store the tracepoints for each subtriangle
    ArrayList<TracePoint> tracePoints[][] = (ArrayList<TracePoint>[][])new ArrayList[M.nt][4];
    for (int i = 0; i < M.nt; i++) {
        for (int j = 0; j < 4; j++) {
            tracePoints[i][j] = new ArrayList<TracePoint>();
        }
    }
    
    // If this triangle is marked as exterior, return
    if (M.exterior[M.t(corner)]) {
        return tracePoints;
    }

    // Begin tracing
    int traceCount = 0;
    while(traceCount < maxTraceCount) {
        traceCount += 1;
    
        TraceInDirection(corner, face, tracePoints, visitedT, true, traceCount); // Forward pass
        TraceInDirection(corner, face, tracePoints, visitedT, false, traceCount); // Backward pass

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

    return tracePoints;
}

void ShowFieldAlignedMesh (ArrayList<TracePoint>[][] tracePoints) {
    for (int i = 0; i < M.nt; i++) {
        for (int j = 0; j < 4; j++) {
            pt[] vertices = getSubDivisionK(i, j);
            drawMeshInSubdivision(tracePoints[i][j], vertices, i, j);
        }
    }
}


void drawMeshInSubdivision(ArrayList<TracePoint> tracePoints, pt[] vertices, int t, int s) {
    for (int k = 0; k < tracePoints.size(); k++) {
        for (int l = k+1; l < tracePoints.size(); l++) {
            if (tracePoints.get(k).traceId == tracePoints.get(l).traceId) {
                strokeWeight(5);
                stroke(blue);
                edge(tracePoints.get(k).point, tracePoints.get(l).point);

                // we have a trace edge here 
                ArrayList<pt> left = new ArrayList<pt>();
                ArrayList<Float> leftAngles = new ArrayList<Float>();
                ArrayList<pt> right = new ArrayList<pt>();
                ArrayList<Float> rightAngles = new ArrayList<Float>();

                for (int i = 0; i < vertices.length; i++) {
                    float vAngle = turnAngle(tracePoints.get(k).point, tracePoints.get(l).point, vertices[i]);
                    if (vAngle > 0) {
                        right.add(vertices[i]);
                        rightAngles.add(vAngle);
                        if (t == ct && s == cs) {
                            fill(magenta);
                            show(vertices[i], 10);
                            noFill();                           
                        }
                    } else {
                        left.add(vertices[i]);
                        leftAngles.add(vAngle);
                        if (t == ct && s == cs) {
                            fill(black);
                            show(vertices[i], 10);
                            noFill();                     
                        }
                    }
                }
                if (t == ct && s == cs) {
                    stroke(red);
                    show(tracePoints.get(k).point, 5);
                    noFill();
                    stroke(green);
                    show(tracePoints.get(l).point, 5);
                    noFill();
                    println();
                }
                if (left.size() == 2) {
                    int zero = 0, one = 1;
                    if (abs(turnAngle(left.get(0), tracePoints.get(k).point, right.get(0))) < 1e-6) {
                        zero = 1;
                        one = 0;
                    }
                    // if (t == ct && s == cs) {
                    //     println("zero", turnAngle(left.get(0), tracePoints.get(k).point, right.get(0)));
                    //     println("one", turnAngle(left.get(1), tracePoints.get(k).point, right.get(0)));
                    // }
                    if (leftAngles.get(zero) > leftAngles.get(one)) {
                        strokeWeight(2);
                        stroke(blue);
                        edge(tracePoints.get(l).point, left.get(one));                        
                    } else {
                        strokeWeight(2);
                        stroke(blue);
                        edge(tracePoints.get(k).point, left.get(zero)); 
                    }
                } else if (right.size() == 2) {
                    int zero = 0, one = 1;
                    if (abs(turnAngle(right.get(0), tracePoints.get(k).point, left.get(0))) < 1e-6) {
                        zero = 1;
                        one = 0;
                    }
                    // if (t == ct && s == cs) {
                    //     println("zero", turnAngle(right.get(0), tracePoints.get(k).point, left.get(0)));
                    //     println("one", turnAngle(right.get(1), tracePoints.get(k).point, left.get(0)));
                    // }
                    if (rightAngles.get(zero) > rightAngles.get(one)) {
                        strokeWeight(2);
                        stroke(blue);
                        edge(tracePoints.get(l).point, right.get(one));                        
                    } else {
                        strokeWeight(2);
                        stroke(blue);
                        edge(tracePoints.get(k).point, right.get(zero)); 
                    }
                }
            }
        }
        stroke(red);
        fill(red);
        show(tracePoints.get(k).point, 2);
        noFill();
    }
}