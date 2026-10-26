function G = make_complete(n)
u = ones(n,1);
G = u*u' - eye(n);
end
