function NML = read_nml_fvcom(fnml, varargin)
    %   Read FVCOM NML file
    % =================================================================================================================
    % Parameters:
    %       fnml:       File NML    || required: True || type: File       || example: '*.nml'
    %       varargin:   optional parameters     
    % =================================================================================================================
    % Returns:
    %       NML:        NML Struct  || type: struct
    % =================================================================================================================
    % Updates:
    %       2025-01-13:     Created,    by Christmas; 
    % =================================================================================================================
    % Examples:
    %       
    %       fnml = '/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_NSCS/Control/forecast_run.nml_exp';
    %       NML = read_nml_fvcom(fnml);
    % =================================================================================================================

    TOOLS = FVCOMTOOLS();
    NML.FVCOMTITLE = TOOLS.genFVCOMchar();

    C = strtrim(readlines(fnml));  % 读取所有行
    A_start = find(startsWith(C,'&'));  % 找到所有的&(title开始)
    A_end = find(strcmp(C,'/'));  % 找到所有的/(title结束)
    
    fid = fopen(fnml);
    for ig = 1 : len(A_start)
        frewind(fid);  % 重置文件指针到文件开头
        title = textscan(fid, '&%s', 1, 'Delimiter', '\n', 'HeaderLines', A_start(ig)-1);  % 读取title
        title = string(title);  % cell to str
        frewind(fid);  % 重置文件指针到文件开头
        key_value = textscan(fid, '%s', A_end(ig)-A_start(ig)-1, 'Delimiter', '\n', 'HeaderLines',A_start(ig));  % 读取key-value
        [key,value] = cellfun(@parse_line, strip(key_value{1}), 'UniformOutput', false);  % 解析key-value
        key = matlab.lang.makeUniqueStrings(key, {}, namelengthmax);  % 会有EMPTYONE重复的
        NML.(title) = cell2struct(value,key);  % 保存到NML结构体
    end
    fclose(fid);

    NML = TOOLS.delete_key(NML, 'EMPTYONE');
end


function [key, value] = parse_line(line)
    % 解析一行
    str = strsplit(line, '=');
    if len(str) == 2  % 正常
        key = strip(str{1});
        value = strip(str{2});
    elseif len(str) == 1 && strcmp(str{1},',')  % 如果只是一行 ,
        key = 'EMPTYONE';
        value = NaN;
        return
    elseif len(str) >= 3  % 如果 两个等号 RST_OUT_INTERVAL = 'days= 1.' ,!!!seconds= 3600.'
        F = find(line=='=', 1);
        key = strip(line(1:F-1));
        value = strip(line(F+1:end));
    end

    if size(key,1) == 0
        key = 'EMPTYONE';
    end
    % 去除注释
    key = del_exclamation(key,'key');
    value = del_exclamation(value,'value');
    % 去除最后的,
    if endsWith(value, ',')
        value(end:end) = [];
    end
    % 去除引号 'or "
    value = del_quotation(strip(value));
    if isempty(key)
        key = 'EMPTYONE';
        return  % key被注释
    end
    if isstrprop(key(1), 'digit')
        key = ['f' , key];
    elseif strcmpi(value, 'T')  % 不区分大小写
        value = true;
    elseif strcmpi(value, 'F')
        value = false;
    end
    
    value_numerical = str2double(value);
    if ~ isnan(value_numerical)
        value = value_numerical;
    end
    clearvars value_numerical
end


function Str = del_exclamation(str, opt)
    % 去掉! 
    % key和value的去除方法不一样
    % key   --> 只去掉所有的! 在开头补充 ANNOTATION__
    % value --> 把value中第一个!及后面的内容都去掉
    Str = str;
    switch opt
    case 'key'
        F = find(contains(Str, '!'));
        Str(Str=='!') = [];
        if F
            Str = ['ANNOTATION__' strip(Str)];
            clear F
        end
    case 'value'
        F = find(str=='!',1);
        Str(F:end) = [];
        Str = strip(Str);
    end

end
