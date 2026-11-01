% This is Part two codes
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'Part1'));
% Load the deployment parameters calculated in Part 1
load('deployment_parameters.mat', 'P0', 'r_min', 'k');

disp(r_min);
disp(k);
disp(size(P0));
K = 4500;
n = size(P0, 1);
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
figE1 = figure('Name', 'E1 Protocol A Convergence');
axE1 = axes(figE1);
hold(axE1, 'on');
for i = 1:5
    semilogy(axE1, 0:K,max(deltaA_all(i,:), 1e-15),'LineWidth', 1.5);
end
yline(axE1, threshold, '--k', '1% threshold', ...
    'LineWidth', 1.2);
set(axE1, 'YScale', 'log');
xlabel(axE1, 'Iteration k');
ylabel(axE1, 'Spread \delta[k]');
title(axE1, 'E1: Protocol A Convergence');
legend(axE1, networkNames, 'Location', 'best');
grid(axE1, 'on');
xlim(axE1, [0 K]);
hold(axE1, 'off');
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

swarmAverage = [mean(x0), mean(y0)];
distanceA = norm(theoryA(2,:) - swarmAverage);
distanceB = norm(theoryB(2,:) - swarmAverage);
fprintf('\nE2: Star network Positions\n');
fprintf('Protocol A distance from swarm average: %.6f\n', distanceA);
fprintf('Protocol B distance from swarm average: %.6f\n', distanceB);