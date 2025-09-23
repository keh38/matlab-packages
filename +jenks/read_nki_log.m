function DL = read_nki_log(fn)

fp = fopen(fn, 'rb', 'b');

D = epl.file.read_prepended_string(fp);
Y = epl.file.read_prepended_2d_array(fp, 'double');

fclose(fp);

DL.name = D;
DL.time = Y(1, :);
DL.joystickIn = Y(2, :);
DL.joystickCommand = Y(3, :);
DL.disturbance = Y(4, :);
DL.Vcommand = Y(5, :);
DL.Vfeedback = -40*Y(6, :);
DL.position = Y(7, :);
DL.rightButton = Y(8, :);
DL.leftButton = Y(9, :);
DL.sync = Y(10, :);
DL.tsystem = typecast(Y(10, :), 'int64');
