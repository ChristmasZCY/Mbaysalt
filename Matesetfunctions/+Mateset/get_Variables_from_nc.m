function [Vars_name, Vars] = get_Variables_from_nc(fin,varargin)
    % TODO: need to write
    % =================================================================================================================
    % discription:
    %       Make tide current u/v/h from TPXO9-atlas, and write to nc file.
    % =================================================================================================================
    % parameter:
    %       yyyy: year                             || required: True || type: double         ||  format: 2019 or '2019'
    %       mm: month                              || required: True || type: double         ||  format: 1 or '1'
    %       varargin{1}: day_length                || required: False|| type: double         ||  format: 1:31
    % =================================================================================================================
    % example:
    %       make_tide_from_tpxo(2023,5)
    %       make_tide_from_tpxo(2023,5,[1,3,5])
    % =================================================================================================================

    varargin  = read_varargin2(varargin,{'INFO'});  % 是否打印信息, 默认不打印
    if ~isempty(INFO)
        INFO = true;
    else
        INFO = false;
    end

    fin_info = ncinfo(fin);  % 使用 ncinfo 函数获取文件信息
    vars = fin_info.Variables; % 获取变量信息
    
    [Dims,Dims_name,Dims_len] = Mateset.get_Dimensions_from_nc(fin);
    Dims_keys = fieldnames(Dims);

    % 获取变量名
    Vars_name = cell(length(vars)-length(Dims_len),1);
    t = 1;
    for i = 1:length(vars)
        if ~strncmp(vars(i).Name, Dims_keys, 5)
            Vars_name{t} = vars(i).Name;
            Vars.(Vars_name{t}) = ncread(fin,Vars_name{t});
            
            t = t + 1;
        end
    end
end
    

    