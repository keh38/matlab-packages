function writeLenAndString(fp, str)

fwrite(fp, length(str), 'int32');
fwrite(fp, str, 'char');
