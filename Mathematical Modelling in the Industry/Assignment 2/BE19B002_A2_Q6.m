clear
clc

x = linspace(-4, 4, 100);    % 100 Steps
t = linspace(0, 3, 100);     % 100 Steps 
[X,T] = meshgrid(x,t); %creating the meshgrid for x,t. This will be used to find the value and also plot the graph. 
y= zeros(length(t), length(x)); %the value array

#All the cases are defined below. 
case1a = (X <= 1) & (T <= 0.5);
case1b = (X > 1) & (X <= (1 + 4*T)) & (T <= 0.5);
case1c = (X > (1 + 4*T)) & (X <= 3) & (T <= 0.5);
case1d =  (X > 3) & (T <= 0.5);
case2a = (X <= 1) & (T > 0.5) & (T <= 2);
case2b = (X > 1) & (X <= (1 + 4*sqrt(2*T) - 4*T)) & (T > 0.5) & (T <= 2);
case2c = (X > (1 + 4*sqrt(2*T) - 4*T)) & (T > 0.5) & (T <= 2);
case3a = (X <= (5 - 2*T)) & (T > 2);
case3b = (X > (5 - 2*T)) & (T > 2);

%using the cases to calculate the outputs
y(case1a) = 1;
y(case1b) = 1 - (1/8)*((X(case1b) ./ T(case1b)) - (1 ./ T(case1b)));
y(case1c) = 0.5;
y(case1d) = 1.5;
y(case2a) = 1
y(case2b) = 1 - (1/8)*((X(case2b) ./ T(case2b)) - (1 ./ T(case2b)));
y(case2c) = 1.5;
y(case3a) = 1;
y(case3b) = 1.5;

%plotting the graphs
figure(1)
surf(x, t, y)