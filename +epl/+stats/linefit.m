function [M, B, R, P] = linefit(X,Y)
% LINEFIT -- wrapper for 'regress.m'.
% Usage: [M, B, R, P] = linefit(X,Y)
%
[b,bint,r,rint,stats] = regress(Y(:), [X(:) ones(length(X), 1)]);
M = b(1);
B = b(2);
R = sqrt(stats(1));
P = stats(3);

% fprintf('R2 = %.3f\n', stats(1));
% fprintf('F = %.3f\n', stats(2));
% fprintf('p = %e\n', stats(3));
% fprintf('df = %d\n', length(X) - 2);
