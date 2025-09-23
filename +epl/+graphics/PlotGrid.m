classdef PlotGrid < hgsetget
   
   % --- PROPERTIES ---
   properties (SetAccess = public)
      Direction = 'normal';
      Name = 'Plot Grid';
      Size = [];
      XInteriorOffset = 0;
      YInteriorOffset = 0;
      Units = 'pixels';
   end
   properties (SetAccess = immutable)
      NumRows = 1;
      NumCols = 1;
      Border = 0.1;
   end
   properties (Hidden, SetAccess = private)
      hAxes = [];
      hXLabel = -1;
      hYLabel = -1;
   end
   
   % ---- METHODS ---
   methods
      % Constructor
      function obj = PlotGrid(nr, nc, sz)
         if nr<1 || nc<1, error('Invalid plot grid size.'); end
         obj.NumRows = nr;
         obj.NumCols = nc;
         
         if nargin > 2
            obj.Size = sz;
         end
         
         obj.hAxes = NaN(nr, nc);
         LayoutGrid(obj);
      end
      
      % --- PROPERTY ACCESSORS ---
      function obj = set.Size(obj, value)
         % Sets size of subplots (pixels)
         obj.Size = value;
         if ~isempty(obj.hAxes)
            LayoutGrid(obj);
         end
      end
      
      %--------------------------------------------------------------------
      function obj = set.XInteriorOffset(obj, value)
         obj.XInteriorOffset = value;
         LayoutGrid(obj);
      end
      
      %--------------------------------------------------------------------
      function obj = set.YInteriorOffset(obj, value)
         obj.YInteriorOffset = value;
         LayoutGrid(obj);
      end
      
      %--------------------------------------------------------------------
      function obj = set.Units(obj, value)
         obj.Units = value;
         LayoutGrid(obj);
      end
      
      %--------------------------------------------------------------------
      % --- PUBLIC METHODS ---
      function h = Axes(obj, row, col)
         % Retrieve subplot axes handle, using either row,col or linear
         % index.
         
         if nargin < 3
            % Linear index
            iPlot = row;
            row = floor((iPlot-1) / obj.NumCols) + 1;
            col = iPlot - (row-1)*obj.NumCols;
         end
         
         if strcmpi(obj.Direction, 'reverse')
            row = obj.NumRows - row + 1;
         end
         
         h = obj.hAxes(row, col);
         set(h, 'Visible', 'on');
      end
      
      %--------------------------------------------------------------------
      function Finish(obj)
         % 
         for j = 1:obj.NumRows
            for k = 1:obj.NumCols
               h = obj.hAxes(j,k);
               axes(h);
               
               if j < obj.NumRows
                  xlabel('');
                  set(h, 'XTickLabel', []);
               end
               if j==obj.NumRows && k<obj.NumCols
                  xtl = cellstr(get(h, 'XTickLabel'));
                  xtl{end} = '';
                  set(h, 'XTickLabel', xtl);
               end
               if k==1 && j>1
                  ytl = cellstr(get(h, 'YTickLabel'));
                  ytl{end} = '';
                  set(h, 'YTickLabel', ytl);
               end
               if k > 1
                  ylabel('');
                  set(h, 'YTickLabel', []);
               end
            end
         end
      end
      
      %--------------------------------------------------------------------
      function XLabel(obj, str, varargin)
         % Displays a shared y-axis label
         
         if ishandle(obj.hXLabel)
            delete(obj.hXLabel);
         end
         
         if isempty(str)
            return;
         end
         
         xmin = Inf;
         xmax = -Inf;
         y = Inf;
         
         labelRow = obj.NumRows;
         
         for k = 1:obj.NumCols
            pos = get(obj.hAxes(labelRow, k), 'Position');
            op = get(obj.hAxes(labelRow, k), 'OuterPosition');
            
            xmin = min(xmin, pos(1));
            xmax = max(xmax, pos(1)+pos(3));
            y = min(y, op(2));
         end
         
         obj.hXLabel = axes;
         set(obj.hXLabel, 'Position', [xmin y-0.05 xmax-xmin 0.05]);
         ht = text(0.5, 0.5, str);
         
         set(ht, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
         set(ht, 'FontSize', 14)
         set(ht, varargin{:});
         axis off
      end
      
      %--------------------------------------------------------------------
      function YLabel(obj, str, varargin)
         % Displays a shared y-axis label
         
         if ishandle(obj.hYLabel)
            delete(obj.hYLabel);
         end
         
         if isempty(str)
            return;
         end
         
         ymin = Inf;
         ymax = -Inf;
         x = Inf;
         
         for k = 1:obj.NumRows
            pos = get(obj.hAxes(k, 1), 'Position');
            op = get(obj.hAxes(k, 1), 'OuterPosition');
            
            ymin = min(ymin, pos(2));
            ymax = max(ymax, pos(2)+pos(4));
            x = min(x, op(1));
         end
         
         obj.hYLabel = axes;
         set(obj.hYLabel, 'Position', [x-0.05 ymin 0.05 ymax-ymin]);
         ht = text(0.5, 0.5, str);
         
         set(ht, 'Rotation', 90, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
         set(ht, 'FontSize', 14)
         set(ht, varargin{:});
         axis off
         
      end
      
      %--------------------------------------------------------------------
      function XAxis(obj, minVal, maxVal)
         % Set x-axis limits of all subplots in one go
         set_axis_lim(obj, 'X', minVal, maxVal);
      end
      
      %--------------------------------------------------------------------
      function YAxis(obj, minVal, maxVal)
         % Set y-axis limits of all subplots in one go
         set_axis_lim(obj, 'Y', minVal, maxVal);
      end
      
      %--------------------------------------------------------------------
      function SetAxisProps(obj, varargin)
         % Set axes properties of all subplots in one go
         set(obj.hAxes, varargin{:});
      end
      
      %--------------------------------------------------------------------
      function obj = InteriorOffset(obj, Xvalue, Yvalue)
         % Set spacing between grid subplots
         obj.XInteriorOffset = Xvalue;
         if nargin == 2
            obj.YInteriorOffset = Xvalue;
         else
            obj.YInteriorOffset = Yvalue;
         end
         LayoutGrid(obj);
      end
      
      %--------------------------------------------------------------------
      function obj = RowLabels(obj, Labels)

         k = 1;
         if isequal(obj.Direction, 'reverse')
            Labels = flip(Labels);
         end
         for j = 1:obj.NumRows
            h = obj.hAxes(j,k);
            if isnumeric(Labels(j))
               ylabel(h, num2str(Labels(j)));
               hl = get(h, 'YLabel');
               set(hl, 'Rotation', 0, 'VerticalAlignment', 'middle');
            elseif iscell(Labels(j))
               ylabel(h, strtrim(Labels{j}));
               hl = get(h, 'YLabel');
               set(hl, 'Rotation', 0, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'right');
            end
         end
      end
      %--------------------------------------------------------------------
      function obj = ColumnLabels(obj, Labels)

         j = obj.NumRows;
         for k = 1:obj.NumCols
            h = obj.hAxes(j,k);
            if isnumeric(Labels(k))
               xlabel(h, num2str(Labels(k)));
            elseif ischar(Labels)
               xlabel(h, deblank(Labels(k,:)));
            elseif iscell(Labels)
               xlabel(h, Labels{k});
            end
         end
      end
      
   end % of public methods

   %-----------------------------------------------------------------------
   % --- PRIVATE METHODS ---
   methods (Access = private)
      function LayoutGrid(obj)
         ou = get(gcf, 'Units');
         set(gcf, 'Units', obj.Units);
         figPos = get(gcf, 'Position');
         
         if isempty(obj.Size)
            dx = round((1-obj.Border)*figPos(3) / obj.NumCols - obj.XInteriorOffset);
            dy = round((1-obj.Border)*figPos(4) / obj.NumRows - obj.YInteriorOffset);
            
         else
            dx = obj.Size(1);
            dy = obj.Size(2);
            figPos(3) = (dx*obj.NumCols + obj.XInteriorOffset*(obj.NumCols-1)) / (1-obj.Border);
            figH = (dy*obj.NumRows + obj.YInteriorOffset*(obj.NumRows-1)) / (1-obj.Border);
            figPos(2) = figPos(2) - (figH - figPos(4));
            figPos(4) = figH;
            set(gcf, 'Position', figPos);
         end
         
         set(gcf, 'Units', ou);
         y = round((1-obj.Border/2)*figPos(4) - dy);
         
         for j = 1:obj.NumRows
            x = round(4*obj.Border*figPos(3)/5);
            for k = 1:obj.NumCols

               if isnan(obj.hAxes(j,k))
                  obj.hAxes(j,k) = axes;
                  set(obj.hAxes(j,k), 'Visible', 'off', 'Box', 'on');
               end
               set(obj.hAxes(j,k), 'Units', obj.Units);
               set(obj.hAxes(j,k), 'Position', [x y dx dy]);
               set(obj.hAxes(j,k), 'Units', 'normalized');
               
               x = x + dx + obj.XInteriorOffset;
            end
            y = y - dy - obj.YInteriorOffset;
         end
         
      end
      
      %--------------------------------------------------------------------
      function set_axis_lim(obj, whichAxis, minVal, maxVal)
         for kr = 1:obj.NumRows
            for kc = 1:obj.NumCols
               if strcmpi(get(obj.hAxes(kr,kc), 'Visible'), 'on')
                  set(obj.hAxes(kr,kc), [whichAxis 'Lim'], [minVal maxVal]);
               end
            end
         end
      end
      
   end % of private methods
   
end