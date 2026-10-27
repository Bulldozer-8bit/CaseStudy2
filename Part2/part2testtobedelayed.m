% 前置部分不变
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'Part1'));
n = 100;
load('deployment_parameters.mat', 'P0', 'r_min', 'k');
K = 4500;
x0 = P0(:,1); y0 = P0(:,2);
G1 = make_complete(n); G2 = make_star(n); G3 = make_ring(n, k);
G4 = make_disk(P0, r_min); G4_larger = make_disk(P0, r_min + 0.4);
G_list = {G1, G2, G3, G4, G4_larger};
networkNames = {'T1 Complete', 'T2 Star', 'T3 Ring', 'T4 Disk: r_min', 'T4 Disk: r_min+0.4'};
I = eye(n); C = I - (1/n)*ones(n);

% 初始化存储空间，避免冗余计算
deltaA_all = zeros(5, K+1);
timeA_all = NaN(5,1);
delta0 = sqrt(norm(C*x0)^2 + norm(C*y0)^2);
threshold = 0.01 * delta0;

theoryA = zeros(5,2); theoryB = zeros(5,2);
simA = zeros(5,2);    simB = zeros(5,2);
errorA = zeros(5,1);  errorB = zeros(5,1);

% 预留位置存储 G4 (第4个网络) 的轨迹，用于最后画图，避免最后再次重复仿真
XA_G4 = []; YA_G4 = []; XB_G4 = []; YB_G4 = [];

figure; hold on;

%% 合并 E1 与 E2 的核心循环
for i = 1:5
    G = G_list{i};
    d = sum(G, 2);
    D = diag(d);
    L = D - G;
    
    % 正确计算每个网络的 WA 和 WB
    WA = (I + D) \ (I + G);
    epsilon = 1 / max(d);  
    WB = I - epsilon * L;
    
    % 仅仿真一次即可！
    XA = simulate_linear(WA, x0, K);
    YA = simulate_linear(WA, y0, K);
    XB = simulate_linear(WB, x0, K);
    YB = simulate_linear(WB, y0, K);
    
    % 如果是 G4 网络，把轨迹存下来给最后画图用
    if i == 4
        XA_G4 = XA; YA_G4 = YA; XB_G4 = XB; YB_G4 = YB;
    end
    
    % --- E1 计算部分 ---
    for j = 1:K+1
        deltaA_all(i,j) = sqrt(norm(C*XA(:,j))^2 + norm(C*YA(:,j))^2);
    end
    idx = find(deltaA_all(i,:) <= threshold, 1, 'first');
    if ~isempty(idx), timeA_all(i) = idx - 1; end
    semilogy(0:K, max(deltaA_all(i,:), 1e-15), 'LineWidth', 1.5);
    
    % --- E2 计算部分 ---
    weights = 1 + d;
    theoryA(i,1) = sum(weights .* x0) / sum(weights);
    theoryA(i,2) = sum(weights .* y0) / sum(weights);
    theoryB(i,1) = mean(x0);
    theoryB(i,2) = mean(y0);
    
    simA(i,1) = mean(XA(:,end)); simA(i,2) = mean(YA(:,end));
    simB(i,1) = mean(XB(:,end)); simB(i,2) = mean(YB(:,end));
    
    errorA(i) = max(sqrt((XA(:,end) - theoryA(i,1)).^2 + (YA(:,end) - theoryA(i,2)).^2));
    errorB(i) = max(sqrt((XB(:,end) - theoryB(i,1)).^2 + (YB(:,end) - theoryB(i,2)).^2));
end

% --- E1 收尾画图与输出 ---
yline(threshold, '--k', '1% threshold');
xlabel('Iteration k'); ylabel('Spread \delta[k]');
title('E1: Protocol A Convergence');
legend(networkNames, 'Location', 'best'); grid on; hold off;

fprintf('\nE1: Protocol A rendezvous times\n');
for i = 1:5
    if isnan(timeA_all(i)), fprintf('%s: Not reached\n', networkNames{i});
    else, fprintf('%s: %d steps\n', networkNames{i}, timeA_all(i)); end
end

% --- E2 控制台输出 ---
for i = 1:5
    fprintf('\n%s\n', networkNames{i});
    fprintf('Protocol A theoretical: (%.6f, %.6f) | Sim: (%.6f, %.6f) | Err: %.3e\n', ...
        theoryA(i,1), theoryA(i,2), simA(i,1), simA(i,2), errorA(i));
    fprintf('Protocol B theoretical: (%.6f, %.6f) | Sim: (%.6f, %.6f) | Err: %.3e\n', ...
        theoryB(i,1), theoryB(i,2), simB(i,1), simB(i,2), errorB(i));
end

% --- E2: Star network 距离计算（使用上面的 theory 数组即可）---
swarmAverage = [mean(x0), mean(y0)];
distanceA = norm(theoryA(2,:) - swarmAverage);
distanceB = norm(theoryB(2,:) - swarmAverage);
fprintf('\nE2: Star network\n');
fprintf('Protocol A distance from swarm average: %.6f\n', distanceA);
fprintf('Protocol B distance from swarm average: %.6f\n', distanceB);

%% 彻底消除冗余：直接使用存下来的 G4 轨迹画图，不要重新计算 WA/WB 和 simulate_linear
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