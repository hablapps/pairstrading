// import linear regression module
\l C:/q/dash/sample/linear_regression.q

// load tables
tab1: 40000#1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:C:/q/dash/sample/data/stocks/USA500IDXUSD.csv;
tab2: 40000#1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:C:/q/dash/sample/data/stocks/USATECHIDXUSD.csv;
tab3: flip `dateTime`spread`mean`up`low`operation!("P"$();"F"$();"F"$();"F"$();"F"$();"F"$());

// Fix data and take log(prices)
priceX: 0!1_(update delta:0f^deltas dateTime from distinct select distinct dateTime, log bid, log ask from update dateTime:"P"$@[;19;:;"."] each dateTime from tab1);
priceY: 0!1_(update delta:0f^deltas dateTime from distinct select distinct dateTime, log bid, log ask from update dateTime:"P"$@[;19;:;"."] each dateTime from tab2);
spreads: 200#select from tab3;

// Create an empty auxiliary table
tAux: 1_1#priceX;
profit: 0;

// Calculate alpha y beta and spreads
px: exec bid from priceX;
py: exec bid from priceY;
s1: py - ((px * betaF[px;py])-alphaF[px;py]);
mean: avg[100#s1];
std: dev[100#s1];
spreads: update dateTime: priceX[`dateTime], spread: s1, mean: mean ,up: mean+1.96*std, low: mean-1.96*std , operation:0 from spreads;

/ load and initialize kdb+tick 
/ all tables in the top level namespace (.) become publish-able
\l C:/q/dash/sample/tick/u.q
.u.init[];

// Read and write on buffer functions
.ringBuffer.read:{[t;i] $[i<=count t; i#t; i rotate t] }
.ringBuffer.write:{[t;r;i] @[t;(i mod count value t)+til 1;:;r];}

// Initialize index and empty tables (We will access directly to these objects from dashboards)
.streamPair.i:-1;
.streamPair.priceX: 1000#tAux;
.streamPair.priceY: 1000#tAux;
.streamPair.spreads: 1000#tab3;
//.streamPair.spreads: update spread:0 from .streamPair.spreads;
// Timer function
timer:{t:.z.p;while[.z.p<t+x&abs x-16*1e6]}    / 16 <- timer variable

.streamPair.genPair:{
      // We wait some delta
      d: `float$(priceX[.streamPair.i+:1][`delta]);
      timer[d];
      // We take the i element from our tables
      resX: enlist priceX[.streamPair.i];
      resY: enlist priceY[.streamPair.i];
      resSpread: enlist spreads[.streamPair.i];
      // We update our buffer tables with those values
      .ringBuffer.write[`.streamPair.priceX;resX;.streamPair.i];
      .ringBuffer.write[`.streamPair.priceY;resY;.streamPair.i];
      .ringBuffer.write[`.streamPair.spreads;resSpread;.streamPair.i];
      resX
 }


// Publish stream updates each milisecond
.z.ts: {u.pub[`tAux; .streamPair.genPair[]]} 

// Snapshot read from our buffer
.u.snap:{[t] .ringBuffer.read[.streamPair.priceX;.streamPair.i]} // reqd. by dashboards

\t 16