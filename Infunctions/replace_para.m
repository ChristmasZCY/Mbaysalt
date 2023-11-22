function Sout = replace_para(Sin,replaced_format, str)
    %       Replace ${replaced_format}$ with str for char or string or struct
    % =================================================================================================================
    % Parameter:
    %       Sin: input parameter                    || required: True || type: char or string or struct
    %       replaced_format: replaced format        || required: True || type: char or string  ||  format: 'yyyymmdd'
    %       str: replaced string                    || required: True || type: char or string  ||  format: '20190101'
    %       Sout: output parameter                  || required: True || type: char or string or struct
    % =================================================================================================================
    % Example:
    %       Sout = replace_para('select * from ${yyyymmdd}$', 'yyyymmdd', '20190101')
    %       Sout = replace_para(struct, 'yyyymmdd', '20190101')
    % =================================================================================================================

    replaced_str = ['${', replaced_format, '}$'];
    
    if isa(Sin, 'struct')
        Sout = Sin;
        key = fieldnames(Sin);
        for i = 1 : length(key)
            tmp_1 = char(Sin.(key{i}));
            if isa(tmp_1,'char')
                var = regexp(tmp_1, '\${(.*?)}\$', 'match');
                for j = 1 : length(var)
                    if strcmp(replaced_str, var{j})
                        tmp_2 = strrep(tmp_1, replaced_str, str);
                        Sout.(key{i}) = tmp_2;
                    end
                end
              
            end
        end
    elseif isa(Sin, 'char') || isa(Sin, 'string')
        Sin = char(Sin);
        Sout = '';
        var = regexp(Sin, '\${(.*?)}\$', 'match');
        for j = 1 : length(var)
            if strcmp(replaced_str, var{1})
                Sout = strrep(Sin, replaced_str, str);
            end
        end
    end

end

