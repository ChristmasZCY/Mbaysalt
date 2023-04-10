function varargout = read_conf(conf_file, varargin)
    % =================================================================================================================
    % discription:
    %       read configuration file from *.conf file
    % =================================================================================================================
    % parameter:
    %       conf_file: configuration file          || required: True || type: char or string  ||  format: *.conf
    %       varargin{n}: parameter name            || required: False|| type: char or string  ||  format: 'f2dmFile'
    %       varargout{n}: parameter value          || required: False|| type: char or string  ||  format: 'f2dmFile'
    % =================================================================================================================
    % example:
    %       read_conf(conf_file)
    %       read_conf(conf_file, 'f2dmFile')
    % =================================================================================================================

    fid = fopen(conf_file, 'r');
    if fid == -1
        error('Cannot open file %s', conf_file);
    end

    l_num = 1;
    kv_conf = cell(0);
    while ~feof(fid)
        line = strip(fgetl(fid));
        if contains(line,'=')
            if  ~ startsWith(line,"#")
                F = strfind(line,"#");
                if ~ isempty(F)
                    line = strip(line(1:F-1));
                end
                kv_conf{l_num}= line;
                l_num = l_num + 1;
            end
        end
    end
    fclose(fid);

    %-cellfun: 对cell中的每个元素执行函数
    %-strsplit: 将字符串分割成单词
    %-str2bool: 将字符串转换为逻辑值
    %-str2func: 将字符串转换为函数句柄
    %-str2sym: 将字符串转换为符号表达式
    %-str2mat: 将字符串转换为矩阵
    [key,value] = cellfun(@parse_line, kv_conf, 'UniformOutput', false);
    [varargout{1}, varargout{2}] = KeyValue2Struct(key,value);
    if nargin > 1
        varargout{3} = varargout{2};
        varargout{2} = varargout{1};
        varargout{1} = varargout{1}.(varargin{1});
    end



    function [key, value] = parse_line(line)
        str = strsplit(line, '=');
        key = strip(str{1});
        value = strip(str{2});

        if size(key,1) == 0
            key = 'NaN';
        end
        value = del_quotation(value);
        if isstrprop(key(1), 'digit')
            key = ['f' , key];
        elseif strcmpi(value, '.True.')
            value = true;
        elseif strcmpi(value, '.False.')
            value = false;
        elseif startsWith(value,'[')
            if ~ isnan(str2num(value))
                value = str2num(value);
            else
                value = list_to_cell(value);
            end
        elseif startsWith(value,'{')
            value = json_to_struct(value);
        elseif is_number(value)
            value = str2double(value);
        end
        if size(value,1) == 0
            value = NaN;
        end

    end

end

