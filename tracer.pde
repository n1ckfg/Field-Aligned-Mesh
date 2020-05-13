class tracer {

    int maxSteps = 5000;
    float stepSize = 0.05;
    color forwardColor = #4dac26;
    color backwardColor = #d01c8b;
    int maxTraceCount = 20;
    boolean[] visited = new boolean[300];
    ArrayList<ArrayList<tracePt>> stabs = new ArrayList<ArrayList<tracePt>>();
    ArrayList<ArrayList<trace>> allTraces = new ArrayList<ArrayList<trace>>();

    int vid = 0;

    tracer () {
    }

    pt getStartingPoint(int corner) {
        return getStartingPoint(M.getTriangleVerticesForCorner(corner));
    }

    pt getStartingPoint(pt[] vertices) {
        return P(
            vertices[0],
            vertices[1],
            vertices[2]
        ); 
    }

    pt makeTraceStep (pt p, float s, vec v) {
        return P(p, s, v);
    }

    int getNextCorner () {
        for (int i = 0; i < M.nt; i++) {
            if (!visited[i]) {
                return 3*i;
            }
        }
        return -1;
    }

    trace getTraceInTriangle (int id, pt start, int corner, int direction) {
        // sphere(start, rt);
        // println("Tracing In: ", corner);
        visited[M.t(corner)] = true;
        pt[] vertices = M.getTriangleVerticesForCorner(corner);
        vec[] vectors = M.getTriangleVectorsForCorner(corner);
        ArrayList<pt> tracePoints = new ArrayList<pt>();
        int exitCorner = -1;
        int ntp = 0;
        pt tp = P(start);
        while (ntp < maxSteps) {
            tracePoints.add(P(tp)); 
            // get the next trace point
            vec v = M.getFieldAtPoint(tp, vertices, vectors);
            pt tpn = makeTraceStep(tp, direction*stepSize, v);
            // check if the point is inside the current triangle
            // add the last point in the trace points array and exit
            pt E1 = getIntersection(tp, tpn, vertices[0], vertices[1]);
            pt E2 = getIntersection(tp, tpn, vertices[1], vertices[2]);
            pt E3 = getIntersection(tp, tpn, vertices[2], vertices[0]);
            if (E1 != null) {
                // println(tp, tpn, E1);
                stabs.get(corner).add(new tracePt(E1, id, vid));
                if (M.u(corner) != M.n(corner)) {
                    stabs.get(M.p(M.u(corner))).add(new tracePt(E1, id, vid));
                }
                vid ++;
                exitCorner = corner;
                tracePoints.add(P(E1));
                break;
            } else if (E2 != null) {
                // println(tp, tpn, E2);
                stabs.get(M.n(corner)).add(new tracePt(E2, id, vid));
                if (M.u(M.n(corner)) != M.n(M.n(corner))) {
                    stabs.get(M.p(M.u(M.n(corner)))).add(new tracePt(E2, id, vid));
                }
                exitCorner = M.n(corner);
                tracePoints.add(P(E2));
                vid ++;
                break;
            } else if (E3 != null) {
                // println(tp, tpn, E3);
                stabs.get(M.n(M.n(corner))).add(new tracePt(E3, id, vid));
                if (M.u(M.n(M.n(corner))) != M.n(M.n(M.n(corner)))) {
                    stabs.get(M.p(M.u(M.n(M.n(corner))))).add(new tracePt(E3, id, vid));
                }
                exitCorner = M.n(M.n(corner));
                tracePoints.add(P(E3));
                vid ++;
                break;
            }
            tp = P(tpn);
            ntp += 1;
        }
        // sphere(tp, rt);
        return new trace(
            id, 
            tracePoints, 
            ntp,
            corner,
            exitCorner,
            direction
        );
    }

    ArrayList<trace> getCompleteTrace (int id, int corner, int direction) {
        int segments = 0;
        ArrayList<trace> traceSegments = new ArrayList<trace>();
        // Get the starting point for the trace
        pt s = getStartingPoint(corner);
        // Copy the startCorner
        int startCorner = corner;
        // Begin Tracing
        while (true) {
            trace t = getTraceInTriangle(id, s, corner, direction);
            traceSegments.add(t);
            // Check for stopping criterions
            if (t.exit == -1) {
                // println("Looping Inside the Triangle");
                break;
            } else if (M.t(M.u(t.exit)) == M.t(corner)) {
                // println("Boundary Triangle");
                break;                
            } else if (visited[M.t(M.u(t.exit))]) {
                // println("Already Visited Triangle");
                break;
            }
            // Move to next triangle
            s = t.points.get(t.points.size()-1);
            corner = M.u(t.exit);
        }
        return traceSegments;
    }

    void getAllTraces () {
        vid = M.nv;
        int corner = 0;
        stabs = new ArrayList<ArrayList<tracePt>>();
        allTraces = new ArrayList<ArrayList<trace>>();
        // println("Started Tracing from: ", corner);
        Arrays.fill(visited, false);
        for (int i = 0; i < M.nc; i++) {
            stabs.add(new ArrayList<tracePt>());
        }
        // begin tracing
        int traceCount = 0;
        while (traceCount < maxTraceCount && corner != -1) {
            // Forward Pass
            // println("Forward Tracing from: ", corner);
            ArrayList<trace> tf = getCompleteTrace(traceCount, corner, 1);
            allTraces.add(tf);
            // Backward Pass
            // println("Backward Tracing from: ", corner);
            ArrayList<trace> tb = getCompleteTrace(traceCount, corner, -1);
            allTraces.add(tb);
            // Choose next start
            corner = getNextCorner();
            traceCount += 1;
            // println("Continuing tracing from: ", corner);
        }
    }   

    void drawTrace (ArrayList<pt> tracePoints, int n, int d) {
        noStroke();
        // choose color
        if (d == 1) {
            fill(forwardColor);
        } else if (d == -1) {
            fill(backwardColor);
        } else {
            return;
        }
        // draw
        for (int i = 0; i < tracePoints.size()-1; i++) {
            caplet(tracePoints.get(i), rt, tracePoints.get(i+1), rt);
        }
    }

    void showAllTraces () {
        // println("Traces:", allTraces.size());
        for (int i = 0; i < allTraces.size(); i++) {
            for (int j = 0; j < allTraces.get(i).size(); j++) {
                drawTrace(allTraces.get(i).get(j).points, allTraces.get(i).get(j).steps, allTraces.get(i).get(j).direction);
            }
        }
    }

    void showAllStabs () {
        for (int i = 0; i < stabs.size(); i++) {
            for (int j = 0; j < stabs.get(i).size(); j++) {
                fill(red);
                sphere(stabs.get(i).get(j).point, 2*rt);
            }
        }
    }

    void showStabsForCorner (int i) {
        for (int j = 0; j < stabs.get(i).size(); j++) {
            fill(blue);
            sphere(stabs.get(i).get(j).point, 2.5*rt);
        }        
    }

    void showStabbedTriangles () {
        fill(orange);
        for (int i = 0; i < M.nt; i++) {
            if (visited[i]) {
                int c = 3*i;
                show(
                    P(M.g(c).x, M.g(c).y, M.g(c).z+6.5),
                    P(M.g(M.n(c)).x, M.g(M.n(c)).y, M.g(M.n(c)).z+6.5),
                    P(M.g(M.n(M.n(c))).x, M.g(M.n(M.n(c))).y, M.g(M.n(M.n(c))).z+6.5)
                );
            }
        }        
    }
}