# LOESS and LOESS_PANEL
Local regression for market power estimation in SAS for cross-sectional and panel data. 

## How to use?
``` 
%loess(c,lnr,lnw1 lnw2 lnw3 lnea lnla, cnpj, time, smooth=.6, out=loess);

%loess_panel(c,lnr,lnw1 lnw2 lnw3 lnea lnla, cnpj, time, smooth=.6);
```
where

`c` is the dataset

`lnr` is the log transform of the total revenue

`lnw1 lnw2 lnw3` are the log transform input prices

`lnea lnla` represents the log bank-specific characteristics

`cnpj` and `time` are ID and time variables respectively 

## Reference
Tabak, B. M. ; Gomes, G. M.; Júnior, M. S. The impact of market power at bank level in risk-taking: The Brazilian case. International Review of Financial Analysis, Volume 40. [(PDF)](http://sbfin.org.br/artigos-aceitos-15sbfin/econometria/5092.pdf)
