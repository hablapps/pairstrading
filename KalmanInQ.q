
// devolver m y e

eye:{(2#x)#1f,x#0f}
zeros: {(x#0f)}
transpose: {enlist each x}


delta: 1e-5;

G: eye 2;
W: delta % (1-delta) * eye 2;
V: 1f;

m0: zeros 2;
c0: eye 2;

estimates: zeros 2;

innovs: ();
covariances: zeros 2;

// -----------------
x: 1f;
y: 1f;
yt: y;
Ft: x, 1f;

// a_t = G_t * m_t-1 
// EQ 1
alphat: G mmu m0;

// R_t = G_t * C_t-1 * T(G) + W_t
// EQ 2
Rt: ((G mmu c0) mmu flip G) + W ;

// f_t = T(F_t) * a_t
// EQ 5
ft: Ft mmu alphat;

// e_t = y_t - f_t
// EQ 3
et: yt - ft;

innovs ,: et;

// Q_t = T(F_t) * R_t * F_t + V_t
// EQ 6
Qt: ((Ft mmu Rt) mmu transpose Ft)+V;

// A_t R_t * F_t * inv(Q_t)
// EQ 7
At: ((Rt mmu transpose Ft) mmu Qt);

// m_t = a_t + A_t * e_t
// EQ 4
mt: alphat + (At mmu et);

// C_t = R_t - A_t * Q_t * T(A_t)
// EQ 8
Ct: (eye[2] - ((At mmu Ft) mmu Rt));

estimates,: mt;

covariances,: Ct;

// update mt and Ct
m0:: mt;
C0:: Ct;

estimates





