class fieldMesh {
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
                for (int i = 0; i < TRACER.stabs.get(c1).size(); i++) {
                    for (int j = 0; j < TRACER.stabs.get(c2).size(); j++) {
                        tracePt p1 = TRACER.stabs.get(c1).get(i);
                        tracePt p2 = TRACER.stabs.get(c2).get(j);
                        if (p1.traceId == p2.traceId) {
                            beam(p1.point, p2.point, 2*rt);
                            fatEdgeDone = true;
                            // Draw the Non Fat Edges
                            if (TRACER.stabs.get(c3).size() == 1) {
                                // Connect with the opposite tracepoint
                                tracePt p3 = TRACER.stabs.get(c3).get(0);
                                beam(p1.point, p3.point, rt);
                                beam(p2.point, p3.point, rt);
                            } else {
                                // Connect with one of the vertices, c1 or c3
                                pt p31 = M.g(c1), p32 = M.g(c3);
                                if (d(p1.point, p32) > d(p2.point, p31)) {
                                    beam(p1.point, p32, rt);
                                } else {
                                    beam(p2.point, p31, rt);
                                }
                            }
                        }
                    }
                }
            }
            if (!fatEdgeDone) {
                for (int i = 0; i < TRACER.stabs.get(c2).size(); i++) {
                    for (int j = 0; j < TRACER.stabs.get(c3).size(); j++) {
                        tracePt p1 = TRACER.stabs.get(c2).get(i);
                        tracePt p2 = TRACER.stabs.get(c3).get(j);
                        if (p1.traceId == p2.traceId) {
                            beam(p1.point, p2.point, 2*rt);
                            fatEdgeDone = true;
                            // Draw the Non Fat Edges
                            if (TRACER.stabs.get(c1).size() == 1) {
                                tracePt p3 = TRACER.stabs.get(c1).get(0);
                                beam(p1.point, p3.point, rt);
                                beam(p2.point, p3.point, rt);
                            } else {
                                // Connect with one of the vertices, c1 or c3
                                pt p31 = M.g(c2), p32 = M.g(c1);
                                if (d(p1.point, p32) > d(p2.point, p31)) {
                                    beam(p1.point, p32, rt);
                                } else {
                                    beam(p2.point, p31, rt);
                                }
                            }
                        }
                    }
                }
            }
            if (!fatEdgeDone) {
                for (int i = 0; i < TRACER.stabs.get(c3).size(); i++) {
                    for (int j = 0; j < TRACER.stabs.get(c1).size(); j++) {
                        tracePt p1 = TRACER.stabs.get(c3).get(i);
                        tracePt p2 = TRACER.stabs.get(c1).get(j);
                        if (p1.traceId == p2.traceId) {
                            beam(p1.point, p2.point, 2*rt);
                            fatEdgeDone = true;
                            // Draw the Non Fat Edges
                            if (TRACER.stabs.get(c2).size() == 1) {
                                tracePt p3 = TRACER.stabs.get(c2).get(0);
                                beam(p1.point, p3.point, rt);
                                beam(p2.point, p3.point, rt);
                            } else {
                                // Connect with one of the vertices, c1 or c3
                                pt p31 = M.g(c3), p32 = M.g(c2);
                                if (d(p1.point, p32) > d(p2.point, p31)) {
                                    beam(p1.point, p32, rt);
                                } else {
                                    beam(p2.point, p31, rt);
                                }
                            }
                        }
                    }
                }   
            }
        }
    }
}