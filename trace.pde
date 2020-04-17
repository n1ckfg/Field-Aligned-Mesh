class trace {
    ArrayList<pt> points;
    int exit = -1;
    int id = -1;
    int steps = 0;
    int entry = -1;
    int direction = 0;

    trace (int id, ArrayList<pt> ps, int s, int en, int ex, int d) {
        points = ps;
        id = id;
        steps = s;
        entry = en;
        exit = ex;
        direction = d;
    }
}

class tracePt {
    pt point;
    int traceId;
    int vid;

    tracePt (pt p, int tid, int v) {
        point = P(p);
        traceId = tid;
        vid = v;
    }
}