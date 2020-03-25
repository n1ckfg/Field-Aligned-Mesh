class fieldMesh {
    void show () {
        // println("SHOWING STABS");
        // Use TRACER Stabs to Construct the new Edges
        for (int i = 0; i < M.nt; i++) {
            // Get the Corners for this Triangle
            int c1 = 3*i;
            int c2 = M.n(c1), c3 = M.n(M.n(c1));
            // Get the stabs at these corners
            // println(i, c1, TRACER.stabs.get(c1).size(), TRACER.stabs.get(c2).size(), TRACER.stabs.get(c3).size());
        }
    }
}