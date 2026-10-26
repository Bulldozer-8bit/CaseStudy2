% This is Part two codes
n = 100;

I = eye(n); % 100x100 identity matrix
G = ones(n) - I; % Use "ones" to simulate G before Part1 is done.  
d = sum(G, 2);
D = diag(d);
L = D - G;

% Protocol A: averaginggit

WA = (I + D)^-1 * (I + G);


% Protocol B: one step
epsilon = 1 / max(d);
WB = I - epsilon * L;

