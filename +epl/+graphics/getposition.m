function [POS, EXT] = getposition(h, units)
% GETPOSITION -- gets object position in specified units.
% Usage: POS = getposition(h, units)
%
originalUnits = get(h, 'Units');
set(h, 'Units', units);
POS = get(h, 'Position');

if nargout == 2,
   if isprop(h, 'Extent'),
      EXT = get(h, 'Extent');
   else
      error('Object does not have ''extent'' property.');
   end
end

set(h, 'Units', originalUnits);