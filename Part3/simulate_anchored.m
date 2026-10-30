function X = simulate_anchored(W,lambda,a,x0,K)
n = length(x0);

Lambda = diag(lambda);
I = eye(n);

X = zeros(n,K+1);
X(:,1) = x0;

for t = 1:K
    X(:,t+1) = Lambda*W*X(:,t) + (I-Lambda)*a;
end
end