// import linear regression module
\l linear_regression.q

// load tables
tab1: 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USA500IDXUSD.csv;
tab2: 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USATECHIDXUSD.csv;
tab3: flip `dateTime`spread`mean`up`low`ewma!("P"$();"F"$();"F"$();"F"$();"F"$();"F"$());
historial_tab1: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:data/SP500_hist.csv;
historial_tab2: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:data/NASDAQ100_hist.csv;

// Fix data and take log(prices)
priceX: 0!1_(update delta:0f^deltas dateTime from distinct select distinct dateTime, log bid, log ask from update dateTime:"P"$@[;19;:;"."] each dateTime from tab1);
priceY: 0!1_(update delta:0f^deltas dateTime from distinct select distinct dateTime, log bid, log ask from update dateTime:"P"$@[;19;:;"."] each dateTime from tab2);
spreads: select from tab3;

// Create an empty auxiliary table
tAux: 1_1#priceX;
profit: 0;

// Calculate alpha and beta from historical values
beta_lr: betaF[px:-100#log historial_tab1`close;py:-100#log historial_tab2`close]; // we only take most recent 100 values for the alpha and beta 
alpha_lr: alphaF[px;py];
// We calculate an historical standard deviation
std_lr: dev[(1000#exec bid from priceY) - (1000#exec bid from priceX)];

/ load and initialize kdb+tick 
/ all tables in the top level namespace (.) become publish-able
\l tick/u.q
.u.init[];

// Read and write on buffer functions
.ringBuffer.read:{[t;i] $[i<=count t; i#t; i rotate t] }
.ringBuffer.write:{[t;r;i] @[t;(i mod count value t)+til 1;:;r];}

// Initialize index and empty tables (We will access directly to these objects from dashboards)
.streamPair.i:-1;
.streamPair.iEWMA:-1;
.streamPair.priceX: 1000#tAux;
.streamPair.priceY: 1000#tAux;
.streamPair.spreads: 1000#tab3;

// Timer function
timer:{t:.z.p;while[.z.p<t+x&abs x-16*1e6]}    / 16 <- timer variable

.streamPair.genPair:{
      // We wait some delta
      d: `float$(priceX[.streamPair.i+:1][`delta]);
      timer[d];
      // We take the i element from our tables
      resX: enlist priceX[.streamPair.i];
      resY: enlist priceY[.streamPair.i];

      // We calculate spreads for linear regression
      s: priceY[.streamPair.i][`bid] - ((priceX[.streamPair.i][`bid] * beta_lr)+alpha_lr);
      ewma: $[.streamPair.i<=0;0f;(s - .streamPair.spreads[.streamPair.iEWMA-1][`spread]) % .streamPair.spreads[.streamPair.iEWMA-1][`spread]];
      // ONCE IT SURPASSES 1000 ELEMS IT IS USELESS MAYBE USE `if[.streamPair.iEWMA = 999f ; .streamPair.iEWMA: 0f];` ¿?
      .streamPair.iEWMA+:1;
      resSpread: enlist `dateTime`spread`mean`up`low`ewma!("p"$(priceX[.streamPair.i][`dateTime]);"f"$(s);"f"$(0);"f"$(1.96*std_lr);"f"$(-1.96*std_lr);"f"$0f^(sqrt[0.06*(ewma xexp 2) + 0.94*(.streamPair.spreads[.streamPair.iEWMA-1][`ewma] xexp 2)])); 
     
      // We update our buffer tables with those values
      .ringBuffer.write[`.streamPair.priceX;resX;.streamPair.i];
      .ringBuffer.write[`.streamPair.priceY;resY;.streamPair.i];
      .ringBuffer.write[`.streamPair.spreads;resSpread;.streamPair.i];
      resX

 }

// Publish stream updates each milisecond
.z.ts: {.streamPair.genPair[]]} 

// Snapshot read from our buffer
.u.snap:{[t] .ringBuffer.read[.streamPair.priceX;.streamPair.i]} // reqd. by dashboards

\t 16
