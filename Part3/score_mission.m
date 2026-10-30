function J = score_mission(D, S) % form make_deployment.m, including G, P0, faulty, r, g, seed

working_robots = setdiff(1:size(D.PO, 1), D.faulty);
working_S = intersect(S, working_robots);

if length(working_S) > D.m
    error('Assigned too many working robots as leaders. Max budget is %d.', D.m);
end

n = size(D.PO, 1);
T = 125; 

d = D.G * ones(n, 1); 
D_mat = diag(d);
W_A = (eye(n) + D_mat) \ (eye(n) + D.G); 

lambda_base = ones(n, 1);
lambda_base(D.faulty) = 0; % not listening to the network

a_base = zeros(n, 1);
a_base(D.faulty) = D.PO(D.faulty, 1); 
b_base = zeros(n, 1);
b_base(D.faulty) = D.PO(D.faulty, 2);

X_base = simulate_anchored(W_A, lambda_base, a_base, D.PO(:, 1), T);
Y_base = simulate_anchored(W_A, lambda_base, b_base, D.PO(:, 2), T);


lambda_new = lambda_base;
lambda_new(S) = 0.5; 
lambda_new(D.faulty) = 0; 

a_new = a_base;
a_new(S) = D.g(1); 
a_new(D.faulty) = D.PO(D.faulty, 1);

b_new = b_base;
b_new(S) = D.g(2);
b_new(D.faulty) = D.PO(D.faulty, 2);

X_new = simulate_anchored(W_A, lambda_new, a_new, D.PO(:, 1), T);
Y_new = simulate_anchored(W_A, lambda_new, b_new, D.PO(:, 2), T);


J_sum = 0;

for k = 2:(T + 1) 

    dist2_base = (X_base(working_robots, k) - D.g(1)).^2 + (Y_base(working_robots, k) - D.g(2)).^2;
    e_base = mean(dist2_base);

    dist2_new = (X_new(working_robots, k) - D.g(1)).^2 + (Y_new(working_robots, k) - D.g(2)).^2;
    e_new = mean(dist2_new);

    if e_base > 0
        J_sum = J_sum + (1 - e_new / e_base);
    end
end

J = (100 / T) * J_sum;
end