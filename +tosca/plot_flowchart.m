function plot_flowchart(params)

cla;
hold on;

nflow = numel(params.Flowchart);

for k = 1:nflow
   f = params.Flowchart(k);
   epl.graphics.drawBoxWithText(f.rect.left, f.rect.top, f.rect.right, f.rect.bottom, f.Name);

   nlink = length(f.Links);
   for klink = 1:nlink
      nextIndex = f.Links(klink).forward;
      if nextIndex < 0, continue; end

      fnext = params.Flowchart(nextIndex + 1);

      x1 = f.rect.right;
      y1 = 0.5*(f.rect.top + f.rect.bottom);
      x2 = fnext.rect.left;
      y2 = 0.5*(fnext.rect.top + fnext.rect.bottom);
      quiver(x1, y1, x2-x1, y2-y1, 0, 'k');

   end
end

axis equal tight;
axis off;