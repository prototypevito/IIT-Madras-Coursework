% Initialising variables
x = linspace(-4, 4, 41);    
t = linspace(0, 3, 151);
k = t(2) - t(1);    % step size for the time
h = x(2) - x(1);    % step size for the space
nt = 151;   % Total number of time steps
nx = 41;    % Total number of space steps
j = @(rho) 8 * rho - 4 * rho.^2;
j_dash = @(rho) 8 - 8 * rho;
RHO = zeros(length(x), length(t));

% Initial conditions
RHO(:, 1) = 1 * (x <= 1) + 0.5 * ((x > 1) & (x <= 3)) + 1.5 * (x > 3);
% Boundary conditions
RHO(1, :) = 1;
RHO(41, :) = 1.5;

% Implementing the numerical method
for idt = 1 : nt - 1
    for idx = 2 : nx - 1
        RHO_star1 = RHO(idx - 1, idt) - (k / h) * (j(RHO(idx, idt)) - j(RHO(idx - 1, idt)));
        RHO_star2 = RHO(idx, idt) - (k / h) * (j(RHO(idx + 1, idt)) - j(RHO(idx, idt)));
        RHO(idx, idt + 1) = 0.5 * (RHO(idx, idt) + RHO_star2) - (k / h) * (j(RHO_star2) - j(RHO_star1));
    end
end

% Plotting the density function
figure(1)
surf(t,x,RHO)
xlabel('t','FontSize', 20)
ylabel('x','FontSize', 20)
zlabel('rho(x,t)','FontSize', 20)
title('Intersecting Characteristics using Mac-Cornack method', 'FontSize', 10)
colorbar
set(gca, 'XDir','reverse')