class subdivider {

    int[] W = new int [3*M.maxnt];

    void splitEdges () {
        for (int i = 0; i < M.nc; i++) {
            if (M.bord(i)) {
                M.G[M.nv] = P(M.g(M.n(i)), M.g(M.p(i))); 
                M.F[M.nv] = V(M.f(M.n(i)), M.f(M.p(i)));
                W[i] = M.nv++;
            }
            else {
                if (i < M.o(i)) {
                    M.G[M.nv] = P(M.g(M.n(i)), M.g(M.p(i)));
                    M.F[M.nv] = V(M.f(M.n(i)), M.f(M.p(i))); 
                    W[M.o(i)] = M.nv; 
                    W[i] = M.nv++; 
                } 
            } 
        }
    }

    int w (int i) {
        return W[i];
    }

    void splitTriangles() {    // splits each tirangle into 4
        for (int i = 0; i < 3*M.nt; i = i+3) {
            M.V[3*M.nt+i] = M.v(i); 
            M.V[M.n(3*M.nt+i)] = w(M.p(i)); 
            M.V[M.p(3*M.nt+i)] = w(M.n(i));
            M.V[6*M.nt+i] = M.v(M.n(i)); 
            M.V[M.n(6*M.nt+i)] = w(i); 
            M.V[M.p(6*M.nt+i)] = w(M.p(i));
            M.V[9*M.nt+i] = M.v(M.p(i)); 
            M.V[M.n(9*M.nt+i)] = w(M.n(i)); 
            M.V[M.p(9*M.nt+i)] = w(i);
            M.V[i] = w(i); 
            M.V[M.n(i)] = w(M.n(i)); 
            M.V[M.p(i)] = w(M.p(i));
        }
        M.nt = 4 * M.nt; 
        M.nc = 3 * M.nt;
    }

    void subdivide () {
        splitEdges();
        println("Edge Split Done");
        splitTriangles();
        println("Triangle Split Done");
        M.computeO();
        println("ComputeO Done");
    }
}