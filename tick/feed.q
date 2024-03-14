// / Read data
tab1: update sym:`SP500 from 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USA500IDXUSD.csv;
tab2: update sym:`NASDAQ100 from 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USATECHIDXUSD.csv;
tradesSP: 0!1_(update delta:0f^deltas dateTime from 
             distinct select "n"$dateTime,sym, log bid, log ask from 
                update dateTime:"P"$@[;19;:;"."] each dateTime from 
                `dateTime xasc tab1);

tradesNYS: 0!1_(update delta:0f^deltas dateTime from 
             distinct select "n"$dateTime,sym, log bid, log ask from 
                update dateTime:"P"$@[;19;:;"."] each dateTime from 
                `dateTime xasc tab2);                

.tick.i:-1
timer:{t:.z.p;while[.z.p<t+x&abs x-16*1e6]}    / 16 <- timer variable
h:neg hopen `::5010
// / send tables

.z.ts:{
    i+:1;
    dataSP:value tradesSP i;
    dataNYS:value tradesNYS i;
    timer[last dataSP];
    h(".u.upd";`trade;-1_dataSP,'dataNYS)}

\t 16