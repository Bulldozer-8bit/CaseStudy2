% Compare three simple leader-selection strategies:
%
% 1. Random selection
% 2. Highest-degree selection
% 3. Closest-to-rally selection
%
% Number of practice deployments: 20
% Maximum number of leaders: 4

clear;
clc;
close all;

%% 1. Parameters

numDeployments = 20;
m = 4;

strategyNames = {
    'Random'
    'Highest Degree'
    'Closest to Rally'
};

numStrategies = numel(strategyNames);

%% 2. Storage

scores = zeros(numDeployments, numStrategies);

deployments = cell(numDeployments, 1);

selectedLeaders = cell(numDeployments, numStrategies);

%% 3. Generate deployments and evaluate strategies

for s = 1:numDeployments

    fprintf('Evaluating deployment %d of %d...\n', ...
        s, numDeployments);

    %% Generate deployment

    D = make_deployment(s);

    deployments{s} = D;

    n = size(D.P0, 1);

    % Exclude faulty robots
    faulty = D.faulty(:);

    workingRobots = setdiff(1:n, faulty');

    % Number of leaders to select
    numLeaders = min(m, numel(workingRobots));

    %% Strategy 1: Random selection

    % Use a fixed random seed for reproducibility
    rng(10000 + s, 'twister');

    randomOrder = randperm(numel(workingRobots));

    S_random = workingRobots( ...
        randomOrder(1:numLeaders));

    selectedLeaders{s, 1} = S_random;

    scores(s, 1) = score_mission(D, S_random);

    %% Strategy 2: Highest-degree selection

    % Calculate the degree of every robot
    degree = sum(D.G, 2);

    % Only consider working robots
    workingDegree = degree(workingRobots);

    % Sort working robots by degree in descending order
    [~, degreeOrder] = sort(workingDegree, 'descend');

    S_degree = workingRobots( ...
        degreeOrder(1:numLeaders));

    selectedLeaders{s, 2} = S_degree;

    scores(s, 2) = score_mission(D, S_degree);

    %% Strategy 3: Closest-to-rally selection

    % Calculate Euclidean distance to the rally point
    distances = sqrt( ...
        (D.P0(workingRobots, 1) - D.g(1)).^2 + ...
        (D.P0(workingRobots, 2) - D.g(2)).^2);

    % Sort by distance in ascending order
    [~, distanceOrder] = sort(distances, 'ascend');

    S_closest = workingRobots( ...
        distanceOrder(1:numLeaders));

    selectedLeaders{s, 3} = S_closest;

    scores(s, 3) = score_mission(D, S_closest);

end

fprintf('\nAll deployments evaluated successfully.\n');

%% 4. Check the results

assert(all(isfinite(scores(:))), ...
    'Some mission scores are not finite.');

%% 5. Plot score distributions

figure('Name', 'Leader Strategy Comparison', ...
       'NumberTitle', 'off');

boxplot(scores, 'Labels', strategyNames);

ylabel('Mission Score (%)');

title('Comparison of Three Leader-Selection Strategies');

grid on;

yline(0, '--k', 'No improvement');

%% 6. Calculate statistical results

meanScores = mean(scores, 1);

worstScores = min(scores, [], 1);

bestScores = max(scores, [], 1);

stdScores = std(scores, 0, 1);

%% 7. Display summary table

Summary = table( ...
    strategyNames, ...
    meanScores', ...
    worstScores', ...
    bestScores', ...
    stdScores', ...
    'VariableNames', { ...
        'Strategy', ...
        'AverageScore', ...
        'WorstScore', ...
        'BestScore', ...
        'StandardDeviation' ...
    });

fprintf('\n===== Strategy Comparison Summary =====\n');

disp(Summary);

%% 8. Find the worst-performing strategy and deployment

[worstScore, linearIndex] = min(scores(:));

[worstDeployment, worstStrategy] = ...
    ind2sub(size(scores), linearIndex);

fprintf('\n===== Worst-Case Result =====\n');

fprintf('Deployment: %d\n', worstDeployment);

fprintf('Strategy: %s\n', ...
    strategyNames{worstStrategy});

fprintf('Mission score: %.4f%%\n', worstScore);

%% 9. Restore the matching deployment and leader set

% IMPORTANT:
% Always retrieve D and S using the same deployment and strategy
% before plotting. This prevents mismatched deployment/leader data.

D = deployments{worstDeployment};

S = selectedLeaders{worstDeployment, worstStrategy};

%% 10. Plot the worst-case deployment

figure('Name', 'Worst-Case Deployment', ...
       'NumberTitle', 'off');

hold on;

% Draw communication links
gplot(D.G, D.P0);
% Plot all robots
scatter( ...
    D.P0(:, 1), ...
    D.P0(:, 2), ...
    25, ...
    'b', ...
    'filled');

% Plot faulty robots
scatter( ...
    D.P0(D.faulty, 1), ...
    D.P0(D.faulty, 2), ...
    65, ...
    'r', ...
    's', ...
    'filled');

% Plot selected leaders
scatter( ...
    D.P0(S, 1), ...
    D.P0(S, 2), ...
    100, ...
    'g', ...
    'd', ...
    'filled');

% Plot rally point
scatter( ...
    D.g(1), ...
    D.g(2), ...
    180, ...
    'm', ...
    'p', ...
    'filled');

xlabel('x position');

ylabel('y position');

title(sprintf( ...
    'Worst Case: Deployment %d, %s, Score = %.2f%%', ...
    worstDeployment, ...
    strategyNames{worstStrategy}, ...
    worstScore));

legend( ...
    'Communication links', ...
    'Working robots', ...
    'Faulty robots', ...
    'Selected leaders', ...
    'Rally point', ...
    'Location', ...
    'best');

axis equal;

grid on;

hold off;

%% 11. Plot the average score of each strategy

figure('Name', 'Average Strategy Scores', ...
       'NumberTitle', 'off');

bar(meanScores);

set(gca, ...
    'XTick', 1:numStrategies, ...
    'XTickLabel', strategyNames);

ylabel('Average Mission Score (%)');

title('Average Performance Across 20 Deployments');

grid on;

%% 12. Plot the worst score of each strategy

figure('Name', 'Worst Strategy Scores', ...
       'NumberTitle', 'off');

bar(worstScores);

set(gca, ...
    'XTick', 1:numStrategies, ...
    'XTickLabel', strategyNames);

ylabel('Worst Mission Score (%)');

title('Worst-Case Performance Across 20 Deployments');

grid on;

%% 13. Save results

save('leader_strategy_results.mat', ...
    'scores', ...
    'Summary', ...
    'deployments', ...
    'selectedLeaders', ...
    'worstDeployment', ...
    'worstStrategy');

fprintf('\nResults saved to leader_strategy_results.mat\n');

%% Generate deployment

D = make_deployment(7);

n = size(D.P0, 1);
workingRobots = setdiff(1:n, D.faulty(:)');

m = 4;

%% Strategy 1: Random

rng(10007, 'twister');

order = randperm(length(workingRobots));
S_random = workingRobots(order(1:m));

%% Strategy 2: Highest Degree

degree = sum(D.G, 2);

[~, order] = sort(degree(workingRobots), 'descend');
S_degree = workingRobots(order(1:m));

%% Strategy 3: Closest to Rally

distances = sqrt( ...
    (D.P0(workingRobots, 1) - D.g(1)).^2 + ...
    (D.P0(workingRobots, 2) - D.g(2)).^2);

[~, order] = sort(distances, 'ascend');
S_closest = workingRobots(order(1:m));

%% Prepare strategies for the viewer

L(1).name = 'Random';
L(1).S = S_random;

L(2).name = 'Highest Degree';
L(2).S = S_degree;

L(3).name = 'Closest to Rally';
L(3).S = S_closest;

%% Export JSON

export_for_viewer(D, L, 'comparison.json');