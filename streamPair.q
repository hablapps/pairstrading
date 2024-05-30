// import linear regression module
\l linear_regression.q

// load tables
read_tick:{1_ flip `dt`bid`ask`bidVol`askVol!("*FFFF";",")0: `$":data/",string[x],".csv"};
read_hist:{1_ flip enlist[`close]!("   F  ";",") 0: `$":data/",string[x],"_hist.csv"};
tab1:read_tick `USA500IDXUSD;
tab2:read_tick `USATECHIDXUSD;
tab3: flip `dt`spread`mean`up`low`ewma`up2`low2!("P"$();"F"$();"F"$();"F"$();"F"$();"F"$();"F"$();"F"$());
historial_tab1:read_hist `SP500
historial_tab2:read_hist `NASDAQ100

// Fix data and take log(prices)
price_x: 0!1_(update delta:0f^deltas dt from distinct select distinct dt, log bid, log ask from update dt:"P"$@[;19;:;"."] each dt from tab1);
price_y: 0!1_(update delta:0f^deltas dt from distinct select distinct dt, log bid, log ask from update dt:"P"$@[;19;:;"."] each dt from tab2);

// Calculate alpha and beta from historical values
beta_lr: beta_f[px:-100#log historial_tab1`close;py:-100#log historial_tab2`close]; // we only take most recent 100 values for the alpha and beta 
alpha_lr: alpha_f[px;py];
// We calculate an historical standard deviation
std_lr: dev[(1000#exec bid from price_y) - (1000#exec bid from price_x)];

/ load and initialize kdb+tick 
/ all tables in the top level namespace (.) become publish-able
\l tick/u.q
.u.init[];

// Read and write on buffer functions
.ring_buffer.read:{[t;i] $[i<=count t; i#t; i rotate t] }
.ring_buffer.write:{[t;r;i] @[t;(i mod count value t)+til 1;:;r];}

// Initialize index and empty tables (We will access directly to these objects from dashboards)
.stream_pair.i:-1;
.stream_pair.iEWMA:-1;
.stream_pair.price_x: 1000#tAux: 1_1#price_x;
.stream_pair.price_y: 1000#tAux;
.stream_pair.spreads: 1000#tab3;

// Timer function
timer:{t:.z.p;while[.z.p<t+x&abs x-16*1e6]}    / 16 <- timer variable

.stream_pair.gen_pair:{
      // We wait some delta
      d: `float$(price_x[.stream_pair.i+:1][`delta]);
      // timer[d];
      // We take the i element from our tables
      res_x: enlist price_x[.stream_pair.i];
      res_y: enlist price_y[.stream_pair.i];

      // We calculate spreads for linear regression
      s: price_y[.stream_pair.i][`bid] - ((price_x[.stream_pair.i][`bid] * beta_lr)+alpha_lr);
      ewma: dev[ema[0.04; .stream_pair.iEWMA#0f^(exec spread from .stream_pair.spreads)]];
      $[.stream_pair.iEWMA>999;.stream_pair.iEWMA:998;.stream_pair.iEWMA+:1];
      res_spread: enlist `dt`spread`mean`up`low`ewma`up2`low2!("p"$(price_x[.stream_pair.i][`dt]);"f"$(s);"f"$(0);"f"$(1.96*std_lr);"f"$(-1.96*std_lr);"f"$0f^(ewma); "f"$(0f^(1.96*(last 1000 mdev (exec spread from .stream_pair.spreads)))); "f"$0f^(-1.96*(last 1000 mdev (exec spread from .stream_pair.spreads))));  
     
      // We update our buffer tables with those values
      .ring_buffer.write[`.stream_pair.price_x;res_x;.stream_pair.i];
      .ring_buffer.write[`.stream_pair.price_y;res_y;.stream_pair.i];
      .ring_buffer.write[`.stream_pair.spreads;res_spread;.stream_pair.i];
      res_x

 }

// Publish stream updates each milisecond
// .z.ts: {.stream_pair.gen_pair[]} 

// Snapshot read from our buffer
.u.snap:{[t] .ring_buffer.read[.stream_pair.price_x;.stream_pair.i]} // reqd. by dashboards

// \t 100
