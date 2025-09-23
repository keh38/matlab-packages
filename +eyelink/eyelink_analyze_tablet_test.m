function eyelink_analyze_tablet_test(fn)

S = eyelink_read_data(fn);

% identify and remove blinks
S.pupilSize(S.pupilSize == 0) = NaN;

iblink = isnan(S.pupilSize);

%extend the NaNs by 40 ms pre-blink and 150 ms post-blink (Winn et al.
%2018)
% fs is 1000, so 1 sample per 1 ms
remove_blink = zeros(1, length(iblink));

for sample = 1:length(remove_blink)
    if iblink(sample) == 1
        if sample < 40 %if there is a blink at the beginning of trial...
            remove_blink(sample) = 1;
        elseif sample > 40
            remove_blink(sample-40:sample) = 1;
            remove_blink(sample:sample+150) = 1;
        else
        end
    else
    end
end
%if there is a blink at the end of a trial, the length gets
%messed up. Cut it back down to the correct length
if length(remove_blink) > length(iblink)
    remove_blink = remove_blink(1:length(iblink));
else
end

S.pupilSize(logical(remove_blink)) = NaN;

%detect remaining outliers
iOutlier = isoutlier(S.pupilSize, 'movmedian', 1000);
S.pupilSize(logical(iOutlier)) = NaN;

%interpolate
S.pupilSize = fillmissing(S.pupilSize, 'linear');

T = min(diff(S.ttrial));
npts = floor(T * S.sampleRate * 1e-3);

[yavg, tavg] = eyelink_compute_average(S, npts);

fmod = 0.05;

ystim = cos(2*pi*fmod*tavg) * range(yavg)/2 + nanmean(yavg);

figure

hold on;
plot(tavg, yavg);
plot(tavg, ystim);

xlabel('Time (s)');
ylabel('Pupil Size');