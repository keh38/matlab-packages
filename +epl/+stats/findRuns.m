function [startIndex, runLength, mask] = findRuns(V, options)
%FINDRUNS Finds groups of consecutive 'true' elements in the logical vector
% V.
%
% Usage: [startIndex, runLength, mask] = findRuns(V, options);
%
% --- REQUIRED INPUT ---
% V : logical vector
% 
% --- OPTIONAL PROP/VAL PAIRS ---
% 'MinLength': minimum run length (default = 2)
%
% --- OUTPUTS ---
% startIndex   : vector of run start indices
% runLength    : matching vector of run lengths
% mask         : logical mask (=V, with subminimal runs excluded)
%

arguments
   V  {mustBeVector}
   options.MinLength    (1,1) double = 2;
end

minLength = options.MinLength;

% Pad with zeros to detect edges at boundaries
padded = [0, V(:)', 0];
d = diff(padded);

startIndex = find(d == 1);        % rising edges  → run starts
endIdx     = find(d == -1);       % falling edges → run ends (exclusive)
lengths    = endIdx - startIndex; % length of each run

% Filter by minimum length
ikeep      = lengths >= minLength;
startIndex = startIndex(ikeep);
runLength  = lengths(ikeep);

mask = zeros(size(V));
for k = 1:length(startIndex)
   mask(startIndex(k) + (0:runLength(k)-1)) = 1;
end

if size(mask, 1) ~= size(V, 1)
   mask = mask';
end

