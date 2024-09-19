clm
x = readtable('./1.xlsx');
x = x.Variables;
href = x(:,1);
name = x(:,2);
clear x

[uniqueC, ia, ic] = unique(href, 'stable');

uniqueC_href = href(ia);
uniqueC_name = name(ia);

counts = accumarray(ic, 1);
repeat_href = uniqueC_href(counts > 1);
repeat_name = uniqueC_name(counts > 1);
norepeat_href = uniqueC_href(counts == 1);
norepeat_name = uniqueC_name(counts == 1);

for idx = 1: length(repeat_href)
    fprintf('重复: %s : %s \n', repeat_href{idx}, repeat_name{idx})
end

href_new = [norepeat_href(:)', repeat_href(:)',];
name_new = [norepeat_name(:)', repeat_name(:)',];

for idx = 1: length(href_new)
    c{idx,1}= sprintf('<a href="%s" target="_blank"> %s</a>  <br>',href_new{idx},name_new{idx});
end
