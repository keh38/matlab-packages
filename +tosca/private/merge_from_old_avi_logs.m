function TL = merge_from_old_avi_logs(TL, folder, filestem)
% folder = 'C:\Users\hancock\OneDrive\Engineering\Polley\Bshara';
% filestem = 'FBA03-Session3-Run4';

time = [];
firstColumn = [];
trialNum = [];
frameNum = [];

num = 0;
nframes = 0;

fillGaps = false;

while true
   fn = fullfile(folder, sprintf('%s.%03d.avi.txt', filestem, num));

   if ~exist(fn, 'file'), break; end

   fp = fopen(fn, 'rt');
   data = textscan(fp, '%f\t%f\t%f\t%f\t%f');
   fclose(fp);

   if all(isnan(data{5}))
      fillGaps = true;
   end

   firstColumn = [firstColumn; data{1}]; %#ok<*AGROW> 
   trialNum = [trialNum; data{2}]; 
   time = [time; data{3}]; 

   frameNum = [frameNum; data{5} + nframes];
   nframes = nframes + max(data{5}) + 1;

   num = num + 1;
end

if fillGaps
   figure(1);
   tiledlayout(2, 1);
   nexttile;
   hold on;
   plot(time-time(1), firstColumn, '.');
   nexttile;
   hold on;
   plot(abs(trialNum(trialNum<0)), time(trialNum<0)-time(1), '.');

   last_avi = fullfile(folder, sprintf('%s.%03d.avi', filestem, num-1));
   vr = VideoReader(last_avi);

   [time, firstColumn, trialNum, frameNum] = fill_gaps(time, firstColumn, trialNum, vr.NumFrames, TL.trials);

   figure(1);
   nexttile(1);
   plot(time-time(1), firstColumn, '.');
   set(gca, 'Children', flipud(get(gca, 'Children')));
   nexttile(2);
   plot(abs(trialNum(trialNum<0)), time(trialNum<0)-time(1), '.');
   set(gca, 'Children', flipud(get(gca, 'Children')));
end

ind_avi_trial = find(firstColumn == 1);
if length(ind_avi_trial) ~= length(TL.trials)
   error('inconsistent number of trials between Tosca and video');
end

ind_avi_trial(end+1) = length(frameNum) + 1;

for k = 1:length(TL.trials)
   i1 = ind_avi_trial(k) + 1;
   i2 = ind_avi_trial(k+1) - 1;

   if abs(trialNum(i1-1)) ~= k
      error('unexpected video trial number');
   end

   tavi = time(i1:i2) - time(i1);
   fr = frameNum(i1:i2);
   
   tstate = NaN*ones(length(TL.trials{k}.states), 1);
   for ks = 1:length(TL.trials{k}.states)
      tstate(ks) = TL.trials{k}.states(ks).start;
   end

   tstate = tstate - tstate(1);

   idx = ceil(interp1(tavi, 1:length(tavi), tstate));
   idx(end+1) = length(tavi) + 1; %#ok<SAGROW> 

   for ks = 1:length(TL.trials{k}.states)
      TL.trials{k}.states(ks).tframe = tavi(idx(ks):(idx(ks+1)-1));
      TL.trials{k}.states(ks).frames = fr(idx(ks):(idx(ks+1)-1));
   end

end
end

%--------------------------------------------------------------------------
function [t_filled, c1_filled, tr_filled, fr_filled] = fill_gaps(t, c1, tr, numFrames, toscaTrials)

% gap_indices = find(c1>1 & diff(c1)>1);
% gap_indices(end+1) = 40000;
gap_indices = (10000:10000:length(c1))';

dt = median(diff(t));

t_filled = [];
c1_filled = [];
tr_filled = [];

segmentStarts = 1 + [0; gap_indices];

for k = 1:length(gap_indices)
   igap = gap_indices(k);
   iseg = segmentStarts(k):igap;

   disp(igap);
   
   if c1(igap) == 1
      missingFrames = (c1(igap-1)+1) : (c1(igap+1)-1);
   else
      missingFrames = (c1(igap)+1) : (c1(igap+1)-1);
   end
   missingTime = t(igap) + (1:length(missingFrames)) * dt;
   missingTr = NaN(size(missingTime));

   t_filled = [t_filled; t(iseg); missingTime(:)];
   c1_filled = [c1_filled; c1(iseg); missingFrames(:)];
   tr_filled = [tr_filled; tr(iseg); missingTr(:)];
end

iseg = segmentStarts(end):length(c1);
missingFrames = [];
missingTime = [];
missingTr = [];
nfr = sum(c1(iseg) > 1);
if nfr < numFrames
   missingFrames = c1(end) + (1:(numFrames-nfr));
   missingTime = t(end) + (1:length(missingFrames)) * dt;
   missingTr = NaN(size(missingTime));
end
t_filled = [t_filled; t(iseg); missingTime(:)];
c1_filled = [c1_filled; c1(iseg); missingFrames(:)];
tr_filled = [tr_filled; tr(iseg); missingTr(:)];

ttosca = NaN(size(toscaTrials));
for k = 1:length(toscaTrials)
   ttosca(k) = toscaTrials{k}.start;
end

maxTrNum = abs(min(tr_filled));

trNum_tosca = 1:length(ttosca);
ttosca = (ttosca - ttosca(1)) / (ttosca(maxTrNum) - ttosca(1));

itr = tr_filled < 0;

missing = setdiff(trNum_tosca, abs(tr_filled(itr)));

tv_tr = t_filled(itr);

ti = interp1(trNum_tosca, ttosca, missing);
tmissing = tv_tr(1) + ti * range(tv_tr);

figure;
hold on;
plot(trNum_tosca, ttosca,'.');
plot(abs(tr_filled(itr)), (tv_tr-tv_tr(1))/range(tv_tr), '.');
plot(missing, ti, '.');

for k = 1:length(missing)
   insertBefore = find(t_filled > tmissing(k), 1);

   t_filled = [t_filled(1:insertBefore-1); tmissing(k); t_filled(insertBefore:end)];
   c1_filled = [c1_filled(1:insertBefore-1); 1; c1_filled(insertBefore:end)];
   tr_filled = [tr_filled(1:insertBefore-1); -missing(k); tr_filled(insertBefore:end)];

end

fr_filled = c1_filled - c1_filled(1);
fr_filled(c1_filled==1) = NaN;

end