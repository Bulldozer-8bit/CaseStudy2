function stats = graph_stats(G)
n = size(G,1);
d = G*ones(n,1);
stats.degree = d;
stats.edge_count = sum(d)/2;

A = eye(n) + G;
R = eye(n);
stats.diameter = Inf;

for k = 0:n
    if all(R(:))
        stats.diameter = k;
        break;
    end
    R = double(A*R > 0);
end
end