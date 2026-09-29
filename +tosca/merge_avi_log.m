function TL = merge_avi_log(TL, AVI)

fprintf('[Tosca] merging avi log...\n');
fprintf('000 / %03d...', numel(TL.trials));

for k = 1:length(TL.trials)
   
   fprintf('\b\b\b\b\b\b\b\b\b\b\b\b');
   fprintf('%03d / %03d...', k, numel(TL.trials));

   if abs(TL.trials{k}.start - AVI(k).toscaTime) > 1 || ...
         length(TL.trials{k}.states) < length(AVI(k).states)
       [TL, AVI] = tosca.repair_video(TL, AVI);
%       error('Possible video error. Please tell Ken.');
   end
   
   TL.trials{k}.aviFile = AVI(k).aviFile;
   TL.trials{k}.ttosca = AVI(k).toscaTime;
   TL.trials{k}.frameRate = AVI(k).frameRate;
   
   states = TL.trials{k}.states;
   TL.trials{k} = rmfield(TL.trials{k}, 'states');

   if length(states) > length(AVI(k).states)
      fprintf('Missing state marker in trial %d...\n', k);
      ttosc = [states.start];
      
      fravi = [];
      tavi = [];
      for ka = 1:length(AVI(k).states)
         tavi = [tavi; AVI(k).states(ka).tframe]; %#ok<*AGROW> 
         fravi = [fravi; AVI(k).states(ka).frameNum];
      end

      if length(tavi) > 1
         frtosc = interp1(tavi-tavi(1)+ttosc(1), fravi, ttosc);
         frtosc = [round(frtosc) fravi(end)] + 1;
         
         for ks = 1:length(states)
            AVI(k).states(ks).toscaTime = ttosc(ks);
            AVI(k).states(ks).tframe = tavi(frtosc(ks):(frtosc(ks+1)-1));
            AVI(k).states(ks).frameNum = fravi(frtosc(ks):(frtosc(ks+1)-1));
         end
      else
         for ks = 1:length(states)
            AVI(k).states(ks).toscaTime = ttosc(ks);
            AVI(k).states(ks).tframe = [];
            AVI(k).states(ks).frameNum = [];
         end
      end
   end
   
   if length(states) < length(AVI(k).states)
      error('too many AVI states');
   end
   
   for ks = 1:length(states)
      st = states(ks);

      st.frames = AVI(k).states(ks).frameNum;
      st.tframe = AVI(k).states(ks).tframe;
      
      TL.trials{k}.states(ks) = st;
   end
end

