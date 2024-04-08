// We import pykx and our linear regression module
system "l C:\\q\\pykx.q"
\l C:/q/dash/sample/linear_regression.q

// We import the cointegration function from statsmodels library in python
coint:.pykx.import[`statsmodels.tsa.stattools]`:coint; 

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
// @return {dict} Dictionary with cointegration results
fCoint: {p1:0f^(exec close from superTab where sym=x);
        p2: 0f^(exec close from superTab where sym=y); 
        r: 0f^coint[1218#p1;1218#p2]`; 
        `pair`score`pvalue`porcentages!(enlist (x,y);r[0];r[1];enlist r[2])};

// We hardcore read from every .csv the historical data
historial_tab1: update sym: `SP500 from 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/SP500_hist.csv;
historial_tab2: update sym: `NASDAQ100 from 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/NASDAQ100_hist.csv;
historial_tab3: update sym: `BFX from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/BFX.csv;
historial_tab4: update sym: `FCHI from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/FCHI.csv;
historial_tab5: update sym: `GDAXI from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/GDAXI.csv;
historial_tab6: update sym: `HSI from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/HSI.csv;
historial_tab7: update sym: `KS11 from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/KS11.csv;
historial_tab8: update sym: `MXX from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/MXX.csv;
historial_tab9: update sym: `N100 from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/N100.csv;
historial_tab10: update sym: `N225 from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/N225.csv;
historial_tab11: update sym: `NYA from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/NYA.csv;
historial_tab12: update sym: `RUT from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/RUT.csv;
historial_tab13: update sym: `STOXX from 1_ flip `date`open`high`low`close`adjClose`vol!("PFFFFFF";",") 0: `:C:/q/dash/sample/data/stocks/STOXX.csv;

// We join every table in one
superTab: historial_tab1 uj historial_tab2 uj historial_tab3 uj historial_tab4 uj historial_tab5 uj historial_tab6 uj historial_tab7 uj historial_tab8 uj historial_tab9 uj historial_tab10 uj historial_tab11 uj historial_tab12 uj historial_tab13;

// We extract every distinct symbol
symList: exec distinct sym from superTab;

// We calculate the Cartesian product of every symbol in the list.
crossedList: (symList cross symList);

// We apply our cointegration function on every pair of symbols form our crossedList
matrix: fCoint .' crossedList;

// We create a p-values matrix from the ADF test results and set values above the diagonal to 1
pvalues: ones ((count[symList])*til count[symList])_(exec pvalue from matrix); 

// We set some variables in Pyhton memory
.pykx.set[`ADFpairs;pvalues];
.pykx.set[`syms;symList];

// We change to Python in order to plot our results and we import our needed libraries
.pykx.pyexec"import numpy as np";
.pykx.pyexec"import seaborn";
.pykx.pyexec"import matplotlib.pyplot as plt";

// We convert our pvalues to a numpy array so that we do not get any parsing errors
.pykx.pyexec"pvalues = np.array(ADFpairs, float)";

// We plot a heatmap
.pykx.pyexec"seaborn.heatmap(pvalues, xticklabels = syms, yticklabels=syms, cmap='RdYlGn_r', mask= (pvalues >= 0.99))";
.pykx.pyexec"plt.show()";
