function varargout = read_conf(confin, varargin)
    %       Read configuration file from *.conf file
    % =================================================================================================================
    % Parameter:
    %       confin: configuration file             || required: True || type: char or string  ||  format: *.conf
    %       varargin: (optional input)
    %           varargin{1}: keyToGet              || required: False|| type: char or string  ||  format: 'f2dmFile'
    %       varargout: (optional output)
    %         nargin == 1:
    %           varargout{1}: struct               || required: False|| type: struct          ||  format: struct(1*1)
    %           varargout{2}: struct               || required: False|| type: struct          ||  format: struct(n*1) --> name value
    %         nargin == 2:
    %           varargout{1}: value                || required: False|| type: char or string  ||  format: '/Users/.../f2dmFile.2dm'
    %           varargout{2}: struct               || required: False|| type: struct          ||  format: struct(n*1) --> name value
    %           varargout{3}: struct               || required: False|| type: struct          ||  format: struct(1*1)
    % =================================================================================================================
    % Example:
    %       conf = read_conf(confin)
    %       [conf, kv] = read_conf(confin)
    %       Value = read_conf(confin, 'f2dmFile')
    %       [Value, kv, conf] = read_conf(confin, 'f2dmFile')
    % =================================================================================================================

    arguments(Input)
        confin % {mustBeFile}
    end

    arguments(Repeating)
        varargin
    end

    fid = fopen(confin, 'r');
    if fid == -1
        error('Cannot open file %s', confin);
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
    varargout{1} = make_DEFAULT(varargout{1});
    if nargin > 1
        varargout{3} = varargout{2};
        varargout{2} = varargout{1};

        keyToGet = varargin{1};
        varargin(1) = [];

        if ~ isfield(varargout{1}, keyToGet)
            varargout{1} = '';
            warning('Key "%s" not found in struct', keyToGet);
        else
            varargout{1} = varargout{1}.(keyToGet);
        end
    end
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
    elseif strcmpi(value, '.True.')  % 不区分大小写
        value = true;
    elseif strcmpi(value, '.False.')
        value = false;
    elseif startsWith(value,'[')
        if ~ isnan(str2num(value))
            value = str2num(value);
        else
            value = listStr_to_cell(value);
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

function Struct = make_DEFAULT(structIn)
    Struct = structIn;
    Struct.DEFAULT = structIn;
end


