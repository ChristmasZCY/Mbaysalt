function [Vars_name, Vars] = get_Variables_from_nc(fin,varargin)
    % =================================================================================================================
    % discription:
    %       Get the variables from the netCDF file
    % =================================================================================================================
    % parameter:
    %       fin:        input NC file name                || required: True || type: string  ||  format: 'test.nc'
    %       varargin:   optional parameters     
   %           INFO:    whether to print the information  || required: False|| type: char    ||  format: 'INFO'
    % =================================================================================================================
    % example:
    %       [Vars_name, Vars] = get_Variables_from_nc('test.nc');
    %       [Vars_name, Vars] = get_Variables_from_nc('test.nc','INFO');
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
    

    