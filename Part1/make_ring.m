function G = make_ring(n,k)
S = circshift(eye(n),1,1);
G = zeros(n);
for j = 1:k
    G = G + S^j + (S^j)';
end
end