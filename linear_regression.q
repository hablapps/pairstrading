// Alpha and beta functions 
// These formulas are derived from Ordinary Least Squares (OLS) regression for one variable
// OLS regression is a method used to estimate the relationship between a dependent variable (y) and one or more independent variables (x).

// Function to calculate the beta coefficient (slope) using OLS
// The beta coefficient (slope) represents the change in the dependent variable for a one-unit change in the independent variable.
// This function computes the beta coefficient using the formula:
//      beta = ((n * Σ(x*y)) - (Σx * Σy)) / ((n * Σ(x^2)) - (Σx)^2)    
betaF:{dot:'[sum;*];                                      
      ((n*dot[x;y])-(*/)(sum')(x;y))%                         
      ((n:count[x])*dot[x;x])-sum[x]xexp 2};


// Function to calculate the alpha coefficient (intercept) using OLS
// The alpha coefficient (intercept) represents the value of the dependent variable when the independent variable is zero.
// This function computes the alpha coefficient using the formula:
//      alpha = Mean(y) - beta * Mean(x)
alphaF: {avg[y]-(betaF[x;y]*avg[x])};