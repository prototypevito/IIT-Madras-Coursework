clear 
clc 

syms a1 a2 a3 a4 K n1 n2 n3 n4 b1 b2 b3 c1 c2 c4 d1 d2
assume([a1 a2 a3 a4 K n1 n2 n3 n4 b1 b2 b3 c1 c2 c4 d1 d2] >= 0);
eqn1 = a1*n1*(1 - n1/K) - b1*n1*n2 - b2*n1*n3;
eqn2 = c1*n1*n2 - a2*n2 + d1*n2*n4 - b3*n2*n3;
eqn3 = c2*n3*n1 + c4*n3*n2 - a3*n3;
eqn4 = d2*n2*n4 - a4*n4;
eqns = [eqn1==0 eqn2==0 eqn3==0 eqn4==0];
n = [n1 n2 n3 n4];
S = solve(eqns, n); % Solved expressions

eqbm = [];
for i = 1:length(S.n1)
    eqbm = [eqbm; [S.n1(i) S.n2(i) S.n3(i) S.n4(i)]];   % Storing all equilibrium points
end

eqn = [eqn1 eqn2 eqn3 eqn4];
A = sym(zeros(4,4,length(S.n1)));
for k = 1:length(S.n1)
    for i = 1:4
        for j = 1:4
            A(i,j,k) = subs(diff(eqn(i), n(j)), n, eqbm(k,:));
        end
    end
end

A(:,:,1)    % Third index corresponds to each equilibrium point
lambda = eig(A(:,:,1))