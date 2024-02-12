// Alpha and beta functions
betaF:{dot:{sum x*y};                                      
      ((n*dot[x;y])-(*/)(sum')(x;y))%                         
      ((n:count[x])*dot[x;x])-sum[x]xexp 2};
      
alphaF: {avg[y]-(betaF[x;y]*avg[x])};