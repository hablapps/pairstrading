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
fcoint: {@[;1]0f^coint[x;y]`}

// We hardcore read from every .csv the historical data
syms:`SP500_hist`NASDAQ100_hist`BFX`FCHI`GDAXI`HSI`KS11`MXX`N100`N225`NYA`RUT`STOXX
rs:{([]sym:x;close:first((5#" "),"F";csv) 0:`$":data/stocks/",string[x],".csv")}

// We join every table in one
t: `sym xgroup raze rs each syms

// We apply our cointegration function on every pair of symbols form our crossedList
matrix: fcoint .' 0f^neg[trange]#''@\:[;`close](@/:[t]')syms cross syms

// We create a p-values matrix from the ADF test results and set values above the diagonal to 1
pvalues: ones (count[syms]*til count syms)_matrix 


pyhm:.pykx.import[`seaborn]`:heatmap

pyhm[pvalues;`xticklabels pykw syms;`yticklabels pykw syms;`cmap pykw `RdYlGn_r]

pyshow:.pykx.import[`matplotlib.pyplot]`:show

pyshow[::]

