function SetLogTicks(whichAxis, base, minTick, maxTick)
% SETLOGTICKS -- draw nice log-scale tick axes/labels.
% Usage: SetLogTicks(whichAxis, base, minTick, maxTick)
%

if nargin < 3,
   lim = get(gca, [whichAxis 'Lim']);
   minTick = lim(1);
   maxTick = lim(2);
end

if base > 1,
   numTicks = round(log(maxTick/minTick)/log(base));
   ticks = minTick * base .^ (0:numTicks);
elseif length(minTick) == 1,
   ticks = minTick:maxTick;
else
   ticks = minTick;
end
   
tl = cell(size(ticks));
for k = 1:length(ticks),
   tl{k} = num2str(ticks(k));
end

set(gca, [whichAxis 'Tick'], ticks, [whichAxis 'TickLabel'], tl);
set(gca, [whichAxis 'MinorTick'], 'off');
