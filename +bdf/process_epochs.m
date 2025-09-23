function Y = process_epochs(bdfFile)
% bdf.COMPUTE_AVERAGE -- compute average wavefrom from Biosemi .bdf file.
% Usage: Y = bdf.compute_average(bdfFile)
%

header = bdf.read_header(bdfFile);

idxTrial = bdf.find_markers(header);

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
      
      yepoch = y(:, ioff + (1:NepochPts));
      % DO YOUR FILTHY BUSINESS HERE!!!
   end
   
   yrem = y(:, ioff+2:end);
   idx = idx(ioff+2:end);
end

for kb = 1:nbytes, fprintf('\b'); end
fprintf('Processed %d trials.\n', numTrial);