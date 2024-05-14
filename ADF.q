// We import pykx and our linear regression module
system "l pykx.q"
\l linear_regression.q

// 252 -> working days in a year (4 years in working days)
trange:4*252

// We import the cointegration function from statsmodels library in python
coint:.pykx.import[`statsmodels.tsa.stattools]`:coint

// @kind function
// @desc Function to set every item above the diagonal to 1 in a matrix
//       This function modifies the input matrix in place.
// @param matrix {number[][]} Input matrix
// @return {matrix} 
ones:{x .[;;:;1f]/l where((<=).')l:a cross a:til n:count x}

// @kind function
// @desc Function to compute cointegration between two assets
// Cointegration indicates a long-term relationship between assets, where the difference between them tends to oscillate around a mean.
// This function takes the close prices of both assets, computes cointegration, and returns a dictionary with the results.
// @param asset1 {float[]} Close prices of the first asset
// @param asset2 {float[]} Close prices of the second asset
// @return {dict} p_value of ADF test
fCoint: {@[;1]0f^coint[0f^x;0f^y]`}

// We hardcore read from every .csv the historical data
syms:`SP500_hist`NASDAQ100_hist`BFX`FCHI`GDAXI`HSI`KS11`MXX`N100`N225`NYA`RUT`STOXX
read_stock:{[sym1]
  update sym: sym1 from 1_ flip enlist[`close]!((5#" "),"F";",") 0:`$":data/stocks/",string[sym1],".csv"}

// We join every table in one
superTab: `sym xgroup raze read_stock each syms

// We apply our cointegration function on every pair of symbols form our crossedList
matrix: fCoint .' neg[trange]#''@\:[;`close](@/:[superTab]')syms cross syms

// We create a p-values matrix from the ADF test results and set values above the diagonal to 1
pvalues: ones (count[syms]*til count syms)_matrix 

// We set some variables in Pyhton memory
.pykx.set[`ADFpairs;pvalues];
.pykx.set[`syms;syms];

// We change to Python in order to plot our results and we import our needed libraries
.pykx.pyexec"import numpy as np";
.pykx.pyexec"import seaborn";
.pykx.pyexec"import matplotlib.pyplot as plt";

// We convert our pvalues to a numpy array so that we do not get any parsing errors
.pykx.pyexec"pvalues = np.array(ADFpairs, float)";

// We plot a heatmap
.pykx.pyexec"seaborn.heatmap(pvalues, xticklabels = syms, yticklabels=syms, cmap='RdYlGn_r', mask= (pvalues >= 0.99))";
.pykx.pyexec"plt.show()";
