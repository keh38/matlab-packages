function drawBoxWithText(left, top, right, bottom, str)
%DRAWBOXWITHTEXT Draw a rectangle with centered text.
%
%   DRAWBOXWITHTEXT(LEFT, TOP, RIGHT, BOTTOM, STR) draws a rectangle
%   defined by its LEFT, TOP, RIGHT, and BOTTOM edges and places text
%   STR centered within it.

   if top < bottom
      tmp = top;
      top = bottom;
      bottom = tmp;
   end

    % rectangle() uses [x y width height] format
    x = left;
    y = bottom;
    w = right - left;
    h = top - bottom;
    rectangle('Position', [x, y, w, h], 'FaceColor', 'w');

    % Center point of the box
    cx = (left + right) / 2;
    cy = (top + bottom) / 2;

    text(cx, cy, str, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment',   'middle');
end