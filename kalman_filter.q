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
    W: (delta % (1-delta)) * eye 2;
    V: 1f;
    m0: estimates;
    c0: covariances;
    Ft: x, 1f;

    alphat: G mmu m0; // a_t = G_t * m_t-1 (EQ 1)
    Rt: ((G mmu c0) mmu flip[G]) + W; // R_t = G_t * C_t-1 * T(G) + W_t (EQ 2)
    ft: Ft mmu alphat; // f_t = T(F_t) * a_t (EQ 5)
    et: y - ft; // e_t = y_t - f_t (EQ 3)
    Qt: ((Ft mmu Rt) mmu transpose[Ft]) + V; // Q_t = T(F_t) * R_t * F_t + V_t (EQ 6)
    At: ((Rt mmu transpose[Ft]) mmu 1%Qt); // A_t = R_t * F_t * inv(Q_t) (EQ 7)
    mt: (At *\: et) + alphat; // m_t = a_t + A_t * e_t (EQ 4)
    Ct: (eye[2] - (At mmu Ft)) mmu Rt; // C_t = R_t - A_t * Q_t * T(A_t) (EQ 8)
    (mt;Ct)}  // Return new updates

