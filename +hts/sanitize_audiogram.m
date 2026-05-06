function sanitizedAudiogram = sanitize_audiogram(deserializedAudiogram)

sanitizedAudiogram = deserializedAudiogram.audiograms;

for k = 1:length(sanitizedAudiogram)
   sanitizedAudiogram(k).Threshold_dBHL = sanitize_vector(sanitizedAudiogram(k).Threshold_dBHL);
   sanitizedAudiogram(k).Threshold_dBSPL = sanitize_vector(sanitizedAudiogram(k).Threshold_dBSPL);
end

end

%% ------------------------------------------------------------------------
%  Local helpers
% -------------------------------------------------------------------------
function V = sanitize_vector(V)
   if isnumeric(V), return; end

   vnumeric = NaN(size(V));
   for k = 1:length(V)
      if isnumeric(V{k})
         vnumeric(k) = V{k};
      elseif ischar(V{k})
         vnumeric(k) = str2double(strrep(V{k}, 'Infinity', 'Inf'));
      end
   end
   V = vnumeric;
end
