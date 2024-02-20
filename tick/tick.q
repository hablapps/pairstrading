  1 system"l tick/",(src:first .z.x,enlist"sym"),".q"
  2
  3 if[not system"p";system"p 5010"]
  4
  5 \l tick/u.q
  6 \d .u
  7 ld:{
  8   if[not type key L::`$(-10_string L),string x;.[L;();:;()]];i::j::-11!(-2;L);if[0<=type i;-2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";    exit 1];hopen L};
  9
 10 tick:{
 11   init[];
 12   if[not min(`time`sym~2#key flip value@)each t;'`timesym];
 13   @[;`sym;`g#]each t;
 14   d::.z.D;
 15   if[l::count y;L::`$":",y,"/",x,10#".";l::ld d]};
 16
 17 endofday:{
 18   end d;
 19   d+:1;
 20   if[l;hclose l;l::0(`.u.ld;d)]};
 21
 22 ts:{
 23   if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};
 24
 25 if[system"t";
 26   .z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
 27   upd:{[t;x]
 28   if[not -16=type first first x;if[d<"d"$a:.z.P;.z.ts[]];a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 29   t insert x;if[l;l enlist (`upd;t;x);j+:1];}];
 30
 31 if[not system"t";system"t 1000";
 32   .z.ts:{ts .z.D};
 33   upd:{[t;x]ts"d"$a:.z.P;
 34   if[not -16=type first first x;a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 35   f:key flip value t;
 36   pub[t;$[0>type first x;enlist f!x;flip f!x]];if[l;l enlist (`upd;t;x);i+:1];}];
 37
 38 \d .
 39
 40 .u.tick[src;.z.x 1];