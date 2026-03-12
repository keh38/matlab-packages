function idx = findFrom(arr, target, startIdx, numToFind)
%FINDFROM Search an array for a value starting from a given index.
%
%   IDX = FINDFROM(ARR, TARGET, STARTIDX, NUMTOFIND) returns the index of 
%   the first occurrence of TARGET in ARR at or after STARTIDX. Returns -1 
%   if not found.
%
%   Input Arguments:
%       ARR      - 1-by-N numeric vector to search
%       TARGET   - Scalar value to search for
%       STARTIDX - Index at which to begin searching
%       NUMTOFIND- Number of items to find
%
%   Output Arguments:
%       IDX - Index of the first match, or -1 if not found

   if nargin < 4, numToFind = 1; end

    offset = find(arr(startIdx:end) == target, numToFind);
    if isempty(offset)
        idx = -1;
    else
        idx = offset + startIdx - 1;
    end
end