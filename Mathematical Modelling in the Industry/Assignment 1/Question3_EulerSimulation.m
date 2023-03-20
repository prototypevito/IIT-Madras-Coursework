clc
%This simulation is done using the function and variables from the previous question. I have assumed the value of critical density to be 20 whereas the maximum density to be 40cars/km. The differential equation used is taken from the Handwritten submission. 
%V=100 (km/hr)=1/36 (km/s)
%L=0.006km
%d=0.019km
%maxdensity=1/L=1/0.006=166.67 cars/km
%critical density=1/(d+l)=1/(0.006+0.019)=40cars/km
%N=5 (number of cars)
%ts=1second
%k=0.2
dmax=40;
dcri=20; %Assume the critical density to be 20 cars/kms
rt=0.5; %reaction time=0.5 
K=200; %h/k is the time step which will be used instead of h
h=1; %this is the step size for euler's method
n =8000; %the number of time steps we want to iterate the Euler Method for
p =K*rt; %reaction time in terms of time steps taken
t = 0:h:n+p;  % the range of x
% Now we will initiate four arrays, for the respective displacements of the four cars behind the trailing car. These arrays will store the value of displacement after every iteration (time step)
Z2 = zeros(size(t)); 
Z3 = zeros(size(t)); 
Z4 = zeros(size(t));
Z5 = zeros(size(t));

%Since we know Z1, and it is given by the function given below, we will call the function to get Z1
Z1 = @funcZ1; 

%We will now execute the Euler loop for Z2 which will solve the differential equation
for i=1:n
  Z2(p+i+1)=Z2(p+i) + (1/K)*(1/36)*((dcri^2*dmax^2/(dmax^2-dcri^2))*((Z1(i-p)-Z2(i)+(1/dcri))^2-(1/(dmax)^2))-1);
end

tf1=linspace(0,n+p,n+p+1);
d=0.019*ones(size(t));
plot(tf1,Z2-d)

hold on

%We run the Euler loop again to get a matrix for Z3. We also plot the graph for Z3
for i=1:n
   Z3(p+i+1)=Z3(p+i) + (1/K)*(1/36)*((dcri^2*dmax^2/(dmax^2-dcri^2))*((Z2(i)-Z3(i)+(1/dcri))^2-(1/(dmax)^2))-1);
end

plot(tf1,Z3-2*d)

%We run the Euler loop again to get a matrix for Z4, and plot the graph for Z4
for i=1:n
   Z4(p+i+1)=Z4(p+i) + (1/K)*(1/36)*((dcri^2*dmax^2/(dmax^2-dcri^2))*((Z3(i)-Z4(i)+(1/dcri))^2-(1/(dmax)^2))-1);
end
plot(tf1,Z4-3*d)

%We run the Euler loop again to get a matrix for Z5, and plot the graph for Z5
for i=1:n
   Z5(p+i+1)=Z5(p+i) + (1/K)*(1/36)*((dcri^2*dmax^2/(dmax^2-dcri^2))*((Z4(i)-Z5(i)+(1/dcri))^2-(1/(dmax)^2))-1);
end
plot(tf1,Z5-4*d)
hold off

%This is the function for Z1 as given in the problem statement. When t>0, Z1(t)=-vB(t), where B(t) is the integration of b(s)ds. 
function z = funcZ1(n)
    K = 100;
    if n < 0
        z = 0;
    else 
        z = -(15.1/1000)*(1-((n/K)+1)*exp(-n/K));  
    end
end