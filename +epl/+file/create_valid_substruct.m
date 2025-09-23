function substruct = create_valid_substruct(expr)

expr = epl.file.create_valid_varname(expr);

names = split(expr, '.');

coe = cell(length(names), 1);
substruct = struct('type', coe, 'subs', coe);

for k = 1:length(names)
   substruct(k).type = '.';
   substruct(k).subs = names{k};
end