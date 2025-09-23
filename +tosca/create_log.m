function TL = create_log(FN, varargin)
% TOSCA_CREATE_LOG -- add timing details to Tosca trial data.
% Usage: TL = tosca_create_log(FN)
% Usage: TL = tosca_create_log(FN, 'aviFolder', aviFolder)
%
% --- Inputs ---
% FN : main Tosca data file
% aviFolder : if specified, adds video frame information
%

aviFolder = fileparts(FN);
toscaOnly = false;
epl.file.parse_propval_pairs(varargin{:});

% Special case: missing .di.txt files, reconstruct from trace file
[folder, filestem] = fileparts(FN);
reconstructFromTrace = ~exist(fullfile(folder, sprintf('%s-Trial01.di.txt', filestem)), 'file');
if reconstructFromTrace
   warning("No .di.txt files found! Reconstructing from trace file");
   traceData = tosca.read_trace_data(FN, false);   
end

% Read main data file
[D, P] = tosca.read_run(FN, ~reconstructFromTrace); % skip alignment check if there are no .di.txt files

TL.filename = P.Info.Filename;
TL.version = P.Info.Version;
TL.params = P;

if reconstructFromTrace
  [D, traceData] = prune_trace_reconstructed_data(D, traceData);
end

for k = 1:length(D)
   TR{k} = D{k}; %#ok<*AGROW>

   if ~reconstructFromTrace
      s = tosca.read_trial(P, D, D{k}.N);
      % trial timing information
      TR{k}.start = s.Time_s(1);
      TR{k}.stop = max(s.Time_s);
      TR{k}.duration = TR{k}.stop - TR{k}.start;

      % individual state timing information
      tState = [s.Time_s(1) s.Time_s(find(diff(s.State_Change)>0) + 1) max(s.Time_s)];
      names = s.History(1:2:end);
      if length(names) > length(tState)-1
         names = names(1:length(tState)-1);
         %       warning('mismatch between state names and times');
      end

      trep = [s.Time_s(1) s.Time_s(find(diff(s.Rep_Trigger)>0) + 1)];
      for ks = 1:length(names)
         nrep = sum(trep >= tState(ks) & trep < tState(ks+1));
         stateData = struct('name', strtrim(names{ks}), ...tl =
            'start', tState(ks), 'stop', tState(ks+1), 'duration', tState(ks+1) - tState(ks), 'nrep', nrep);
         TR{k}.states(ks) = stateData;
      end

   else 
      TR{k} = reconstruct_trial_from_trace(TR{k}, traceData(k));
   end

end

TL.trials = TR;

if ~toscaOnly
   % merge .avi data, if it exists
   [~, filestem] = fileparts(FN);

   aviLogPath = fullfile(aviFolder, [filestem '.avi.log']);
   if exist(aviLogPath, 'file')
      aviLog = tosca.read_avi_log(aviLogPath);
      TL = tosca.merge_avi_log(TL, aviLog);
      TL.aviFolder = aviFolder;
   elseif exist(fullfile(aviFolder, [filestem '.000.avi.txt']), 'file')
      TL = merge_from_old_avi_logs(TL, aviFolder, filestem);
      TL.aviFolder = aviFolder;
   end
   TL = tosca.create_loco_log(TL);
end

% save to .mat file
save(strrep(TL.filename, '.txt', '.log.mat'), 'TL');



