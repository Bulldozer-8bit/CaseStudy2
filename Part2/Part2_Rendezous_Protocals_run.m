% This is Part two codes

projectRoot = fileparts(fileparts(mfilename('fullpath'))); % Find the project root directory
addpath(fullfile(projectRoot, 'Part1')); % Add Part1 to MATLAB's search path

n = 100;

% P0's dimension is 100 by 2

load('deployment_parameters.mat', 'P0', 'r_min', 'k');
disp(r_min);
disp(k);
disp(size(P0));
K = 4500; % could be changed
x0 = P0(:,1);
y0 = P0(:,2);


% Generate four networks in Part 1
G1 = make_complete(n);
G2 = make_star(n);
G3 = make_ring(n, k);
G4 = make_disk(P0, r_min);

G4_larger = make_disk(P0, r_min + 0.4);


I = eye(n); % 100x100 identity matrix
% G = G1/G2/G3/G4/G4_larger
d = sum(G, 2);
D = diag(d);
L = D - G;

% Protocol A: averaging
WA = (I + D)^-1 * (I + G);

% Protocol B: one step
epsilon = 1 / max(d);
WB = I - epsilon * L;

XA = simulate_linear(WA, x0, K);
YA = simulate_linear(WA, y0, K);

XB = simulate_linear(WB, x0, K);
YB = simulate_linear(WB, y0, K);

C = I - (1/n)*ones(n);

deltaA = zeros(1, K+1);
deltaB = zeros(1, K+1);

for j = 1:K+1
    deltaA(j) = sqrt(norm(C*XA(:,j))^2 + norm(C*YA(:,j))^2);
    deltaB(j) = sqrt(norm(C*XB(:,j))^2 + norm(C*YB(:,j))^2);
end

thresholdA = 0.01 * deltaA(1);
thresholdB = 0.01 * deltaB(1);

idxA = find(deltaA <= thresholdA, 1, 'first');
idxB = find(deltaB <= thresholdB, 1, 'first');

if isempty(idxA)
    timeA = NaN;
else
    timeA = idxA - 1; % we have K+1 columns, column -1 = K (times)
end

if isempty(idxB)
    timeB = NaN;
else
    timeB = idxB - 1;
end

% Plot δ[k] on a log scale, all on one figure

figure;
semilogy(0:K, max(deltaA, eps), 'LineWidth', 1.5); %semilogy means log scale
% eps is the accuracy of matlab, so any value of deltaA below this is inaccurate
hold on;
semilogy(0:K, max(deltaB, eps), 'LineWidth', 1.5);

yline(thresholdA, '--', 'A: 1% threshold');
yline(thresholdB, '--', 'B: 1% threshold');
xlabel('Iteration k');
ylabel('Convergence spread \delta[k]');
title('Rendezvous Convergence');
legend('Protocol A', 'Protocol B', 'Location', 'best');
grid on;

% report kε for each.

fprintf('Protocol A rendezvous time: ');
if isnan(timeA)
    fprintf('Not reached within K = %d steps\n', K);
else
    fprintf('%d steps\n', timeA);
end

fprintf('Protocol B rendezvous time: ');
if isnan(timeB)
    fprintf('Not reached within K = %d steps\n', K);
else
    fprintf('%d steps\n', timeB);
end



% Robot initial and final position
figure;
subplot(1,3,1);
plot(x0, y0, 'o');
axis equal;
grid on;
title('Initial Positions');
xlabel('x');
ylabel('y');

subplot(1,3,2);
plot(XA(:,end), YA(:,end), 'o');
axis equal;
grid on;
title('Protocol A: Final Positions');
xlabel('x');
ylabel('y');

subplot(1,3,3);
plot(XB(:,end), YB(:,end), 'o');
axis equal;
grid on;
title('Protocol B: Final Positions');
xlabel('x');
ylabel('y');

%% 10. Compare theoretical consensus locations
% Protocol A preserves the degree-weighted average
weights = 1 + d;
xA_theory = sum(weights .* x0) / sum(weights);
yA_theory = sum(weights .* y0) / sum(weights);

% Protocol B preserves the arithmetic average
xB_theory = mean(x0);
yB_theory = mean(y0);

fprintf('\nTheoretical consensus locations:\n');
fprintf('Protocol A: (%.6f, %.6f)\n', ...
        xA_theory, yA_theory);
fprintf('Protocol B: (%.6f, %.6f)\n', ...
        xB_theory, yB_theory);

fprintf('\nSimulated final locations (mean across robots):\n');
fprintf('Protocol A: (%.6f, %.6f)\n', ...
        mean(XA(:,end)), mean(YA(:,end)));
fprintf('Protocol B: (%.6f, %.6f)\n', ...
        mean(XB(:,end)), mean(YB(:,end)));