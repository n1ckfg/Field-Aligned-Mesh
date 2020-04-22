class collapser {
    float threshold = 80.0;
    int[] validity;


    void CollapseFATMesh() {
        validity = new int[FMESH.AM.nc];
        for (int i = 0; i < FMESH.AM.nc; i++) {
            validity[i] = 1;
        }

        for (int i = 0; i < FMESH.AM.nc; i++) {
            if (validity[i] == 1) {
                if (FMESH.AM.o(i) != i) { // not a border edge
                    int p = FMESH.AM.p(i), n = FMESH.AM.n(i);
                    if (FMESH.CT[p] != FMESH.CT[n]) { // not an original/trace edge
                        if (d(FMESH.AM.g(p), FMESH.AM.g(n)) < threshold) {
                            collapse(i);
                        }
                    }
                }
            }
        }
        FMESH.AM.c = 0;
    }

    void collapse (int c) {
        if (validity == null) {
            validity = new int[FMESH.AM.nc];
            for (int i = 0; i < FMESH.AM.nc; i++) {
                validity[i] = 1;
            }
        }
        int b   = FMESH.AM.p(c),
            oc  = FMESH.AM.o(c),
            vnc = FMESH.AM.v(FMESH.AM.n(c));
        // collapse the edge opposite to c by collapsing prev(c) into next(c)
        if (validity[c] == 1 && 
            FMESH.AM.o(c) != c && 
            FMESH.CT[FMESH.AM.p(c)] == 0 && 
            FMESH.CT[FMESH.AM.n(c)] == 1 && 
            FMESH.AM.o(FMESH.AM.n(c)) != FMESH.AM.n(c) && 
            FMESH.AM.o(FMESH.AM.u(FMESH.AM.n(c))) != FMESH.AM.u(FMESH.AM.n(c))
        ) {
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
            validity[c] = 0;
            validity[FMESH.AM.n(c)] = 0;
            validity[FMESH.AM.p(c)] = 0;
            validity[oc] = 0;
            validity[FMESH.AM.p(oc)] = 0;
            validity[FMESH.AM.n(oc)] = 0;
        }
    }
}