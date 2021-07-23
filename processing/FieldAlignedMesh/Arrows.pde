class ARROW
{
    pt P = P();
    vec V = V();
    // CREATE
    ARROW() {
    }
    ARROW(pt Q, vec U) {
        P=P(Q);
        V=V(U);
    }
    // SHOW
    void show() {
        arrow(P, V);
    }
}

// ARROW FUNCTIONS
ARROW Arrow(pt Q, vec U) {
    return new ARROW(Q, U);
}
void show(ARROW A) {
    A.show();
}
ARROW LerpAverageOfArrows(ARROW A0, ARROW A1) {
    return Arrow(P(A0.P, A1.P), V(A0.V, A1.V));
}
ARROW SteadyAverageOfArrows(ARROW A0, ARROW A1)
{
    float w = angle(A0.V, A1.V);
    float m = n(A1.V)/n(A0.V);
    pt F = SpiralCenter(w, m, A0.P, A1.P);
    //fill(black); show(F,10);
    vec U = S(V(F, A0.P), V(F, A1.P), 0.5);
    pt Q = P(F, U);
    //fill(magenta); show(Q,10);
    vec V = S(A0.V, A1.V, 0.5);
    return(Arrow(Q, V));
}

ARROW AverageOfArrows(ARROW A0, ARROW A1)
{
    if (spiralAverage) return SteadyAverageOfArrows(A0, A1);
    else return LerpAverageOfArrows(A0, A1);
}

ARROW SimilaritySteadyMorphOfArrows(ARROW A0, float t, ARROW A1)
{
    float w = angle(A0.V, A1.V);
    float m = n(A1.V)/n(A0.V);
    vec V = R(W(pow(m, t), A0.V), t*w);
    pt F = SpiralCenter(w, m, A0.P, A1.P);
    pt P = L(F, R(A0.P, t*w, F), pow(m, t));
    return(Arrow(P, V));
}

//pt spiral(pt A, pt B, pt C, pt D, float t, pt Q)
//  {
//  float a =spiralAngle(A,B,C,D);
//  float s =spiralScale(A,B,C,D);
//  pt G = SpiralCenter(a, s, A, C);
//  return L(G,R(Q,t*a,G),pow(s,t));
//  }


class ARROWRING
{
    int nA=0;                                // number of Arrows
    int maxnA = 6*2*2*2*2*2*2*2;             //  max number of ARROWS
    ARROW[] A = new ARROW [maxnA];                 // geometry table (vertices)
    ARROWRING() {
    }
    void declare() {
        for (int i=0; i<maxnA; i++) A[i]=new ARROW();
    }                           // creates all ARROWS, MUST BE DONE AT INITALIZATION
    void addArrow(pt Q, vec U) {
        A[nA].P=P(Q);
        A[nA].V=V(U);
        nA++;
    }                    // appends a point at position P
    void addArrow(ARROW B) {
        A[nA].P=P(B.P);
        A[nA].V=V(B.V);
        nA++;
    }                    // appends a point at position P
    void empty() {
        nA=0;
    }   // empties this object
    void showArrows() {
        for (int a=0; a<nA; a++) show(A[a]);
    }
    void showArrow(int a) {
        show(A[a]);
    }
    void showAverageArrows()
    {
        for (int a=0; a<nA; a++)
            show(AverageOfArrows(A[a], A[n(a)]));
    }
    int n(int a) {
        return (a+1)%nA;
    }
    int p(int a) {
        return (a+nA-1)%nA;
    }
    void refineInto(ARROWRING Anew)
    {
        Anew.empty();
        for (int a=0; a<nA; a++)
            //int a=1;
        {
            if (quintic)
            {
                ARROW Aa = A[p(a)], Ab = A[a], Ac = A[n(a)], Ad = A[n(n(a))];
                ARROW A1=AverageOfArrows(Aa, Ab);
                ARROW A2=AverageOfArrows(Ab, Ac);
                ARROW A3=AverageOfArrows(Ac, Ad);
                ARROW A4=AverageOfArrows(A1, Ab);
                ARROW A5=AverageOfArrows(Ab, A2);
                ARROW A6=AverageOfArrows(A2, Ac);
                ARROW A7=AverageOfArrows(Ac, A3);
                ARROW A8=AverageOfArrows(A4, A5);
                ARROW A9=AverageOfArrows(A6, A7);
                ARROW A10=AverageOfArrows(A1, A8);
                ARROW A11=AverageOfArrows(A8, A2);
                ARROW A12=AverageOfArrows(A2, A9);
                ARROW A13=AverageOfArrows(A10, A8);
                ARROW A14=AverageOfArrows(A8, A11);
                ARROW A15=AverageOfArrows(A11, A2);
                ARROW A16=AverageOfArrows(A2, A12);
                ARROW A17=AverageOfArrows(A13, A14);
                ARROW A18=AverageOfArrows(A15, A16);
                if (cubic)
                {
                    Anew.addArrow(A8);
                    Anew.addArrow(A2);
                } else
                {
                    Anew.addArrow(A17);
                    Anew.addArrow(A18);
                }
            } else
            {
                Anew.addArrow(A[a]);
                Anew.addArrow(AverageOfArrows(A[a], A[n(a)]));
            }
        }
    }
    void copyInto(ARROWRING A2)
    {
        A2.empty();
        for (int a=0; a<nA; a++) A2.addArrow(A[a]);
    }
}
