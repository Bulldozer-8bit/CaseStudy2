function G = make_disk(P,r)
n = size(P,1);
s = sum(P.^2,2);
u = ones(n,1);
Delta = s*u' + u*s' - 2*P*P';
G = double(Delta <= r^2);
G(1:n+1:end) = 0;
end