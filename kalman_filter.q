// Auxiliary functions
eye:{(2#x)#1f,x#0f}
zeros: {(x#0f)}
transpose: {enlist each x}

// Declare delta
delta: 1e-5f;

// Initialize values
G: eye 2;
W: delta % (1-delta) * eye 2;
W[0;1] : 0f;
W[1;0] : 0f;
V: 1f;
m0: zeros 2;
c0: eye 2;
estimates: zeros 2;
innovs: ();
covariances: zeros 2;

// -----------------
// Func params demo
x: -1f;
y: 4f;
yt: y;

// Matrix 1x2
Ft: x, 1f;

// a_t = G_t * m_t-1 
// EQ 1
// Matrix 2x2 * matrix 1x2 = matrix 1x2
alphat: G mmu m0;

// R_t = G_t * C_t-1 * T(G) + W_t
// EQ 2
// Matrix 2x2 * matrix 2x2 * matrix 2x2 + elem = matrix 2x2 
Rt: ((G mmu c0) mmu flip[G]) + W;

// f_t = T(F_t) * a_t
// EQ 5
// Matrix 1x2 * matrix 1x2 = elem
ft: Ft mmu alphat;

// e_t = y_t - f_t
// EQ 3
// elem - elem = elem
et: yt - ft;

innovs ,: et;

// Q_t = T(F_t) * R_t * F_t + V_t
// EQ 6
// Matrix 1x2 * matrix 2x2 (matrix 1x2) * matrix 2x1 + elem = elem
Qt: ((Ft mmu Rt) mmu transpose[Ft]) + V ;

// A_t = R_t * F_t * inv(Q_t)
// EQ 7
// Matrix 2x2 * matrix 2x1 * elem = matrix 2x1
At: ((Rt mmu transpose[Ft]) mmu 1%Qt);

// m_t = a_t + A_t * e_t
// EQ 4
// Matrix 1x2 * elem + matrix 1x2 = matrix 2x1
mt: (At *\: et) + alphat;

// C_t = R_t - A_t * Q_t * T(A_t)
// EQ 8
// Matrix 2x2 - matrix 1x2 (matrix 2x2) * matrix 1x2 * elem = matrix 1x2
Ct: (Rt - At) mmu (,/)(transpose[At] */: first[Qt]);

estimates,: mt;

covariances,: (,/)Ct;

// update mt and Ct
m0: mt;
C0: Ct;

estimates





