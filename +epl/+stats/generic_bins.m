function bins = generic_bins(data, binWidth)

ymin = floor(min(data)/binWidth) * binWidth;
ymax = ceil(max(data)/binWidth) * binWidth;
bins = ymin : binWidth : ymax;
