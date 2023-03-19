function out = mgeneral_ttest(x,y,alpha)
format long g;
out = struct('mean_x',0,'mean_y',0,'var_x',0,'var_y',0,'dof_x',0,'dof_y',0,'tot_dof',0,'F_cal',0,'var_r_l',0,'var_r_h',0,'diff_mn_l',0,'diff_mn_h',0,'sd',0,'tcal',0,'nh_F',0,'nh_t',0,'fpval',0,'pvalt',0);
out.mean_x = mean(x);
out.mean_y = mean(y);
out.var_x = var(x);
out.var_y = var(y);
out.dof_x = length(x) - 1;
out.dof_y = length(y) - 1;
[a, b, c, d] = vartest2(x,y,'Alpha',alpha);
out.nh_F = a;    out.fpval = b;
out.var_r_l = c(1); out.var_r_h = c(2);
out.F_cal = d.fstat;
if out.nh_F == 0
   [a, b, c, d] = ttest2(x,y,'Alpha',alpha,'Vartype','equal');
    out.nh_t = a;
    out.tpval = b;
    out.diff_mn_l = c(1);   out.diff_mn_h=c(2); out.tcal = d.tstat;
    out.tot_dof = d.df;
    out.sd = d.sd;
else
   [a, b, c, d] = ttest2(x,y,'Alpha',alpha,'Vartype','unequal');
    out.nh_t = a;
    out.tpval = b;
    out.diff_mn_l = c(1);   out.diff_mn_h=c(2); out.tcal = d.tstat;
    out.tot_dof = d.df;
    out.sd = d.sd;
end
end