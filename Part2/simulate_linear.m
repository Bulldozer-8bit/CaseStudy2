% this is simulating function

function X = simulate_linear(W, x0, K)
%SIMULATE_LINEAR Simulate x[k+1] = W*x[k].
%
% Inputs:
%   W  - n-by-n system matrix
%   x0 - n-by-1 initial state vector
%   K  - number of time steps (nonnegative integer)
%
% Output:
%   X  - n-by-(K+1) matrix
%        X(:,1)   = x[0]
%        X(:,k+1) = x[k]

% Validate inputs.
[n, m] = size(W);

assert(n == m, 'W must be a square matrix.');
assert(isvector(x0) && numel(x0) == n, ...
    'x0 must have n elements.');
assert(isscalar(K) && isfinite(K) && ...
    K >= 0 && K == floor(K), ...
    'K must be a nonnegative integer.');

x0 = x0(:);

% Allocate storage for every time step.
X = zeros(n, K + 1);
X(:, 1) = x0; % transform to column vector

% Simulate using matrix-vector products.
for iter_k = 1:K
    X(:, iter_k + 1) = W * X(:, iter_k);
end
end