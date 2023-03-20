clear
clc 

% Initialising variables
x = linspace(-4, 4, 100); %100 steps    
t = linspace(0, 3, 100); %100 steps

j = @(rho) rho - rho.^2;   % Defining flux j(rho)
j_dash = @(rho) 1 - 2 * rho;  % Defining j'(rho)
RHO= zeros(length(x), length(t)); %initializing the density variable

k = t(2) - t(1);    % step size for time
h = x(2) - x(1);    %step size for the space
nt = 100;    % Total number of time steps
nx = 100;    % Total number of space steps

% Initial conditions for the Density
RHO(:,1) = 1 * (x <= 0);  % Density at t=0

% Boundary conditions for the density
RHO(1,:) = 1 ;
RHO(100,:) = 0 ;

% Implementing the numerical method: Green light problem using the upwind method
for idt = 1 : nt - 1
    for idx = 2 : nx - 1
            RHO(idx, idt + 1) = 0.5 * (RHO(idx - 1, idt) + RHO(idx + 1, idt)) - 0.5 * (k / h) * (j(RHO(idx + 1, idt)) - j(RHO(idx - 1, idt)));     
    end
end
% Plotting the density function
figure(1)
surf(t,x,RHO)
xlabel('t', 'FontSize', 20)
ylabel('x', 'FontSize', 20)
zlabel('rho(x,t)', 'FontSize', 20)
colorbar
title('Green Light Problem using the Lax-Friedrichs method', 'FontSize', 15)
set(gca, 'XDir','reverse')