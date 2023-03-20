clc
%V=100 (km/hr)=1/36 (km/s)
%maxdensity=40cars/km
%L=0.006km
%d=19m
%N=5 (number of cars)
%ts=1second
%k=0.2,0.1, this code I have used the value of k to be 0.2
rt=0.5; %reaction time=0.5 in this code. Other values given are: 1 and 2
K=100; %h/k is the time step which will be used instead of h
h=1; %this is the step size for euler's method
n = 10000; %the number of time steps we want to iterate the Euler Method for
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

  Z2(p+i+1)=Z2(p+i) + (1/K)*(1/36)*log(1+(40/exp(1))*(Z1(i-p)-Z2(i)));
end

tf1=linspace(0,n+p,n+p+1);
d=0.019*ones(size(t));
plot(tf1,Z2-d)

hold on

%We run the Euler loop again to get a matrix for Z3. We also plot the graph for Z3
for j=1:n
    Z3(p+j+1) =Z3(p+j) + (1/K)*(1/36)*log(1+(40/exp(1))*(Z2(j)-Z3(j)));
end

plot(tf1,Z3-2*d)

%We run the Euler loop again to get a matrix for Z4, and plot the graph for Z4
for i=1:n
    Z4(p+i+1) =Z4(p+i) + (1/K)*(1/36)*log(1+(40/exp(1))*(Z3(i)-Z4(i))) ;
end
plot(tf1,Z4-3*d)

%We run the Euler loop again to get a matrix for Z5, and plot the graph for Z5
for i=1:n
    Z5(p+i+1) =Z5(p+i) + (1/K)*(1/36)*log(1+(40/exp(1))*(Z4(i)-Z5(i))) ;
end
plot(tf1,Z5-4*d)
hold off

%This is the function for Z1 as given in the problem statement. When t>0, Z1(t)=-vB(t), where B(t) is the integration of b(s)ds. 
function z = funcZ1(n)
    K = 100;
    if n < 0
        z = 0;
    else 
        z = -(15.1/2000)*(1-((n/K)+1)*exp(-n/K));  
    end
end

#The plots have been saved using the following format:
#Euler indicates that the method used is Euler's 
#Euler1 indicates the value of k, 1 is for k=0.2, 2 is for k=0.1
#Euler1_1 indicates the reaction time, 1 is for 0.5s,2 is for 1s, 3 is for 2s