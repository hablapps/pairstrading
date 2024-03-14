/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd]
/2008.09.09 .k ->.q
\l ../linear_regression.q

if[not "w"=first string .z.o;system "sleep 1"];

// It should use the gateway + hdb 
historial_tab1: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:data/SP500_hist.csv;
historial_tab2: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:data/NASDAQ100_hist.csv;

// Calculate alpha and beta from historical values
beta_lr: betaF[px:-100#log historial_tab1`close;py:-100#log historial_tab2`close];  
alpha_lr: alphaF[px;py];
// We calculate an historical standard deviation
std_lr: dev[(1000#exec bid from priceY) - (1000#exec bid from priceX)];

updPairs: {[t;d]
    // calculate spreads
    s: d[1][2] - ((d[0][2] * beta_lr)+alpha_lr);
    // Update table
    d: update spread: s, up: 1.96*std_lr, low: -1.96*std_lr from d;
    // insert on trade table
    `trade insert d;
}

upd:insert;

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5010";":5012");

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[`$":",.u.x 1;`:.;x;`sym];@[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;system "cd ",1_-10_string first reverse y};
/ HARDCODE \cd if other than logdir/db

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

