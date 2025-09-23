function [Data, Header] = read_turandot_data(fn)

d = loadjson(fn);
Header = d{1};
Data = d(2:end);
