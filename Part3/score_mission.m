function J = score_mission(D, S)
% SCORE_MISSION
% Evaluate the performance of a selected set of leaders.
%
% Inputs:
%   D : deployment structure containing:
%       D.G       - adjacency matrix
%       D.P0      - initial robot positions
%       D.faulty  - indices of faulty robots
%       D.g       - rally point [x, y]
%
%   S : indices of selected leaders
%
% Output:
%   J : mission score (percentage)

    %% 1. Basic information

    n = size(D.P0, 1);
    T = 125;
    maxLeaders = 4;

    faulty = D.faulty(:);
    S = S(:);

    %% 2. Validate leader selection

    % Check that S contains valid integer indices
    if ~isnumeric(S) || any(~isfinite(S)) || ...
            any(S ~= floor(S)) || ...
            any(S < 1) || any(S > n)

        error('S must contain valid integer robot indices.');
    end

    % Check that leaders are distinct
    if numel(unique(S)) ~= numel(S)
        error('Leader indices must be distinct.');
    end

    % Check the leader budget
    if numel(S) > maxLeaders
        error('At most 4 leaders can be selected.');
    end

    % Check that no faulty robot is selected
    if any(ismember(S, faulty))
        error('Faulty robots cannot be selected as leaders.');
    end

    %% 3. Construct the averaging matrix W_A

    I = eye(n);

    degree = sum(D.G, 2);
    DegreeMatrix = diag(degree);

    W_A = (I + DegreeMatrix) \ (I + D.G);

    %% 4. Construct the baseline system (no leaders)

    % All working robots are followers: lambda = 1
    lambda_base = ones(n, 1);

    % Faulty robots are anchored at their initial positions
    lambda_base(faulty) = 0;

    a_base = zeros(n, 1);
    b_base = zeros(n, 1);

    a_base(faulty) = D.P0(faulty, 1);
    b_base(faulty) = D.P0(faulty, 2);

    % Simulate baseline x and y coordinates
    X_base = simulate_anchored( ...
        W_A, lambda_base, a_base, D.P0(:, 1), T);

    Y_base = simulate_anchored( ...
        W_A, lambda_base, b_base, D.P0(:, 2), T);

    %% 5. Construct the system with selected leaders

    lambda_new = lambda_base;

    % Leaders have lambda = 0.5
    lambda_new(S) = 0.5;

    % Faulty robots must remain anchored at their initial positions
    lambda_new(faulty) = 0;

    a_new = a_base;
    b_new = b_base;

    % Leaders are anchored toward the rally point
    a_new(S) = D.g(1);
    b_new(S) = D.g(2);

    % Simulate the new system
    X_new = simulate_anchored( ...
        W_A, lambda_new, a_new, D.P0(:, 1), T);

    Y_new = simulate_anchored( ...
        W_A, lambda_new, b_new, D.P0(:, 2), T);

    %% 6. Calculate the mission score

    % Only working robots are included in the score
    working_robots = setdiff(1:n, faulty');

    J_sum = 0;

    % Column 1 corresponds to k = 0.
    % Therefore, columns 2 through T+1 correspond to k = 1,...,T.

    for k = 2:T+1

        % Baseline squared distances from the rally point
        dist2_base = ...
            (X_base(working_robots, k) - D.g(1)).^2 + ...
            (Y_base(working_robots, k) - D.g(2)).^2;

        e_base = mean(dist2_base);

        % New system squared distances from the rally point
        dist2_new = ...
            (X_new(working_robots, k) - D.g(1)).^2 + ...
            (Y_new(working_robots, k) - D.g(2)).^2;

        e_new = mean(dist2_new);

        % Percentage improvement at this time step
        if e_base > 0
            J_sum = J_sum + (1 - e_new / e_base);
        end

    end

    % Average improvement over T time steps
    J = (100 / T) * J_sum;

end