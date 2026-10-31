%% Part3_Explore.m
% Compare three simple leader-selection strategies
% over multiple practice deployments.

clear;
clc;
close all;

%% 1. Experiment settings

numDeployments = 30;       % At least 20, as required
seeds = 1:numDeployments;
m = 4;                     % Maximum number of leaders

strategyNames = {
    'Random'
    'Highest Degree'
    'Closest to Rally'
};

numStrategies = length(strategyNames);

% Each row: one deployment
% Each column: one strategy
scores = zeros(numDeployments, numStrategies);

% Store deployments for later plotting
deployments = cell(numDeployments, 1);

% Store selected leaders
selectedLeaders = cell(numDeployments, numStrategies);


%% 2. Generate deployments and evaluate strategies

for q = 1:numDeployments

    seed = seeds(q);

    % Generate a deployment
    D = make_deployment(seed);
    deployments{q} = D;

    n = size(D.G, 1);

    % Exclude faulty robots
    working = setdiff(1:n, D.faulty(:)');

    mUse = min(m, length(working));


    %% Strategy 1: Random working robots

    % Use a reproducible random selection for each deployment
    rng(100000 + seed, 'twister');

    randomOrder = randperm(length(working));
    S_random = working(randomOrder(1:mUse));


    %% Strategy 2: Highest-degree robots

    degree = sum(D.G, 2);

    [~, order] = sort(degree(working), 'descend');

    S_degree = working(order(1:mUse));


    %% Strategy 3: Robots closest to the rally point

    distances = sqrt(sum((D.P0(working, :) - D.g).^2, 2));

    [~, order] = sort(distances, 'ascend');

    S_closest = working(order(1:mUse));


    %% Evaluate the three strategies

    selectedLeaders{q, 1} = S_random;
    selectedLeaders{q, 2} = S_degree;
    selectedLeaders{q, 3} = S_closest;

    scores(q, 1) = score_mission(D, S_random);
    scores(q, 2) = score_mission(D, S_degree);
    scores(q, 3) = score_mission(D, S_closest);

    fprintf('Seed %d completed.\n', seed);

end


%% 3. Display average, median, and standard deviation

meanScores = mean(scores, 1)';
medianScores = median(scores, 1)';
stdScores = std(scores, 0, 1)';

summaryTable = table( ...
    strategyNames, ...
    meanScores, ...
    medianScores, ...
    stdScores, ...
    'VariableNames', ...
    {'Strategy', 'MeanScore', 'MedianScore', 'StdScore'});

disp(' ');
disp('========== Strategy Comparison ==========');
disp(summaryTable);


%% 4. Determine the best strategy by average score

[~, bestIndex] = max(meanScores);

fprintf('\nBest strategy by average score: %s\n', ...
    strategyNames{bestIndex});


%% 5. Plot deployment layouts using predetermined seeds

% These seeds are selected before examining the scores.
% They are NOT selected based on best or worst performance.

layoutSeeds = [1, 7, 19, 30];

figure('Name', 'Practice Deployment Layouts', ...
       'Position', [100, 100, 1000, 700]);

for p = 1:length(layoutSeeds)

    seed = layoutSeeds(p);
    q = find(seeds == seed, 1);

    D = deployments{q};

    working = setdiff(1:size(D.P0, 1), D.faulty(:)');

    subplot(2, 2, p);

    % Working robots
    scatter(D.P0(working, 1), D.P0(working, 2), ...
        18, 'b', 'filled');

    hold on;

    % Faulty robots
    scatter(D.P0(D.faulty, 1), D.P0(D.faulty, 2), ...
        35, 'r', 'filled');

    % Rally point
    plot(D.g(1), D.g(2), 'kp', ...
        'MarkerSize', 13, ...
        'MarkerFaceColor', 'y');

    axis equal;
    grid on;

    xlabel('x');
    ylabel('y');

    title(sprintf('Deployment: Seed %d, r = %.1f', ...
        seed, D.r));

    legend('Working robots', 'Faulty robots', 'Rally point', ...
        'Location', 'best');

end

sgtitle('Examples of Practice Deployments');


%% 6. Plot score distributions

figure('Name', 'Score Distribution Comparison', ...
       'Position', [150, 150, 850, 550]);

boxplot(scores, 'Labels', strategyNames);

ylabel('Mission Score (%)');
xlabel('Leader Selection Strategy');

title(sprintf('Score Distributions over %d Practice Deployments', ...
    numDeployments));

grid on;


%% 7. Analyze the lower-performing quarter of deployments

% This examines recurring failure patterns rather than selecting
% and plotting one single worst deployment.

numLow = max(1, ceil(0.25 * numDeployments));

fprintf('\n========== Lower-Performing Deployment Analysis ==========\n');

for s = 1:numStrategies

    [sortedScores, order] = sort(scores(:, s), 'ascend');

    lowIndices = order(1:numLow);

    fprintf('\n%s:\n', strategyNames{s});
    fprintf('Lower-quarter score range: %.2f to %.2f\n', ...
        sortedScores(1), sortedScores(numLow));

    for j = 1:length(lowIndices)

        q = lowIndices(j);
        D = deployments{q};

        degree = sum(D.G, 2);

        % Geometric size of the deployment
        spatialSize = norm(max(D.P0, [], 1) - min(D.P0, [], 1));

        % Average distance from working robots to the rally point
        working = setdiff(1:size(D.P0, 1), D.faulty(:)');

        avgDistanceToRally = mean( ...
            sqrt(sum((D.P0(working, :) - D.g).^2, 2)));

        fprintf(['  Seed %d: score = %.2f, ' ...
                 'mean degree = %.2f, degree std = %.2f, ' ...
                 'spatial size = %.2f, avg rally distance = %.2f\n'], ...
            D.seed, scores(q, s), mean(degree), std(degree), ...
            spatialSize, avgDistanceToRally);

    end

end