function G = make_disk(P,r)
n = size(P,1);
s = sum(P.^2,2);
u = ones(n,1);
Delta = s*u' + u*s' - 2*P*P';
G = double(Delta <= r^2)-eye(n);
end
