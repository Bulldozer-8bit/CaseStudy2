% This is Part two codes
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'Part1'));
n = 100;
% Load the deployment parameters calculated in Part 1
load('deployment_parameters.mat', 'P0', 'r_min', 'k');
disp(r_min);
disp(k);
disp(size(P0));
K = 4500;
x0 = P0(:,1);
y0 = P0(:,2);

%% Generate four networks and the larger-radius T4
G1 = make_complete(n);
G2 = make_star(n);
G3 = make_ring(n, k);
G4 = make_disk(P0, r_min);
G4_larger = make_disk(P0, r_min + 0.4);
G_list = {G1, G2, G3, G4, G4_larger};
networkNames = {
    'T1 Complete'
    'T2 Star'
    'T3 Ring'
    'T4 Disk: r_min'
    'T4 Disk: r_min+0.4'
};
I = eye(n);
C = I - (1/n)*ones(n);

deltaA_all = zeros(5, K+1);
timeA_all = NaN(5,1);

deltaB_all = zeros(5, K+1);
timeB_all = NaN(5,1);

delta0 = sqrt(norm(C*x0)^2 + norm(C*y0)^2);
threshold = 0.01 * delta0;
theoryA = zeros(5,2); 
theoryB = zeros(5,2);
simA = zeros(5,2);    
simB = zeros(5,2);
errorA = zeros(5,1);
errorB = zeros(5,1);
XA_G4 = []; 
YA_G4 = []; 
XB_G4 = []; 
YB_G4 = [];

figure; 
hold on;
for i = 1:5 % for different networks
    G = G_list{i};
    d = sum(G, 2);
    D = diag(d);
    L = D - G;
    
    WA = (I + D) \ (I + G);
    epsilon = 1 / max(d);  
    WB = I - epsilon * L;
    
    XA = simulate_linear(WA, x0, K);
    YA = simulate_linear(WA, y0, K);
    XB = simulate_linear(WB, x0, K);
    YB = simulate_linear(WB, y0, K);
    
    if i == 4 % save G4 for plotting later
        XA_G4 = XA;
        YA_G4 = YA;
        XB_G4 = XB;
        YB_G4 = YB;
    end
    
    %% E1 calculation (both protocol A and B)
    for j = 1:K+1
        deltaA_all(i,j) = sqrt(norm(C*XA(:,j))^2 + norm(C*YA(:,j))^2);
        deltaB_all(i,j) = sqrt(norm(C*XB(:,j))^2 + norm(C*YB(:,j))^2); % 计算 B 的 spread
    end
    
    % Protocol A convergent time
    idxA = find(deltaA_all(i,:) <= threshold, 1, 'first');
    if ~isempty(idxA)
        timeA_all(i) = idxA - 1; 
    end
    
    % Protocol B convergent time
    idxB = find(deltaB_all(i,:) <= threshold, 1, 'first');
    if ~isempty(idxB)
        timeB_all(i) = idxB - 1; 
    end
    
    semilogy(0:K, max(deltaA_all(i,:), 1e-15), 'LineWidth', 1.5);
    % semilogy means log scale
    % 1e-15 is the accuracy of matlab, so value below this is inaccurate
   
    %% E2 calculation
    weights = 1 + d;
    theoryA(i,1) = sum(weights .* x0) / sum(weights);
    theoryA(i,2) = sum(weights .* y0) / sum(weights);
    theoryB(i,1) = mean(x0);
    theoryB(i,2) = mean(y0);
    
    % all robots' average final positions
    simA(i,1) = mean(XA(:,end)); 
    simA(i,2) = mean(YA(:,end));
    simB(i,1) = mean(XB(:,end));
    simB(i,2) = mean(YB(:,end));
    
    errorA(i) = max(sqrt((XA(:,end) - theoryA(i,1)).^2 + (YA(:,end) - theoryA(i,2)).^2));
    errorB(i) = max(sqrt((XB(:,end) - theoryB(i,1)).^2 + (YB(:,end) - theoryB(i,2)).^2));
end

%% E1 plotting (Only for Protocol A)
yline(threshold, '--k', '1% threshold');
xlabel('Iteration k'); ylabel('Spread \delta[k]');
title('E1: Protocol A Convergence');
legend(networkNames, 'Location', 'best'); grid on; hold off;

%% E1 printing 
fprintf('\nE1: Protocol A rendezvous times\n');
for i = 1:5
    if isnan(timeA_all(i))
        fprintf('%s: Not reached\n', networkNames{i});
    else
        fprintf('%s: %d steps\n', networkNames{i}, timeA_all(i)); 
    end
end

%% E2 printing (comparing star reaching speed in 2 protocols)
fprintf('\nE2: Protocol B rendezvous times\n');
for i = 1:5
    if isnan(timeB_all(i))
        fprintf('%s: Not reached\n', networkNames{i});
    else
        fprintf('%s: %d steps\n', networkNames{i}, timeB_all(i)); 
    end
end

fprintf('\n Star Network Convergence Speed Comparison \n');
stepsA = timeA_all(2); 
stepsB = timeB_all(2);
fprintf('Protocol A steps: %d\n', stepsA);
fprintf('Protocol B steps: %d\n', stepsB);
if isnan(stepsA) || isnan(stepsB)
    fprintf('Comparison incomplete due to non-convergence.\n');
elseif stepsA < stepsB
    fprintf('Result: Protocol A is FASTER than Protocol B on the Star network.\n');
elseif stepsB < stepsA
    fprintf('Result: Protocol B is FASTER than Protocol A on the Star network.\n');
else
    fprintf('Result: Protocol A and B have the SAME speed on the Star network.\n');
end
fprintf('\n');

%% E2 theoretical values
for i = 1:5
    fprintf('\n%s\n', networkNames{i});
    fprintf('Protocol A theoretical: (%.6f, %.6f) | Sim: (%.6f, %.6f) | Err: %.3e\n', ...
        theoryA(i,1), theoryA(i,2), simA(i,1), simA(i,2), errorA(i));
    fprintf('Protocol B theoretical: (%.6f, %.6f) | Sim: (%.6f, %.6f) | Err: %.3e\n', ...
        theoryB(i,1), theoryB(i,2), simB(i,1), simB(i,2), errorB(i));
end

%% 
swarmAverage = [mean(x0), mean(y0)];
distanceA = norm(theoryA(2,:) - swarmAverage);
distanceB = norm(theoryB(2,:) - swarmAverage);
fprintf('\nE2: Star network Positions\n');
fprintf('Protocol A distance from swarm average: %.6f\n', distanceA);
fprintf('Protocol B distance from swarm average: %.6f\n', distanceB);

%% plotting G4 position
figure;
subplot(1,3,1);
plot(x0, y0, 'o'); axis equal; grid on;
title('Initial Positions'); xlabel('x'); ylabel('y');
subplot(1,3,2);
plot(XA_G4(:,end), YA_G4(:,end), 'o'); axis equal; grid on;
title('T4: Protocol A Final Positions'); xlabel('x'); ylabel('y');
subplot(1,3,3);
plot(XB_G4(:,end), YB_G4(:,end), 'o'); axis equal; grid on;
title('T4: Protocol B Final Positions'); xlabel('x'); ylabel('y');