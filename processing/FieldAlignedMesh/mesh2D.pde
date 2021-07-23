// PLANAR TRIANGLE MESH
// Jarek Rossignac, Nov 6, 2019

float eps = 0.01;

public static int indexOf(int needle, int[] haystack)
{
    for (int i=0; i<haystack.length; i++)
    {
        if (haystack[i] == needle) return i;
    }
    return -1;
}

class MESH {
    // VERTICES
    int nv=0, maxnv = 3000;
    pt[] G = new pt [maxnv];   // location of vertex
    vec[] F = new vec [maxnv]; // vector at vertex
    ArrayList<Integer> constrainedIndices = new ArrayList<Integer>();
    ArrayList<vec> constrainedVectors = new ArrayList<vec>();

    // TRIANGLES
    int nt = 0, maxnt = maxnv*4;
    boolean[] isInterior = new boolean[maxnv];
    boolean[] exterior = new boolean[maxnv];

    // CORNERS
    int c=0;    // current corner
    int nc = 0; // corner count
    int[] V = new int [3*maxnt];   // Corner table c.v
    int[] O = new int [3*maxnt];   // Corner table o.v

    MESH() {
        for (int i=0; i<maxnv; i++) {
            G[i]=P();
            F[i]=V();
        }
    }; // declare all points and vectors
    void reset() {
        nv=0;
        nt=0;
        nc=0;
    }                // removes all vertices and triangles
    void loadVertices(pt[] P, int n) {
        nv=0;
        for (int i=0; i<n; i++) addVertex(P[i]);
    }
    void writeVerticesTo(pts P) {
        for (int i=0; i<nv; i++) P.G[i].setTo(G[i]);
    }
    void addVertex(pt P) {
        G[nv++].setTo(P);
    }                                             // adds a vertex to vertex table G
    void addTriangle(int i, int j, int k) {
        V[nc++]=i;
        V[nc++]=j;
        V[nc++]=k;
        nt=nc/3;
    }     // adds triangle (i,j,k) to V table
    void addVertexPVfromPP(pt A, pt B) {
        G[nv].setTo(A);
        F[nv++].setTo(V(A, B));
    }                                             // adds a vertex to vertex table G

    void markExterior () {
        pt Pm = Mouse();
        int corner = -1;
        for (int t = 0; t < M.nc; t++) {
            // Get the three vertices for the triangle
            pt a = M.g(t);
            pt b = M.g(M.n(t));
            pt c = M.g(M.n(M.n(t)));
            if (isInsideTriangle(Pm, a, b, c)) {
                corner = t;
                println(M.t(t));
                break;
            }
        }
        if (corner != -1) {
            M.exterior[M.t(corner)] = true;
        }
    }

    ArrayList<Integer>[] getVertexNeighbourMapping() {
        ArrayList<Integer>[] vnm = (ArrayList<Integer>[]) new ArrayList[nv];
        for (int i = 0; i < nv; i++) {
            vnm[i] = new ArrayList<Integer>();
        }

        for (int i = 0; i < nc; i++) {
            vnm[v(i)].add(v(n(i)));

            // In border vertices, for the corner is last in the
            // clockwise order
            if (v(i) != v(s(i)))
                vnm[v(i)].add(v(s(i)));
        }

        return vnm;
    }

    vec[] tuck (vec[] Fin, ArrayList<Integer>[] vnm, float alpha) {
        vec[] Fout = new vec[nv];
        for (int i = 0; i < nv; i++) {
            vec avg = V(0, 0);
            ArrayList<Integer> neighbors = vnm[i];
            for (int j = 0; j < neighbors.size(); j++) {
                avg = W(avg, W(Fin[i], -1, Fin[neighbors.get(j)]));
            }
            avg.x = avg.x / neighbors.size();
            avg.y = avg.y / neighbors.size();
            Fout[i] = W(Fin[i], alpha, avg);
        }
        return Fout;
    }

    void snap (vec[] FCopy) {
        for (int i = 0; i < constrainedIndices.size(); i++) {
            FCopy[constrainedIndices.get(i)] = V(constrainedVectors.get(i));
        }
    }

    void generateConstrainedVectors() {
        // fix the seed to generate the same set of random numbers
        //java.util.Random rnd = new java.util.Random(10);
        for (int i = 0; i < nv; i++) {
            if (F[i].norm() > 2) {
                constrainedIndices.add(i);
                constrainedVectors.add(V(F[i]));
            } else {
                F[i] = V(0, 0);
            }
        }
    }

    void completeVectorField (int max_iter, float alpha) {
        ArrayList<Integer>[] vnm = getVertexNeighbourMapping();
        vec[] FCopy = new vec[nv];

        for (int i = 0; i < nv; i++) {
            FCopy[i] = V(F[i]);
        }

        for (int iter = 0; iter < max_iter; iter++) {
            FCopy = tuck(FCopy, vnm, alpha);
            FCopy = tuck(FCopy, vnm, -alpha);
            snap(FCopy);
        }

        for (int i = 0; i < nv; i++) {
            F[i] = V(FCopy[i]);
        }
    }

    void loadFromPTS(pts P) {
        int n=P.nv;
        nv=0;
        for (int i=0; i<n; i+=2) addVertexPVfromPP(P.G[i], P.G[i+1]);
    }

    // CORNER OPERATORS
    int t (int c) {
        int r=int(c/3);
        return(r);
    }                   // triangle of corner c
    int n (int c) {
        int r=3*int(c/3)+(c+1)%3;
        return(r);
    }         // next corner
    int p (int c) {
        int r=3*int(c/3)+(c+2)%3;
        return(r);
    }         // previous corner
    int c (int v) {
        return indexOf(v, V);
    }
    int v (int c) {
        return V[c];
    }                                // vertex of c
    int o (int c) {
        return O[c];
    }                                // opposite corner
    int l (int c) {
        return o(n(c));
    }                             // left
    int s (int c) {
        return n(o(n(c)));
    }                             // left
    int u (int c) {
        return p(o(p(c)));
    }                             // left
    int r (int c) {
        return o(p(c));
    }                             // right
    pt g (int c) {
        return G[V[c]];
    }                             // shortcut to get the point where the vertex v(c) of corner c is located
    vec f (int c) {
        return F[V[c]];
    }                             // shortcut to get the vector of the vertex v(c) of corner c
    pt cg(int c) {
        return P(0.8, g(c), 0.1, g(p(c)), 0.1, g(n(c)));
    }   // computes offset location of point at corner c

    boolean nb(int c) {
        return(O[c]!=c);
    };  // not a border corner
    boolean bord(int c) {
        return(O[c]==c);
    };  // not a border corner
    int firstBorderCorner() {
        int i=0;
        while (nb(i) && i<nc) i++;
        return i;
    }
    pt firstBorderEdgeMidPoint() {
        int fbc = M.firstBorderCorner();
        return P(g(p(fbc)), g(n(fbc)));
    }

    // CURRENT CORNER OPERATORS
    void next() {
        c=n(c);
    }
    void previous() {
        c=p(c);
    }
    void opposite() {
        c=o(c);
    }
    void left() {
        c=l(c);
    }
    void right() {
        c=r(c);
    }
    void swing() {
        c=s(c);
    }
    void unswing() {
        c=u(c);
    }
    void printCorner() {
        println("c = "+c);
    }

    // DISPLAY
    void showCurrentCorner(float r) {
        show(cg(c), r);
    };   // renders corner c
    void showEdge(int c) {
        edge( g(p(c)), g(n(c)));
    };  // draws edge of t(c) opposite to corner c
    void showVertices(float r) {
        for (int v=0; v<nv; v++) show(G[v], r);
    }                          // shows all vertices
    void showBorderVertices(float r) {
        for (int v=0; v<nv; v++) if (!isInterior[v]) show(G[v], r);
    } // shows only border vertices
    void showInteriorVertices(float r) {
        for (int v=0; v<nv; v++) if (isInterior[v]) show(G[v], r);
    }   // shows interior vertices
    void showTriangles() {
        for (int c=0; c<nc; c+=3) show(g(c), g(c+1), g(c+2));
    }         // draws all triangles (edges, or filled)
    void showEdges() {
        for (int i=0; i<nc; i++) showEdge(i);
    };         // draws all edges of mesh twice

    void showBorderEdges() {
        for (int i=0; i<nc; i++) {
            if (bord(i)) {
                showEdge(i);
            };
        };
    };         // draws all border edges of mesh

    void showFATBorderEdges() {
        for (int i = 0; i < nc; i++) {
            if (bord(i)) {
                if (!exterior[t(i)])
                    showEdge(i);
            } else {
                if (!exterior[t(i)] && exterior[t(o(i))]) {
                    showEdge(i);
                }
            }
            //} else {
            //    println(i, " was non bord");
            //    int ext = M.s(M.n(i));
            //    if (exterior[M.t(ext)]) {
            //        edge(g(i), g(n(i)));
            //    }
            //}
        }
    }

    void showNonBorderEdges() {
        for (int i=0; i<nc; i++) {
            if (!bord(i)) {
                showEdge(i);
            };
        };
    };         // draws all border edges of mesh
    void showVerticesAndVectors(float r) {
        for (int v=0; v<nv; v++) {
            show(G[v], r);
            arrow(G[v], F[v]);
        }
    }                          // shows all vertices
    void drawArrows()
    {
        stroke(blue);
        for (int v=0; v<nv; v++)
        {
            if (completeVectorField && !constrainedIndices.contains(v))
                fill(red);
            else
                fill(blue);
            arrow(G[v], F[v]);
            fill(white);
            show(G[v], 13);
            fill(black);
            if (v<10) label(G[v], str(v));
            else label(G[v], V(-1, 0), str(v));
        }
        noFill();
    }
    void showCorner(int c, float r) {
        if (bord(c)) show(cg(c), 1.5*r);
        else show(cg(c), r);
        // label(cg(c), str(c));
    }
    
    // renders corner c
    void showCorners(float r)
    {
        noStroke();
        for (int c=0; c<nc; c+=3)
        {
            fill(red);
            showCorner(c, r);
            fill(dgreen);
            showCorner(c+1, r);
            fill(blue);
            showCorner(c+2, r);
        }
    }

    // DISPLAY
    void classifyVertices()
    {
        for (int v=0; v<nv; v++) isInterior[v]=true;
        for (int c=0; c<nc; c++) if (bord(c)) isInterior[v(n(c))]=false;
    }

    void triangulate() {     // performs Delaunay triangulation using a quartic algorithm
        c=0;                   // to reset current corner
        pt X = new pt(0, 0);
        float r=1;
        for (int i=0; i<nv-2; i++) for (int j=i+1; j<nv-1; j++) for (int k=j+1; k<nv; k++) {
            X=CircumCenter(G[i], G[j], G[k]);
            r = d(X, G[i]);
            boolean found=false;
            for (int m=0; m<nv; m++) if ((m!=i)&&(m!=j)&&(m!=k)&&(d(X, G[m])<=r)) found=true;
            if (!found) {
                if (cw(G[i], G[j], G[k])) addTriangle(i, j, k);
                else addTriangle(i, k, j);
            };
        };
    }

    void computeO() {   // slow method to set the O table from the V table, assumes consistent orientation of tirangles
        for (int i=0; i<3*nt; i++) {
            O[i]=i;
        };  // init O table to -1: has no opposite (i.e. is a border corner)
        for (int i=0; i<3*nt; i++) {
            for (int j=i+1; j<3*nt; j++) {       // for each corner i, for each other corner j
                if ( (v(n(i))==v(p(j))) && (v(p(i))==v(n(j))) ) {
                    O[i]=j;
                    O[j]=i;
                };
            };
        }; // make i and j opposite if they match
    }

    void computeOfast() // faster method for computing O
    {
        int nIC [] = new int [maxnv];                            // number of incident corners on each vertex
        println("COMPUTING O: nv="+nv +", nt="+nt +", nc="+nc );
        int maxValence=0;
        for (int c=0; c<nc; c++) {
            O[c]=c;
        };                      // init O table to -1: has no opposite (i.e. is a border corner)
        for (int v=0; v<nv; v++) {
            nIC[v]=0;
        };                    // init the valence value for each vertex to 0
        for (int c=0; c<nc; c++) {
            nIC[v(c)]++;
        }                   // computes vertex valences
        for (int v=0; v<nv; v++) {
            if (nIC[v]>maxValence) {
                maxValence=nIC[v];
            };
        };
        println(" Max valence = "+maxValence+". "); // computes and prints maximum valence
        int IC [][] = new int [maxnv][maxValence];                 // declares 2D table to hold incident corners (htis can be folded into a 1D table !!!!!)
        for (int v=0; v<nv; v++) {
            nIC[v]=0;
        };                     // resets the valence of each vertex to 0 . It will be sued as a counter of incident corners.
        for (int c=0; c<nc; c++) {
            IC[v(c)][nIC[v(c)]++]=c;
        }        // appends incident corners to corresponding vertices
        for (int c=0; c<nc; c++) {                                 // for each corner c
            for (int i=0; i<nIC[v(p(c))]; i++) {                     // for each incident corner a of the vertex of the previous corner of c
                int a = IC[v(p(c))][i];
                for (int j=0; j<nIC[v(n(c))]; j++) {                   // for each other corner b in the list of incident corners to the previous corner of c
                    int b = IC[v(n(c))][j];
                    if ((b==n(a))&&(c!=n(b))) {
                        O[c]=n(b);
                        O[n(b)]=c;
                    };  // if a and b have matching opposite edges, make them opposite
                };
            };
        };
    } // end computeO

    pt triCenter(int c) {
        return P(g(c), g(n(c)), g(p(c)));
    }  // returns center of mass of triangle of corner c
    pt triCircumcenter(int c) {
        return CircumCenter(g(c), g(n(c)), g(p(c)));
    }  // returns circumcenter of triangle of corner c

    void smoothenInterior() { // even interior vertiex locations
        pt[] Gn = new pt[nv];
        int[] sum = new int[nv];
        for (int v=0; v<nv; v++) sum[v]=0;
        for (int v=0; v<nv; v++) Gn[v]=P(0, 0);
        for (int c=0; c<3*nt; c++)
        {
            float d=d(g(n(c)), g(p(c)));
            Gn[v(c)].add(d, P(g(n(c)), g(p(c))));
            sum[v(c)]+=d;
        }
        for (int v=0; v<nv; v++) Gn[v].scale(1./sum[v]);
        for (int v=0; v<nv; v++) if (isInterior[v]) G[v].translateTowards(.1, Gn[v]);
    }
} // end of MESH
