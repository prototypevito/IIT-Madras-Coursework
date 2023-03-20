clear 
clc

x=linspace(-4,4,100) %two arrays with equally spaced elements, 100 steps 
t=linspace(0,3,100) 
[X,T]=meshgrid(x,t)%creating a meshgrid to be used for the plotting of the graph
Y=zeros(length(t),length(t))

%Defining the three cases to be used, as mentioned in the assignment question.
case1= (-T<X) & (X<=T);
case2= X<= -T;
case3= X>T;

%The output for the the three functions
Y(case1)=(0.5) * (1 - (X(case1) ./ T(case1)));
Y(case2)=1;
Y(case3)=0;

%plotting the figure
figure(1)
surf(x,t,Y)




