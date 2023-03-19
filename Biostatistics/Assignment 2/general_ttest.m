function out = general_ttest(x,y,alpha)
format long g;
out = struct('mean_x',0,'mean_y',0,'var_x',0,'var_y',0,'dof_x',0,'dof_y',0,'tot_dof',0,'F_cal',0,'var_r_l',0,'var_r_h',0,'diff_mn_l',0,'diff_mn_h',0,'sd',0,'tcal',0,'nh_F',0,'nh_t',0,'fpval',0,'pvalt',0);
out.mean_x = mean(x);
out.mean_y = mean(y);
out.var_x = var(x);
out.var_y = var(y);
out.dof_x = length(x) - 1;
out.dof_y = length(y) - 1;
out.F_cal = out.var_x/out.var_y;
left_F = finv(alpha/2,out.dof_x,out.dof_y);
right_F = finv(1-alpha/2,out.dof_x,out.dof_y);
out.nh_F=0;
if out.F_cal<left_F || out.F_cal > right_F
    out.nh_F = 1;
end
out.fpval = 2*(fcdf(out.F_cal,out.dof_x,out.dof_y)); %Problem of factor of 2
out.var_r_h = out.F_cal/left_F; out.var_r_l = out.F_cal/right_F;
nx = length(x); ny = length(y);
out.tot_dof = out.dof_x + out.dof_y;
if out.nh_F == 0
    out.sd = sqrt((1/nx + 1/ny)*((out.dof_x * out.var_x + out.dof_y * out.var_y)/(out.tot_dof)));
    out.tcal = (out.mean_x - out.mean_y)/out.sd;
    %Hypothesis for mean or ttest when variance of both population is equal
    left_t = tinv(alpha/2,out.tot_dof);
    right_t = tinv(1-alpha/2,out.tot_dof);
    
    out.nh_t = 0;
    if out.tcal < left_t || out.tcal > right_t
           out.nh_t = 1;
    end
    
    out.diff_mn_l = (out.mean_x - out.mean_y) - abs(tinv(alpha/2,out.tot_dof))*out.sd;
    out.diff_mn_h = (out.mean_x - out.mean_y) + abs(tinv(alpha/2,out.tot_dof))*out.sd;
else
    out.sd = sqrt( out.var_x/nx + out.var_y/ny );
    out.tcal = (out.mean_x - out.mean_y)/out.sd;
    sas = out.var_x/nx + out.var_y/ny;
    out.tot_dof = sas^2/((out.var_x/nx)^2/out.dof_x + (out.var_y/ny)^2/out.dof_y);
    %Hypothesis for mean or ttest when variance of populatons are not equal
    left_t = tinv(alpha/2,out.tot_dof);
    right_t = tinv(1 - alpha/2,out.tot_dof);
    
    out.nh_t = 0;
    if out.tcal < left_t || out.tcal > right_t
        out.nh_t = 1;
    end
    
    out.diff_mn_l = (out.mean_x - out.mean_y) - abs(left_t)*out.sd;
    out.diff_mn_h = (out.mean_x - out.mean_y) + abs(right_t)*out.sd;
end
out.tpval = 2*tcdf(-abs(out.tcal),(out.tot_dof));
end