// Primitives for VECTOR FIELD tracing
// vector at P of field interpolating 3 arrows: (Pa,Va), (Pb,Vb), (Pc,Vc)
vec VecAt(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc) {
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
    return 2;
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

vec nbcProduct(vec Aprime, vec Bprime, vec Cprime, float[] nbc) {
    return V(nbc[0] * Aprime.x + nbc[1] * Bprime.x + nbc[2] * Cprime.x, 
        nbc[0] * Aprime.y + nbc[1] * Bprime.y + nbc[2] * Cprime.y);
}

vec computeVectorField(pt P, pt Pa, vec Va, pt Pb, vec Vb, pt Pc, vec Vc) {
    float[] nbc = calculateNBC(Pa, Pb, Pc, P);
    return nbcProduct(Va, Vb, Vc, nbc);
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
int[] drawCorrectedTraceInTriangleFrom(pt Q, pt Pa, vec Va,
                                       pt Pb, vec Vb, pt Pc, vec Vc,
                                       int k, float s, pt E, pt MT, color c)
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
        stroke(c);
        v(Pn);
        tracePoints.add(Pn);
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
    pt ret = P(M.g(corner), M.g(M.n(corner)), M.g(M.n(M.n(corner))));
    return ret;
}

int TraceInDirection(int cor, pt[] traceMidPoints, boolean[] visitedT, boolean positive, int traceCount) {
    int[] e = {-1, -1};
    pt E = P(), MT = P();
    pt S = midOfNext(cor);

    label(S, str(traceCount));
    ellipse(S.x, S.y, 20, 20);
    strokeWeight(1);

    int corner = cor;
    int orig_corner = cor;
    pt[] Ps = fillPoints(corner);
    vec[] Vs = fillVectors(corner);
    float step = 0.2;
    int iterations = 100;
    if (!positive)
    step = -step;

    color col = #4dac26;
    if (!positive)
    col = #d01c8b;

    while(true) {
        MT = P();

        e = drawCorrectedTraceInTriangleFrom(S, Ps[0], Vs[0], Ps[1], Vs[1], Ps[2], Vs[2], iterations, step, E, MT, col);
        visitedT[M.t(corner)] = true;
        
        if (e[1] > 1 && !MT.equals(P())) {
            traceMidPoints[M.t(corner)] = P(MT);
        } else {
            traceMidPoints[M.t(corner)] = P(S);
        }
        if (corner == orig_corner) {
            traceMidPoints[M.t(corner)] = P(S);
        }

        int c = corner;
        if (e[0] == 1) {//b
            c = M.n(corner);
        } else if (e[0] == 2) {//c
            c = M.p(corner);
        }

        corner = M.u(c); //unswing into the next triangle
        if ((M.t(corner) == M.t(c)) || //Border case
            (e[0] == 0) || // Looping inside the triangle
            (M.exterior[M.t(corner)]) || // Dont consider this triangle
            (visitedT[M.t(corner)])) { // Check if we have already been in this triangle
            return orig_corner;
        }
        Ps = fillPoints(corner);
        Vs = fillVectors(corner);

        S = E;
    }
}

pt[] TraceMeshStartingFrom(int corner) {
    boolean visitedT[] = new boolean[M.nt];
    boolean TrueT[] = new boolean[M.nt];
    pt traceMidPoints[] = new pt[M.nt];
    Arrays.fill(visitedT, false);
    Arrays.fill(TrueT, true);
    
    if (M.exterior[M.t(corner)]) {
        return traceMidPoints;
    }

    int traceCount = 0;
    while(true) {
        traceCount += 1;
    
      TraceInDirection(corner, traceMidPoints, visitedT, true, traceCount); // Forward pass
      TraceInDirection(corner, traceMidPoints, visitedT, false, traceCount); // Backward pass

      boolean found = false;
      for (int i = 0; i < M.nt; i++) {
        if (visitedT[i] == false && M.exterior[i] == false) {
          corner = 3 * i;
          found = true;
          break;
        }
      }

      if (!found) {
        break;
      }   
    }

    return traceMidPoints;
}
