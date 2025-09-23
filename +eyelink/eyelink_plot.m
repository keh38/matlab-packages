function eyelink_plot(S)


T0 = S.time(1);
t = (S.time - T0) * 1e-3;
tstate = (S.tstate-T0) * 1e-3;

sz = S.pupilSize;
% sz(sz == 0) = NaN;

figure;
plot(t, sz);

reference('x', tstate, 'r-');

xlabel('Time (s)');
ylabel('Pupil size');