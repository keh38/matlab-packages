function Yg = cos2window(Y, R_ms, Fs_Hz)
%COS2WINDOW - Create a cosine-squared window.
% Usage: W = cos2window(X, R, Fs)
%	X	Signal to be windowed
%	R_ms	Ramplength, ms
%	Fs_Hz	Sampling rate, Hz
%

sinePeriod_s = 2*R_ms/1000;
npts = sinePeriod_s * Fs_Hz;
sineFrequency = 1/sinePeriod_s;

sineBuffer = -cos(2*pi*sineFrequency*(0:npts-1)/Fs_Hz);
sineBuffer = (sineBuffer + 1)/2;
sineBuffer = sineBuffer.^2;

%  Split the sinusoid in half and fill center with ones
numPoints = length(Y);
numOnes = numPoints - length(sineBuffer);
N = length(sineBuffer);
G = [sineBuffer(1:round(N/2)) ones(1,numOnes) sineBuffer((round(N/2)+1):end)];

if size(Y,1) ~= size(G,1)
   G = G';
end

Yg = Y .* G;
