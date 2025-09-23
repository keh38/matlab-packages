function [P, yFit, stats] = fit_power2(X, Y)

Binit = power2start(X,Y);

LB = [];
UB = [];

opt = optimset('MaxFunEvals', 4e4, 'MaxIter',4e4, 'Display', 'off', ...
   'Jacobian', 'off', 'DiffMaxChange', 0.1, 'DiffMinChange', 1e-8, ...
   'Algorithm', 'trust-region-reflective', 'PrecondBandWidth', Inf);

fh = @(p,x)Fpower2(p,x,Y);

B = lsqcurvefit(fh, Binit, X, Y, LB, UB, opt);
yFit = Fpower2(B, X, Y); % create fit, so we have it.

lincoeffs = [X.^B ones(size(X))] \ Y;
a = lincoeffs(1);
c = lincoeffs(2);

P = [a B c];

stats.resid = yFit - Y;
stats.sse = sum(stats.resid.^2);
stats.sstot = sum((Y - mean(Y)).^2);
stats.R2 = 1 - stats.sse/stats.sstot;
n = length(Y);
k = length(P) - 1;
stats.adjR2 = 1 - ((1-stats.R2)*(n-1) / (n - k - 1));

%--------------------------------------------------------------------------
function F = Fpower2(P, X, Y)
b = P;
lincoeffs = [X.^b ones(size(X))] \ Y;
a = lincoeffs(1);
c = lincoeffs(2);

F = a * X.^b + c;

%--------------------------------------------------------------------------
function B = power2start(X, Y)

ikeep = X>0 & Y>0;
X = X(ikeep);
Y = Y(ikeep);

B = mean( log( Y(1)./Y(2:end) )./log( X(1)./X(2:end) ) );



