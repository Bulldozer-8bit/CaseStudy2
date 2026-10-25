function G = make_star(n)
e1 = zeros(n,1);
e1(1) = 1;
u = ones(n,1);
G = e1*u' + u*e1' - 2*e1*e1';
end