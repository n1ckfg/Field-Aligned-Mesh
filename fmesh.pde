class fieldMesh {
    boolean ChooseEdge (pt p1, pt p2, pt p3, pt p4) {
        if (mode == 0) {
            // Longer Edge
            return d(p1, p3) > d(p2, p4);
        } else if (mode == 1) {
            // Shorter Edge
            return d(p1, p3) < d(p2, p4);
        } else if (mode == 2) {
            // Edge aligned to the Trace
            return abs(dot(U(p1, p2), U(p1, p3))) > abs(dot(U(p1, p2), U(p2, p4)));
        } else if (mode == 3) {
            // Delaunay Criterion
            pt c1 = CircumCenter(p1, p2, p3);
            pt c2 = CircumCenter(p3, p4, p1);
            if (d(c1, p4) > d(c1, p1) && d(c2, p2) > d(c2, p1)) {
                return true;
            }
            return false;
        }
        return true;
    }

    boolean ShowFATM (int c1, int c2, int c3) {
        boolean fatEdgeDone = false;
        for (int i = 0; i < TRACER.stabs.get(c1).size(); i++) {
            for (int j = 0; j < TRACER.stabs.get(c2).size(); j++) {
                tracePt p1 = TRACER.stabs.get(c1).get(i);
                tracePt p2 = TRACER.stabs.get(c2).get(j);
                if (p1.traceId == p2.traceId) {
                    fill(magenta);
                    beam(p1.point, p2.point, rt);
                    sphere(p1.point, 2*rt);
                    sphere(p2.point, 2*rt);
                    fatEdgeDone = true;
                    // Draw the Non Fat Edges
                    if (TRACER.stabs.get(c3).size() == 1) {
                        // Connect with the opposite tracepoint
                        tracePt p3 = TRACER.stabs.get(c3).get(0);
                        fill(metal);
                        beam(p1.point, p3.point, rt);
                        beam(p2.point, p3.point, rt);
                    } else {
                        // Connect with one of the vertices, c1 or c3
                        pt p31 = M.g(c1), p32 = M.g(c3);
                        if (ChooseEdge(p1.point, p2.point, p32, p31)) {
                            fill(metal);
                            beam(p1.point, p32, rt);
                        } else {
                            fill(metal);
                            beam(p2.point, p31, rt);
                        }
                    }
                }
            }
        }
        return fatEdgeDone;
    }

    void show () {
        // println("SHOWING STABS");
        // Use TRACER Stabs to Construct the new Edges
        for (int c = 0; c < M.nt; c++) {
            // Get the Corners for this Triangle
            int c1 = 3*c;
            int c2 = M.n(c1), c3 = M.n(M.n(c1));
            // Get the stabs at these corners
            // println(i, c1, TRACER.stabs.get(c1).size(), TRACER.stabs.get(c2).size(), TRACER.stabs.get(c3).size());
            // Draw a fat edge aligned to the trace
            boolean fatEdgeDone = false;
            int fc = -1, sc = -1, tc = -1;
            if (!fatEdgeDone) {
                fatEdgeDone = ShowFATM(c1, c2, c3);
            }
            if (!fatEdgeDone) {
                fatEdgeDone = ShowFATM(c2, c3, c1);
            }
            if (!fatEdgeDone) {
                fatEdgeDone = ShowFATM(c3, c1, c2);   
            }
        }
    }
}