function X = invert_power2(P, Y)

a = P(1);
b = P(2);
c = P(3);

X = ((Y-c)/a) .^ (1/b);
