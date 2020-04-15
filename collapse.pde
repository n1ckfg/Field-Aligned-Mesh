class collapser {
    void collapse (int c) {
        // check if the edge to be collapsed is a border edge. if not then proceed
        if (!M.bord(c)) {
            // collapse the edge opposite to c by collapsing prev(c) into next(c)
            int b   = M.p(c),
                oc  = M.o(c),
                vnc = M.v(M.n(c));
            for (int a = b; a != M.n(oc); a = M.p(M.r(a))) {
                M.V[a] = vnc;
            }
            M.V[M.p(c)] = vnc;
            M.V[M.n(M.o(c))] = vnc;
            M.O[M.l(c)] = M.r(c); 
            M.O[M.r(c)] = M.l(c);     
            M.O[M.l(oc)] = M.r(oc); 
            M.O[M.r(oc)] = M.l(oc); 
        } 
    }
}