classdef Logger < handle

   properties (SetAccess = private)
      logPath;
      echoToCommandWindow = true;
      logText = '';
   end

   methods
      function obj = Logger(folder, filestem, echoToCommandWindow)
         dateTag = datetime('now', 'Format', 'yyyyMMdd');
         obj.logPath = fullfile(folder, sprintf('%s-%s.log', filestem, dateTag));
         obj.logText = '';

         if nargin > 2
            obj.echoToCommandWindow = echoToCommandWindow;
         end
      end

      %--------------------------------------------------------------------
      function LogInfo(obj, message)
         obj.AddEntry('INFO', message);
      end

      %--------------------------------------------------------------------
      function LogError(obj, message)
         obj.AddEntry('ERROR', message);
      end

      %--------------------------------------------------------------------
      function AddEntry(obj, category, message)
         dateStr = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
         entry = sprintf('%s\t[%s]\t%s\n', dateStr, category, message);

         if obj.echoToCommandWindow
            fprintf('%s', entry);
         end

         obj.logText = [obj.logText entry];

         if length(obj.logText) > 1000
            obj.Flush();
         end
      end

      %--------------------------------------------------------------------
      function Flush(obj)
         fp = fopen(obj.logPath, 'at');
         fprintf(fp, '%s', obj.logText);
         fclose(fp);
         obj.logText = '';
      end

   end
end

%--------------------------------------------------------------------------
% END OF Logger.m
%--------------------------------------------------------------------------
