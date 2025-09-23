function varargout = tight_figure(fig, border)
% TIGHT_FIGURE -- make figure size minimum required to show plot.
% Usage: tight_figure(fig)
%
if nargin < 1, fig = gcf; end
if nargin < 2, border = 0; end

if ~ishandle(fig),
   border = fig;
   fig = gcf;
end

drawnow;

% hax = get(fig, 'Children');
hax = findobj(fig, 'Type','axes');
xmin = Inf;
xmax = -Inf;
ymin = Inf;
ymax = -Inf;

% set(gca, 'LooseInset', [0 0 0 0]);
% annotation('rectangle', get(gca, 'Position') + ...
%            get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1], ...
%            'Color', 'Red');
        
for k = 1:length(hax), 
   set(hax(k), 'Units', 'pixels');
   axesPos = get(hax(k), 'Position');
   axesTightInset = get(hax(k), 'TightInset');

   xmin = min(xmin, axesPos(1) - axesTightInset(1));
   xmax = max(xmax, axesPos(1)+axesPos(3) + axesTightInset(3));
   ymin = min(ymin, axesPos(2) - axesTightInset(2));
   ymax = max(ymax, axesPos(2)+axesPos(4) + axesTightInset(4));
end

ou = get(fig, 'Units');
figPos = get(fig, 'Position');
origPos = figPos;

set(fig, 'Units', 'pixels');
figPosIn = get(fig, 'Position');
set(fig, 'Units', ou);

border = border * figPos(3)/figPosIn(3);

for k = 1:length(hax),
   axesPos = get(hax(k), 'Position');
   axesPos(1) = axesPos(1) - xmin + border;
   axesPos(2) = axesPos(2) - ymin + border;
   set(hax(k), 'Position', axesPos);
end

figPos(3) = xmax-xmin + 2*border;
figPos(4) = ymax-ymin + 2*border;

dy = origPos(4) - figPos(4);
figPos(2) = figPos(2) + dy;

set(fig, 'Position', figPos);

figPos = getposition(fig, 'inches');

set(fig, 'PaperPosition', [0 0 figPos(3:4)]);
set(fig, 'PaperSize', figPos(3:4));
