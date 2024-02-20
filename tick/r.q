  1 if[not "w"=first string .z.o;system "sleep 1"];
  2
  3 upd:insert;
  4
  5 .u.x:.z.x,(count .z.x)_(":5010";":5012");
  6
  7 .u.end:{
  8   t:tables`.;
  9   t@:where `g=attr each t@\:`sym;
 10   .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
 11   @[;`sym;`g#] each t;};
 12
 13 .u.rep:{
 14   (.[;();:;].)each x;
 15   if[null first y;:()];
 16   -11!y;
 17   system "cd ",1_-10_string first reverse y };
 18
 19 .u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";