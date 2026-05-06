function data = read_json_file(fn)

text = fileread(fn);
data = jsondecode(text);
