function SPL = get_tone_level(fn, freq)

calData = cfts.calib.read(fn);
SPL = interp1(calData.Freq, calData.Mag, freq);
