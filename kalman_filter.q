// Reference
// https://www.quantstart.com/articles/State-Space-Models-and-the-Kalman-Filter/

// Auxiliary functions
// Creates a diagonal matrix
eye:{(2#x)#1f,x#0f}
// Creates a 0's symetric matrix
zeros: {(x#0f)}
// JUST WORKS FOR 1X2 MATRIXES -> transform a 1x2 matrix to 2x1
transpose: {enlist each x}


// This function implements the Kalman Filter algorithm to estimate the state of a linear dynamic system.
// It takes the following parameters:
/   x: The observation matrix (measurement) at time t.
/   y: The state transition matrix (predicted state) at time t.
/   delta: The observation covariance matrix, representing the uncertainty in the measurements.
/   estimates: The estimated state mean vector at time t-1.
/   covariances: The estimated state covariance matrix at time t-1.

// The function returns:
/   estimates: estimated updated state mean vector at time t
/   covariances: estimated updated state covariance matrix at time t.

kalmanFilter:{[x;y;delta;estimates; covariances]

    // Initialize static values 
    G: eye 2;
    W: delta % (1-delta) * eye 2;
    W[0;1] : 0f;
    W[1;0] : 0f;
    V: 1f;
    m0: zeros 2;
    c0: eye 2;
    yt:y;
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
    Ct: (eye[2] - (At mmu Ft)) mmu Rt;

    // Return new updates
    (mt;Ct)}

co: (2#2)#0f,2#0f;
est1: kalmanFilter[2f;3f;1e-5;zeros[2];co][0];
est2: kalmanFilter[3f;5f;1e-5;zeros[2];co][0];
est3: kalmanFilter[4f;1f;1e-5;zeros[2];co][0];
