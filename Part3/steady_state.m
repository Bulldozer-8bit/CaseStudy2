
%% ESE 105 Case Study II - Steady State Verification

clear;
clc;

D = make_deployment(7);

G = D.G;
P0 = D.P0;
faulty = D.faulty(:);
g = D.g;

n = size(G,1);
I = eye(n);
d = sum(G,2);
D_mat = diag(d);

W = (I + D_mat) \ (I + G);

% Demonstration: first 4 working robots
 isWorking = true(n,1);
 isWorking(faulty) = false;

 workingIndices = find(isWorking);
 m = min(4,numel(workingIndices));

 S = workingIndices(1:m);

% S = choose_leaders(G,P0,faulty,g,4);
% substitute by choose leader later

lambda = ones(n,1);

lambda(faulty) = 0;
lambda(S) = 0.5;

a = g(1)*ones(n,1);
b = g(2)*ones(n,1);

a(faulty) = P0(faulty,1);
b(faulty) = P0(faulty,2);

Lambda = diag(lambda);

A = I - Lambda*W;

rhsX = (I-Lambda)*a;
rhsY = (I-Lambda)*b;

xStar = A \ rhsX;
yStar = A \ rhsY;


K = 2000;

X = simulate_anchored(W,lambda,a,P0(:,1),K);
Y = simulate_anchored(W,lambda,b,P0(:,2),K);

xFinal = X(:,end);
yFinal = Y(:,end);



errorX = norm(xFinal-xStar,2);
errorY = norm(yFinal-yStar,2);
errorTotal = hypot(errorX,errorY);

residualX = norm(A*xStar-rhsX,2);
residualY = norm(A*yStar-rhsY,2);

%% Display results
fprintf('\n========== Steady-State Verification ==========\n');

fprintf('Number of robots: %d\n',n);
fprintf('Number of leaders: %d\n',numel(S));
fprintf('Number of faulty robots: %d\n',numel(faulty));
fprintf('Simulation iterations: %d\n',K);

fprintf('\nSimulation vs theoretical equilibrium:\n');
fprintf('X-coordinate error: %.12e\n',errorX);
fprintf('Y-coordinate error: %.12e\n',errorY);
fprintf('Combined error:     %.12e\n',errorTotal);

fprintf('\nLinear-system residuals:\n');
fprintf('X residual: %.12e\n',residualX);
fprintf('Y residual: %.12e\n',residualY);

tolerance = 1e-8;

if errorTotal < tolerance
    fprintf('\nPASS: Simulation matches theoretical equilibrium.\n');
else
    fprintf('\nDifference is larger than tolerance.\n');
    fprintf('Try increasing K or checking the model parameters.\n');
end
