function NBN = synthesize_nbn(Fs_Hz, Npts, Flo, Fhi, skirtOct)
% epl.signals.synthesize_nbn -- create narrowband noise
% Usage: NBN = epl.signals.synthesize_nbn(Fs_Hz, Npts, Flo, Fhi, skirtOct)
% 
% Synthesizes a token of bandpass noise using a Butterworth filter.
%
% *Inputs*
% Fs_Hz     : sampling rate, Hz
% Npts      : number of points
% Flo       : low-frequency cutoff, Hz
% Fhi       : high-frequency cutoff, Hz
% skirtOct  : filter skirts in octave (default = 1/8)
%

if nargin < 5, skirtOct = 1/8; end

y = normrnd(0, 1, 1, Npts);

Fnyq = Fs_Hz/2;

Rp = 0.5;
Rs = 60;

Fp1 = Flo / Fnyq;
Fp2 = Fhi / Fnyq;

Fst1 = Fp1 * 2^(-skirtOct);
Fst2 = Fp2 * 2^(skirtOct);

d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', Fst1,Fp1,Fp2,Fst2, Rs, Rp, Rs);
hd = design(d, 'butter');

NBN = hd.filter(y);

