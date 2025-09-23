function [D, TR] = prune_trace_reconstructed_data(D, TR)
% prune_trace_reconstructed_data -- remove empty trials
% Usage: [D, TR] = prune_trace_reconstructed_data(D, TR);
% 
% Serves similar function to check_alignment
%

if length(D) ~= length(TR)
   error('data and trace arrays are not the same length');
end

ikeep = true(size(D));

N = 1;

for k = 1:length(D)
   % Event 5 = output thread. If not present and there was an error, then 
   if ~any(TR(k).Event == 5) && any(contains(TR(k).Message, 'Error'))
      ikeep(k) = false;
   else
      D{k}.N = N;
      N = N + 1;
   end
end

D = D(ikeep);
TR = TR(ikeep);