class collapser {
    float threshold = 100.0;
    int maxRecursionDepth = 5;

    void AnalyseCollapseAnalyse() {
        int pre = FMESH.CountNarrowTriangles();
        CollapseFATMesh(0);
        int pos = FMESH.CountNarrowTriangles();
        println("Collapse done", pre, pos);
    }

    void CollapseFATMesh(int depth) {
        if (depth >= maxRecursionDepth) {
            return;
        }
        println("Depth:", depth);

        for (int i = 0; i < FMESH.AM.nc; i++) {
            int p = FMESH.AM.p(i), n = FMESH.AM.n(i);
            if (d(FMESH.AM.g(p), FMESH.AM.g(n)) < threshold) {
                collapse(i);
            }
        }
        FMESH.AM.c = 0;
        CollapseFATMesh(depth+1);
    }

    void collapse (int c) {
        int b   = FMESH.AM.p(c),
            oc  = FMESH.AM.o(c),
            vnc = FMESH.AM.v(FMESH.AM.n(c));
        // collapse the edge opposite to c by collapsing prev(c) into next(c)
        if (FMESH.validity[c] == 1 && 
            FMESH.AM.o(c) != c && 
            FMESH.CT[FMESH.AM.p(c)] == -1 && 
            FMESH.CT[FMESH.AM.n(c)] != -1  && 
            FMESH.AM.o(FMESH.AM.n(c)) != FMESH.AM.n(c) && 
            FMESH.AM.o(FMESH.AM.u(FMESH.AM.n(c))) != FMESH.AM.u(FMESH.AM.n(c))
        ) {
            println("collapsed edge opposite to corner:", c);
            for (int a = b; a != FMESH.AM.n(oc); a = FMESH.AM.p(FMESH.AM.r(a))) {
                FMESH.AM.V[a] = vnc;
            }
            FMESH.AM.V[FMESH.AM.p(c)] = vnc;
            FMESH.AM.V[FMESH.AM.n(FMESH.AM.o(c))] = vnc;
            FMESH.AM.O[FMESH.AM.l(c)] = FMESH.AM.r(c); 
            FMESH.AM.O[FMESH.AM.r(c)] = FMESH.AM.l(c);     
            FMESH.AM.O[FMESH.AM.l(oc)] = FMESH.AM.r(oc); 
            FMESH.AM.O[FMESH.AM.r(oc)] = FMESH.AM.l(oc); 
            // invalidate collapsed corners
            FMESH.validity[c] = 0;
            FMESH.validity[FMESH.AM.n(c)] = 0;
            FMESH.validity[FMESH.AM.p(c)] = 0;
            FMESH.validity[oc] = 0;
            FMESH.validity[FMESH.AM.p(oc)] = 0;
            FMESH.validity[FMESH.AM.n(oc)] = 0;
        }
    }
}