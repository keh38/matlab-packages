function X = invert_sigmoid(P, Y)

a = P(1);
b = P(2);
c = P(3);
d = P(4);

if a / (Y-d) <= 0
   X = NaN;
else
   X = c - 1/b * log10(a/(Y-d) - 1);
end
