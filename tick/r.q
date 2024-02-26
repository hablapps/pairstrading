if[not "w"=first string .z.o;system "sleep 1"];
upd:insert;
  
.u.x:.z.x,(count .z.x)_(":5010";":5012");

.u.end:{
   t:tables`.;
   t@:where `g=attr each t@\:`sym;
   .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
   @[;`sym;`g#] each t;};
 
.u.rep:{
  (.[;();:;].)each x;
  if[null first y;:()];
  -11!y;
  system "cd ",1_-10_string first reverse y };

.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";