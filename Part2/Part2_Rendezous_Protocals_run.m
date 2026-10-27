% This is Part two codes

% Find the project root directory
projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Add Part1 to MATLAB's search path
addpath(fullfile(projectRoot, 'Part1'));
n = 100;

% k = ? change before test
% K = ?
% P0 = ?
% rmin = ?
% x0 = ?
% y0 = ?


% Generate four networks in Part 1
G1 = make_complete(n);
G2 = make_star(n);
G3 = make_ring(n, k);
G4 = make_disk(P0, rmin);


I = eye(n); % 100x100 identity matrix
G = ones(n) - I; % Use "ones" to simulate G before Part1 is done.  
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