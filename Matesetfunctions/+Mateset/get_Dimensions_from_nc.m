function [Dims,Dims_name,Dims_len] = get_Dimensions_from_nc(fin,varargin)
    %       Get the dimensions information from a netCDF file
    % =================================================================================================================
    % Parameter:
    %       fin:        input NC file name                || required: True || type: string  ||  format: 'test.nc'
    %       varargin:   optional parameters     
    %           INFO:    whether to print the information  || required: False|| type: char    ||  format: 'INFO'
    % =================================================================================================================
    % Example:
    %       [Dims,Dims_name,Dims_len] = get_Dimensions_from_nc('test.nc');
    %       [Dims,Dims_name,Dims_len] = get_Dimensions_from_nc('test.nc','INFO');
    % =================================================================================================================

    varargin  = read_varargin2(varargin,{'INFO'});  % 是否打印信息, 默认不打印
    if ~isempty(INFO)
        INFO = true;
    else
        INFO = false;
    end

    fin_info = ncinfo(fin);  % 使用 ncinfo 函数获取文件信息
    dims = fin_info.Dimensions;  % 获取维度信息
    Dims = sort_dims(dims);  % 将维度信息按照 lon, lat, depth, time, other 的顺序排列

    % 显示每个维度的名称和长度
    Dims_name = cell(length(dims),1);
    Dims_len = zeros(length(dims),1);
    Dims_key = fieldnames(Dims);
    for i = 1:length(Dims_key)
        key = Dims_key{i};
        Dims_name{i} = Dims.(key).Name;
        Dims_len(i) = Dims.(key).Length;
        if INFO
            fprintf('Dimension %d: %s (%d)\n', i, Dims.(key).Name, Dims.(key).Length);
        end
    end

    

end

function Dims = sort_dims(dims)
    lon_name = ['longitude','long','lon','XLONG'];
    lat_name = ['latitude', 'lati','lat','XLAT'];
    depth_name = ['depth','dep','z','Z'];
    time_name = ['time','Time','t','T'];
    other_name = ['DateStr'];
    Dims = struct();
    for i = 1:length(dims) % 从 dims 中找到 lon 的维度信息
        if any(strcmp(dims(i).Name,lon_name))
            Dims.(dims(i).Name) = dims(i);
            dims(i) = [];
            break
        end
    end

    for i = 1:length(dims) % 从 dims 中找到 lat 的维度信息
        if any(strcmp(dims(i).Name,lat_name))
            Dims.(dims(i).Name) = dims(i);
            dims(i) = [];
            break
        end
    end

    for i = 1:length(dims) % 从 dims 中找到 depth 的维度信息
        if any(strcmp(dims(i).Name,depth_name))
            Dims.(dims(i).Name) = dims(i);
            dims(i) = [];
            break
        end
    end

    for i = 1:length(dims) % 从 dims 中找到 time 的维度信息
        if any(strcmp(dims(i).Name,time_name))
            Dims.(dims(i).Name) = dims(i);
            dims(i) = [];
            break
        end
    end

    for j = 1:length(other_name)
        for i = 1:length(dims) % 从 dims 中找到 other 的维度信息
            if any(strcmp(dims(i).Name,other_name(j)))
                Dims.(other_name{j}) = dims(i);
                dims(i) = [];
                break
            end
        end
    end
    for i = 1:length(dims) % 将剩余的维度信息放到 Dims中
        Dims.(dims(i).Name) = dims(i);
    end
end
