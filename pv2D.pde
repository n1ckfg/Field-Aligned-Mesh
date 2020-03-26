
float det(vec U, vec V) {
    return dot(R(U), V);
}     

float[] getNBCoefficients(pt A, pt B, pt C, pt P) {
    float[] ret = new float[3];
    vec AP = V(A, P);
    vec AB = V(A, B);
    vec AC = V(A, C);
    float denominator =  det(AB, AC);

    // ret 0: A, 1: B, 2: C
    ret[1] = det(AP, AC) / denominator;
    ret[2] = det(AB, AP) / denominator;
    ret[0] = 1 - (ret[1] + ret[2]);
    return ret;
}

vec getNBCTransform(vec Aprime, vec Bprime, vec Cprime, float[] nbc) {
    return V(
        nbc[0] * Aprime.x + nbc[1] * Bprime.x + nbc[2] * Cprime.x, 
        nbc[0] * Aprime.y + nbc[1] * Bprime.y + nbc[2] * Cprime.y,
        nbc[0] * Aprime.z + nbc[1] * Bprime.z + nbc[2] * Cprime.z
    );
}

boolean isOnTriangleBoundary(pt Pm, pt Pa, pt Pb, pt Pc) {
    return abs(d(Pa, Pm) + d(Pm, Pb) - d(Pa, Pb)) < 0.0001 || 
    abs(d(Pb, Pm) + d(Pm, Pc) - d(Pc, Pb)) < 0.0001 ||
    abs(d(Pa, Pm) + d(Pm, Pc) - d(Pa, Pc)) < 0.0001;
}

boolean isOnTriangleFace(pt Pm, pt Pa, pt Pb, pt Pc) {
    return 
    (turnAngle(Pa, Pb, Pm) > 0 && turnAngle(Pb, Pc, Pm) > 0  && turnAngle(Pc, Pa, Pm) > 0);
}

boolean isInsideTriangle(pt Pm, pt Pa, pt Pb, pt Pc) {
    return isOnTriangleFace(Pm, Pa, Pb, Pc) || isOnTriangleBoundary(Pm, Pa, Pb, Pc);
}


pt getIntersection(pt p1, pt p2, pt p3, pt p4)
{
    float x1, x2, x3, x4, y1, y2, y3, y4, s1_x, s1_y, s2_x, s2_y, s, t;
    x1 = p1.x; y1 = p1.y; x2 = p2.x; y2 = p2.y; x3 = p3.x; y3 = p3.y; x4 = p4.x; y4 = p4.y;
    s1_x = x2 - x1;     s1_y = y2 - y1;
    s2_x = x4 - x3;     s2_y = y4 - y3;
    s = (-s1_y * (x1 - x3) + s1_x * (y1 - y3)) / (-s2_x * s1_y + s1_x * s2_y);
    t = ( s2_x * (y1 - y3) - s2_y * (x1 - x3)) / (-s2_x * s1_y + s1_x * s2_y);
    if (s > 0+1e-3 && s < 1-1e-3 && t > 0+1e-3 && t < 1-1e-3)
    {
        return P(x1 + (t * s1_x), y1 + (t * s1_y), 0);
    }
    return null;
}

float angle(vec V) {
    return(atan2(V.y, V.x));
};                                                       // angle between <1,0> and V (between -PI and PI)
float angle(pt A, pt B, pt C) {
    return  angle(V(B, A), V(B, C));
}                                       // angle <BA,BC>
float turnAngle(pt A, pt B, pt C) {
    return  angle(V(A, B), V(B, C));
}  