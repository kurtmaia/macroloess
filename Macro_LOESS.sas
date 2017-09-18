%macro LOESS(base, y, x, id, time, smooth=.6, out=Loess_Result);
proc iml;
sort &base by &id &time;
  use &base;
    Read All Var{&id} into id;
    Read All Var{&time} into time;
    Read All Var{&y} into y[rowname=Nome_Reduzido];
    Read All Var{&x} into x[colname=name1];
   close &base;
start loess(k,y,x,x_mean,id,time,h,cs0,ni0,ncs);
            di_mean=(((x_mean-repeat(x_mean[k,],nrow(x_mean),1))##2)*j(ncol(x_mean),1))##.5;
            di=((diag(di_mean)*cs0`)[+,])`||id||time||(1:nrow(x))`;
      xdi=x||di;
      ydi=y||di;
            call sort(xdi, ncol(x)+1);
            call sort(ydi, ncol(y)+1);
            i=1; j=1;
            x_=xdi[1,];
            do while(j <= Round(ncs*h));
            i=i+1;
              if xdi[i,ncol(x)+2]=xdi[i-1,ncol(x)+2] then j=j;
              if xdi[i,ncol(x)+2]^=xdi[i-1,ncol(x)+2] then j=j+1;
              x_=x_//xdi[i,];
            end;
      x_=x_[1:(nrow(x_)-1),]; 
      w=(32/5)#(1-(x_[, ncol(x)+1]/max(x_[, ncol(x)+1]))##3)##3;
   	  cs1=design(x_[,ncol(x)+2]);
	    ni=vecdiag(cs1`*cs1);
	    x_=x_[(1:nrow(x_)-ni[nrow(ni)]),];
	      w_=w[1:nrow(x_)]||x_[,ncol(x)+2];
		  y_=ydi[1:nrow(x_),1]||x_[,ncol(x)+4];
		 call sort(w_,ncol(w)+1); 
		 call sort(y_,ncol(y)+1); 
	     call sort(x_,ncol(x)+4); 
		   w1=diag(w_[1:nrow(x_),1]);
           x1=x_[,1:ncol(x)]; 
	do s=1 to nrow(x_);
      if x_[s,ncol(x)+2]=k then nrow_sup=s;
      end; 
	  nrow_inf=nrow_sup-(ni0[k]-1);

		start otimized(y,x,id,time,w, inf, sup, nik);
		 w=sqrt(w);
		 ts=design(time); 
		 cs=design(id);
		nomes={Intercept name1}`;
		NN=ncol(cs);
		TT=ncol(ts);
		NT=NN*TT;
		_TOTAL_=nrow(y);
		nvar2=ncol(x);
		x=x||ts[,1:ncol(ts)-1];
		nvar=ncol(x);
		ni=cs`*cs;
		_freq_=vecdiag(ni);
		b1=j(nvar,nvar,0);
		b2=j(nvar,1,0);
		l2=0;
		do i=1 to NN;
			if NT ^= _TOTAL_ 	then _dim_=_freq_[i];
								else _dim_=_freq_[1];
				if _dim_ ^= 0 then do;
					e=j(_dim_,_dim_,1/_dim_);
					l1=l2+1;
					l2=l1+_dim_-1;
				    Qe=w[l1:l2,l1:l2]*(I(_dim_)-e)*w[l1:l2,l1:l2]; 
						b1=b1+x[l1:l2,]`*Qe*x[l1:l2,];
						b2=b2+x[l1:l2,]`*Qe*y[l1:l2];
				end;
		end;
	     b=inv(b1)*b2; 
		 _freq_inv=inv(diag(_freq_));
		 yp_cs=(x`*cs*_freq_inv)`*b;
		 ycs=(y`*cs*_freq_inv)`; 
		 bcs=ycs-yp_cs;
		 b0=bcs[nrow(bcs)];
		 bcs1=bcs[1:nrow(bcs)-1];
		 beta1=bcs1-b0;
		 beta=b0//b//beta1;
		 ypred=(j(nrow(x),1)||x||cs[,1:ncol(cs)-1])*beta;
         return(ypred[inf:sup]||repeat(beta[1:nvar2+1]`,nik,1));
		 finish otimized; 
 yp=otimized(y_[,1],x1,x_[,7],x_[,8],w1,nrow_inf, nrow_sup,ni0[k]);
 result=x_[nrow_inf:nrow_sup,ncol(x)+3]||yp;
 return(result);
 finish;

idf=id;
cs0=design(id);
ncs=ncol(unique(id));
id=(1:ncs)`;
id=((diag(id)*cs0`)[+,])`;
ni0=vecdiag(cs0`*cs0);
      x_mean=(x`*cs0)`;
       x_mean=j(nrow(x_mean),1)||(x`*cs0)`;
h=&smooth; 
Ly=Loess(1,y,x,x_mean,id,time,h,cs0,ni0,ncs);
do i=2 to ncs;
 temp=loess(i,y,x,x_mean,id,time,h,cs0,ni0,ncs);
 Ly=Ly//temp;
end;
Ly=idf||Ly;
name1=Concat("Beta_", name1);
name={"&id" "&time" "Valor_Predito" "Intercepto"}|| name1;
create &out from Ly[colname=name rowname=nome_reduzido];
append from Ly[rowname=nome_reduzido];
quit;
%mend;

%loess(c,lnr,lnw1 lnw2 lnw3 lnea lnla, cnpj, time, smooth=.6, out=loess);


%macro LOESS_PANEL(base, y, x, id, time, smooth=.6, out=Loess_Result);
proc iml;
sort &base by &id &time;
  use &base;
    Read All Var{&id} into id;
    Read All Var{&time} into time;
    Read All Var{&y} into y[rowname=Nome_Reduzido];
    Read All Var{&x} into x[colname=name1];
   close &base;
idf=id;
x=j(nrow(x),1)||x; 
start loess(k,y,x,id,time,h);
cs0=design(id);
id=(1:ncol(unique(id)))`;
id=((diag(id)*cs0`)[+,])`;
ni0=vecdiag(cs0`*cs0);
ncs=ncol(cs0);
      x_mean=(x`*cs0)`;
       x_mean=j(nrow(x_mean),1)||(x`*cs0)`;
            di_mean=(((x_mean-repeat(x_mean[k,],nrow(x_mean),1))##2)*j(ncol(x_mean),1))##.5;
            di=((diag(di_mean)*cs0`)[+,])`||id||time||(1:nrow(x))`;
      xdi=x||di;
      ydi=y||di;
            call sort(xdi, ncol(x)+1);
            call sort(ydi, ncol(y)+1);
            i=1; j=1;
            x_=xdi[1,];
			do while(j <= Round(ncs*h));
            i=i+1;
              if xdi[i,ncol(x)+2]=xdi[i-1,ncol(x)+2] then j=j;
              if xdi[i,ncol(x)+2]^=xdi[i-1,ncol(x)+2] then j=j+1;
              x_=x_//xdi[i,];
            end;
		x_=x_[1:(nrow(x_)-1),];  
      w=(32/5)#(1-(x_[, ncol(x)+1]/max(x_[, ncol(x)+1]))##3)##3;
	  cs1=design(x_[,ncol(x)+2]);
	    ni=vecdiag(cs1`*cs1);
	  x_=x_[(1:nrow(x_)-ni[nrow(ni)]),];
	     w_=w[1:nrow(x_)]||x_[,ncol(x)+4];
		 y_=ydi[1:nrow(x_),1]||x_[,ncol(x)+4];
		 call sort(w_,ncol(w)+1); 
		 call sort(y_,ncol(y)+1); 
	     call sort(x_,ncol(x)+4);   
	       cs=design(x_[,ncol(x)+2]);
           ts=design(x_[,ncol(x)+3]);
		   w1=diag(w_[1:nrow(x_),1]);
	       x1=x_[,1:ncol(x)]; 
		   x1=x1||cs[,1:(ncol(cs)-1)]||ts[,1:(ncol(ts)-1)];
		   beta=inv(x1`*w1*x1)*x1`*w1*y_[,1];
      ypred=x1*beta;
      do s=1 to nrow(x_);
      if x_[s,ncol(x)+2]=k then nrow_sup=s;
      end; 
	  nrow_inf=nrow_sup-(ni0[k]-1);
	  result=x_[nrow_inf:nrow_sup,ncol(x)+3]||ypred[nrow_inf:nrow_sup]||repeat(beta[1:ncol(x)]`,ni0[k],1);
	 return(result); 
finish;	
ncs=ncol(design(id));
h=&smooth;
Ly=Loess(1,y,x,id,time,h);
do i=2 to ncs;
 temp=loess(i,y,x,id,time,h);
 Ly=Ly//temp;
end;
 Ly=idf||Ly;
name1=Concat("Beta_", name1);
name={"&id" "&time" "Valor_Predito" "Intercepto"}|| name1;
create &out from Ly[colname=name rowname=nome_reduzido];
append from Ly[rowname=nome_reduzido];
quit;
%mend;

%loess_panel(c,lnr,lnw1 lnw2 lnw3 lnea lnla, cnpj, time, smooth=.6);