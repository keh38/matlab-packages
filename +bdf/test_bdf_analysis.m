%% Synthetic tone bursts
fn = 'D:\Data\XYZ DATA\XYZ1\synthetic.bdf';

Y = bdf_compute_average(fn, 500, 2);

figure;
plot(Y(1,:));

%% .wav file
fn = 'D:\Data\AAP Data\Pilot3-NoisePat_cyc5rep595R3-13.header.txt';
% fn = 'D:\Data\AAP Data\Pilot3-ABR3k105-0.header.txt';
h = parse_ini_config(fn);

% bdfFile = strrep(fn, '.header.txt', '.0.0.bdf');
bdfFile = 'D:\Data\AAP Data\synthetic_wav.bdf';
header = bdf_read_header(bdfFile);
Tmax = 5000; 
npts = round(header.SampleRate * Tmax/1000);

nskip = 10;

Y = bdf_compute_average(bdfFile, npts, nskip);

iPos = 66;
iNeg = [48 49 12 37 32];

t = (0:npts-1) * 1000 / 8192;

abr = Y(iPos,:) - mean(Y(iNeg,:));
abr = abr - mean(abr);

figure;
hold on;
plot(t, Y(1,:), 'r');
plot(t, filter_abr(abr, 8192, 32, 100, 3000));
% plot(t, abr);
xaxis(0,10);