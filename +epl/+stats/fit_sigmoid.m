function [P, yFit, stats] = fit_sigmoid(X, Y)

X = X(:);
Y = Y(:);

a = max(Y);
[~, kmn] = min(abs(Y - range(Y)/2));
xh = X(kmn);
b = range(Y)/range(X) * 4 / (a * log(10));
c = xh;
Pinit = [b c];
LB = [];
UB = [];

opt = optimset('MaxFunEvals', 4e4, 'MaxIter',4e4, 'Display', 'off');

fh = @(p,x)Fsigmoid(p,x,Y);

P = lsqcurvefit(fh, Pinit, X, Y, LB, UB, opt);

yFit = Fsigmoid(P, X, Y); % create fit, so we have it.

[a,b,c,d] = compute_params(P, X, Y);
P = [a, b, c, d];

stats.resid = yFit - Y;
stats.sse = sum(stats.resid.^2);
stats.sstot = sum((Y - mean(Y)).^2);
stats.R2 = 1 - stats.sse/stats.sstot;
n = length(Y);
k = length(P) - 1;
stats.adjR2 = 1 - ((1-stats.R2)*(n-1) / (n - k - 1));

%--------------------------------------------------------------------------
function [a,b,c,d] = compute_params(P, X, Y)
b = P(1);
c = P(2);
u = 1 ./ (1 + 10.^(b*(c-X)));

lincoeffs = [u ones(size(X))] \ Y;
a = lincoeffs(1);
d = lincoeffs(2);

%--------------------------------------------------------------------------
function F = Fsigmoid(P, X, Y)
[a,b,c,d] = compute_params(P, X, Y);
u = 1 ./ (1 + 10.^(b*(c-X)));
F = a * u + d;

%--------------------------------------------------------------------------
