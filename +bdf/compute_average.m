function Y = compute_average(bdfFile, npts, nskip)
% BDF_COMPUTE_AVERAGE -- compute average wavefrom from Biosemi .bdf file.
% Usage: Y = bdf_compute_average(bdfFile)
%
if nargin < 3, nskip = 0; end

header = bdf.read_header(bdfFile);

Ysum = zeros(header.NumberOfChannels, npts);
numTrial = 0;

idxTrial = bdf.find_markers(header);

% Hack to get asynchronous data
offset = 0;
for k = 1:length(idxTrial)
   if mod(k-1, 11) == 0
      offset = idxTrial(k);
      continue; 
   end
%    idxTrial(k) = round((idxTrial(k) - offset) * 160/101 / 1.6 + offset);
end

if nskip > 1
   idxTrial = idxTrial(1:nskip:end);
end

yrem = zeros(header.NumberOfChannels, 0);
idx = [];

nrecPerRead = 5;
nreads = ceil(header.NumberOfRecords / nrecPerRead);

recsLeft = header.NumberOfRecords;

offset = 0;

fprintf('Computing average...\n');

for k = 1:nreads
   startReadFrom = (k-1)*nrecPerRead;
   numThisRead = min(nrecPerRead, recsLeft);

   if k > 1
      for kb = 1:nbytes, fprintf('\b'); end
   end
   nbytes = fprintf('Record %d of %d...', startReadFrom + numThisRead, header.NumberOfRecords);
   
   y = bdf.read(header, startReadFrom, numThisRead);
   recsLeft = recsLeft - nrecPerRead;

   idx = [idx (1:size(y,2)) + offset];
   offset = offset + size(y,2);

   y = [yrem y];

   ioff = 0;
   
   for itr = idxTrial(idxTrial >= idx(1) & idxTrial < idx(end)-npts)'
      ioff = itr - idx(1);
      
      Ysum = Ysum + y(:, ioff + (1:npts));
      
      numTrial = numTrial + 1;
   end
   
   yrem = y(:, ioff+2:end);
   idx = idx(ioff+2:end);
end

Y = Ysum / numTrial;

for kb = 1:nbytes, fprintf('\b'); end
fprintf('Processed %d trials.\n', numTrial);