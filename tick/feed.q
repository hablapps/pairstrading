// / Read data
// tab1: 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USA500IDXUSD.csv;
// tab2: 1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",") 0: `:data/USATECHIDXUSD.csv;

// / fix 
// update from tab1,tab2

// i:-1`
// h:neg hopen `:5010
// / send tables
// .z.ts{
//     i+:1
//     spdata:value flip tab1[i];
//     nasddata:value flip tab2[i];
//     timer[spdata`delta]
//     h(".u.upd";`trade;(spdata;nasddata),'(`SP500`NASDAQ))
// }

// (.z.p .z.p;`SP500`NASDAQ;priceSP priceND;closeSP closeND)