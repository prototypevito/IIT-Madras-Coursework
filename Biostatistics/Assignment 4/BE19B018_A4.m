clf; clc; close all;
num = xlsread("data4.xlsx");
y_actual = num(:,2);
x_data = num(:,1);
a = 1.0;
b = -1.7;
c = 0.5;
d = 1.0;
h = 0.2; 
lambda = 50;
lambda_l = 1e-3;
lambda_h = 1e+8;
lambda_s = lambda;
tune_p = 2;
nite = 10000;
pas = zeros(nite,5);
tol = 1e-12;
param(1,1) = a;
param(2,1) = b;
param(3,1) = c;
param(4,1) = d;
param(5,1) = h;
delp = 1e-6;
out = struct('alpha',0,'params',0,'total_iterations',0,'nparam',0,'SST',0,'SSR',0,'SSE',0,'R_square',0, 'SE_params',0,'covmat',0, 'final_lambda',0, 'MSE',0, 'R_square_adjusted',0, 'fcal',0, 'reg_DOF',0, 'fpvalue',0, 'errDOF',0, 'H0_f',0, 'tstat',0, 'tpvalues',0, 'H0_params',0, 'RMSE',0,'totDOF',0, 'paramerror',0, 'stderror',0);
out.nparam = 5;
delx = 0.1;
delp = 1e-6;
initx = 0.0;
inity = 0.0;
maxx = 10.0;
stat =1;
alpha1 = 0.02563;
out.alpha = alpha1;
dof = 101-1-1;
out.totDOF = dof;
out.reg_DOF = 1;
out.errDOF = dof;

diffa = @(a,b,c,d,h,delx,maxx,delp) ((expy(a+delp,b,c,d,h,delx,maxx) - expy(a,b,c,d,h,delx,maxx))/delp);
diffb = @(a,b,c,d,h,delx,maxx,delp) ((expy(a,b+delp,c,d,h,delx,maxx) - expy(a,b,c,d,h,delx,maxx))/delp);
diffc = @(a,b,c,d,h,delx,maxx,delp) ((expy(a,b,c+delp,d,h,delx,maxx) - expy(a,b,c,d,h,delx,maxx))/delp);
diffd = @(a,b,c,d,h,delx,maxx,delp) ((expy(a,b,c,d+delp,h,delx,maxx) - expy(a,b,c,d,h,delx,maxx))/delp);
diffh = @(a,b,c,d,h,delx,maxx,delp) ((expy(a,b,c,d,h+delp,delx,maxx) - expy(a,b,c,d,h,delx,maxx))/delp);

plot(x_data,y_actual,'o', 'LineWidth',2); hold on;

for w=1:nite
    if stat == 1
        jmat = [diffa(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx,delp) diffb(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx,delp) diffc(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx,delp) diffd(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx,delp) diffh(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx,delp)];
        jtjm = jmat'*jmat;
        dy = y_actual - expy(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx);
%       dy(:,1) = y_actual - expy(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx) ;
        if lambda_s ~=0
            if w == 1, chia = sum(dy.^2); end
        else
            chia = sum(dy.^2);
        end
    end
    pas(w,:) = param(:,1);
    if lambda_s ~=0
        for i=1:length(jtjm), jtjm(i,i) = jtjm(i,i) + jtjm(i,i)*lambda; end
    else
        for i=1:length(jtjm), jtjm(i,i) = jtjm(i,i) + 0; end
    end
    
    ijtjm = jtjm^-1;
    dyn = y_actual - expy(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx);
    nparam = param + ijtjm * jmat'*dyn;
    dym = y_actual - expy(nparam(1,1),nparam(2,1),nparam(3,1),nparam(4,1),nparam(5,1),delx,maxx);
    chib = sum(dym.^2);
    if((abs(chia-chib)<tol) || w == nite)
        param = nparam;
        SSE = chib; SST = sum(y_actual.^2) - (sum(y_actual))^2/length(y_actual);
        SSEr = SSE/dof; RMSE = sqrt(SSEr);
        SSTr = SST/100;
        rsquare = 1 - SSE/SST;
        rsqadjust = 1 - (100/dof)*(1-rsquare);
        cov_mat = ijtjm * SSEr;
        param_err = zeros(5,2);
        param_err(:,1) = param - abs(tinv(alpha1/2,dof)) * sqrt(diag(cov_mat));
        param_err(:,2) = param + abs(tinv(alpha1/2,dof)) * sqrt(diag(cov_mat));
        out.paramerror = (abs(tinv(alpha1/2,dof))*sqrt(diag(cov_mat)));
        out.SE_params = param_err;
        disp(['param (a,b,c,d,h), ' 'param_low, ' 'param_high']);
        disp([param param_err]);
        disp(['Total iterations, ' 'SSE, ' 'RMSE, ' 'rsquare, ' 'rsqadjusted, ' 'lambda ']);
        disp([w SSE RMSE rsquare rsqadjust lambda]);
        out.params = param;
        out.stderror = sqrt(diag(cov_mat));
        out.SSE = SSE; out.SST = SST; out.covmat = cov_mat;
        out.SSR = out.SST - out.SSE;
%         out.SSRr = out.SSR/
        out.final_lambda = lambda;
        out.R_square = rsquare;
        out.MSE = SSEr;
        out.R_squate_adjusted = rsqadjust;
        out.fcal = (out.SSR*99)/(SSE);
        out.fpvalue = fpval(out.fcal,out.reg_DOF,out.errDOF);
        if out.fpvalue < alpha1
            out.H0_f = 1;
        else
            out.H0_f = 0;
        end
        out.tstat = param.*sqrt(diag(cov_mat)).^-1;
        out.tpvalues = zeros(length(out.tstat),1);
        for q=1:length(out.tstat)
            out.tpvalues(q) = tpval(out.tstat(q),out.errDOF);
            if out.tpvalues < alpha1
                out.H0_params(q) = 1;
            end
        end
        out.RMSE = RMSE;
        break  
    end
    
    if lambda_s ~=0
        if chib < chia
            if lambda/tune_p >=lambda_l lambda = lambda/tune_p; end
            param = nparam;
            chia = chib;
            stat = 1;
        else
            if lambda*tune_p <=lambda_h lambda = lambda*tune_p; end
            stat = 0;
        end
    else
        param = nparam;
    end
            
end
disp(out);

y_cal = expy(param(1,1),param(2,1),param(3,1),param(4,1),param(5,1),delx,maxx);
plot(x_data, y_cal,'LineWidth',2); hold off;
xlabel('X'); ylabel('Y = f(x)');
legend('data','NLS Fit');
gx = gca;
gx.LineWidth = 2;
gx.FontSize = 20;
% pasb = pas(1:w,:);


function pval = fpval(f, adof, bdof)
    if f < 1
       pval = fcdf(f,adof,bdof);
    else
        pval = fcdf(1/f,bdof,adof);
    end
end

function rpval = tpval(t, v)
rpval = betainc(v/(v+t^2),v/2,0.5);
end
