function yk = expy(a,b,c,d,h,delx,maxx)
   format longg;
   xt = 0.0;
   yt = -0.0053434; 
%    yt = -0.053434;
   yk = zeros(ceil(maxx/0.1),1);
   i=1;
   while xt<=maxx
%        if mod(xt,0.1) == 0
       yk(i,1) = yt;
%        end
%        yt = yt + delx*((-1)*(a*(cos(h*xt*yt))) + ((-1)*b*xt*yt^2) + ((-1)*(c*(cos(xt*yt^3)))) + (d*cos(xt)));
       yt = yt + delx*((-1)*(a*(sin(h*xt*yt))) + ((-1)*b*cos(xt*(yt^2))) + ((-1)*(c*(sin(xt*(yt^3))))) + (d*sin(xt^2)));
       xt = xt + delx;
       i=i+1;
   end
end