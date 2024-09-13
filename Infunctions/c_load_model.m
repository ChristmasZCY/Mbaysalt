function [GridStruct, VarStruct, Ttimes] = c_load_model(fin, varargin)
    %       To load model data
    % =================================================================================================================
    % Parameters:
    %       fin:            input file name                 || required: True || type: Text       || example: '*.nc'
    %       varargin:       optional parameters     
    %           Global:     Switch global or local          || required: False|| type: flag       || example: 'Global'
    %           Coordinate: Coordinate system               || required: False|| type: namevalue  || example: 'Coordinate', 'geo'
    %           MaxLon:     MaxLon                          || required: False|| type: namevalue  || example: 'MaxLon', 180
    % =================================================================================================================
    % Returns:
    %       GridStruct:    Model Grid Struct                || required: False|| type: struct     || example: 
    %       VarStruct:     Model Variable Struct            || required: False|| type: struct     || example: 
    %       Ttimes:        Model Ttimes                     || required: False|| type: struct     || example: 
    % =================================================================================================================
    % Updates:
    %       2024-04-03:     Created,                        by Christmas; 
    %       2024-05-13:     Added calculating uv2sd, sd2uv, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.2dm');
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.nc', 'Global', 'Coordinate', 'geo');
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.nc', 'Global');
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc','MaxLon', 180);
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc', 'Global', 'Coordinate', 'geo');
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc', 'Coordinate', 'geo');
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('wrf2fvcom.nc', 'Coordinate', 'geo','MaxLon', 180);
    % =================================================================================================================
    % Dependencies:
    %       f_load_grid.m
    %       f_load_time.m
    %       w_load_grid.m
    %       nc_var_exist.m
    %       nc_attrName_exist.m
    %       nc_attrValue_exist.m
    %       ncdateread.m
    %       read_varargin.m
    %       read_varargin2.m
    %       Mdatetime.m
    % =================================================================================================================

    arguments(Input)
        fin (1,:) {mustBeFile}
    end

    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin2(varargin, {'Global'});
    varargin = read_varargin(varargin, {'Coordinate'}, {'geo'});
    varargin = read_varargin(varargin, {'MaxLon'}, {180});

    fin = convertStringsToChars(fin);
    if endsWith(fin, '.nc') || isNetcdfFile(fin)
        if nc_attrName_exist(fin, 'WAVEWATCH', 'method','START')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            if nc_var_exist(fin, 'tri')
                nv = ncread(fin, 'tri')';
                GridStruct = f_load_grid(lon, lat, nv, 'MaxLon', MaxLon);
            else
                GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            end
            GridStruct.ModelName = 'WW3'; GridStruct.grid = 'TRI';
        elseif nc_attrName_exist(fin, 'product_name', 'method','START')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'Standard'; GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin, 'FVCOM', 'method','START')
            GridStruct = f_load_grid(fin, Global, "Coordinate", Coordinate, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'FVCOM'; GridStruct.grid = 'TRI';
        elseif nc_attrValue_exist(fin, 'wrf2fvcom version', 'method','START')
            GridStruct = w_load_grid(fin, Global, "Coordinate", Coordinate, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'WRF2FVCOM'; GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'WRF\s*(V\d+(\.\d+)?)?\s*MODEL')
            % 匹配{"WRF V4.4 MODEL", "WRF V4.1 MODEL", "WRF V1.2 MODEL", "WRF MODEL", "WRFMODEL"};
            % \s*：匹配零个或多个空白字符。
            % (V\d+(\.\d+)?)?：这是一个整体作为可选部分的组，匹配版本号。\d+：匹配一个或多个数字，代表主版本号。
            % (\.\d+)?：这是一个可选组，匹配点后跟一个或多个数字，代表次版本号。
            GridStruct = w_load_grid(fin,Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'WRF'; GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CF-1.6') && nc_attrValue_exist(fin,'ecmwf/mars-client/bin/grib_to_netcdf.bin','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'ECMWF'; GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CMEMS','method','START') && nc_attrValue_exist(fin,'marine.copernicus.eu','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'CMEMS'; GridStruct.grid = 'GRID';
    elseif nc_attrValue_exist(fin,'CCMP','method','CONTAINS') && nc_attrValue_exist(fin,'RSS','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'CCMP-RSS'; GridStruct.grid = 'GRID';
        else
            error('Just for WRF, WRF2FVCOM, WW3, FVCOM, ECMWF, CMEMS, CCMP-RSS or Standard now !!!')
        end
        SWITCH.read_var = true;
    elseif endsWith(fin, '.2dm') || endsWith(fin, '.msh') || endsWith(fin, '.14')
        GridStruct = f_load_grid(fin, 'Global');
        GridStruct.ModelName = fin(end-2:end); GridStruct.grid = 'TRI';
        SWITCH.read_var = false;
    else
        warning('No set file format !!! ');
        SWITCH.read_var = false;
    end

    if SWITCH.read_var
        [VarStruct, Ttimes] = read_nc(fin, GridStruct);
    else
        VarStruct = struct('');
        Ttimes = Mdatetime();
    end
           
end


function [VarStruct, Ttimes] = read_nc(fin, GridStruct)
    switch upper(GridStruct.ModelName)
    case 'WW3'
        varList = {'hs', 'dir', 't02', 'lm', 'fp', 'hmaxe', 'cge', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'dir'}))
            [VarStruct.dir_u, VarStruct.dir_v] = calc_sd2uv(1, VarStruct.dir, "ww3");
        end
        if nc_var_exist(fin, 'time')
            Ttimes = Mdatetime(ncdateread(fin, 'time'));
        end
        
    case 'FVCOM'
        varList = {'u', 'v', 'ww', 'temp', 'salinity', 'zeta', 'ua', 'va', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'u', 'v'}))
            [VarStruct.uv_spd, VarStruct.uv_dir] = calc_uv2sd(VarStruct.u, VarStruct.v, "current");
        end
        if all(isfield(VarStruct,{'ua', 'va'}))
            [VarStruct.uva_spd, VarStruct.uva_dir] = calc_uv2sd(VarStruct.ua, VarStruct.va, "current");
        end
        if nc_var_exist(fin, 'Times') || nc_var_exist(fin, 'Itime')
            if nc_var_exist(fin, 'Times')
                ftime = f_load_time(fin, 'Times');
            elseif nc_var_exist(fin, 'Itime')
                ftime = f_load_time(fin);
            end
            Ttimes = Mdatetime(ftime,'Cdatenum');
        else
            Ttimes = Mdatetime();
        end
    case 'WRF2FVCOM'
        varList = {'T2', 'U10', 'V10', 'SLP', 'Precipitation', 'Evaporation', ...
                   'Stress_U', 'Stress_V', 'Net_Heat', 'Shortwave', 'Longwave', ...
                   'Sensible', 'Latent', 'SPQ', 'SAT', 'cloud_cover'};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'U10', 'V10'}))
            [VarStruct.UV10_spd, VarStruct.UV10_dir] = calc_uv2sd(VarStruct.U10, VarStruct.V10, "wind");
        end
        if nc_var_exist(fin, 'Times')
            Times = ncread(fin, 'Times')';
            Ttimes = Mdatetime(Times,'fmt','yyyy-MM-dd_HH:mm:ss');
        end
    case 'WRF'
        varList = {'T2', 'U10', 'V10', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'U10', 'V10'}))
            [VarStruct.UV10_spd, VarStruct.UV10_dir] = calc_uv2sd(VarStruct.U10, VarStruct.V10, "wind");
        end
        if nc_var_exist(fin, 'Times')
            Times = ncread(fin, 'Times')';
            Ttimes = Mdatetime(Times,'fmt','yyyy-MM-dd_HH:mm:ss');
        end
    case 'STANDARD'
        varList = {'wind_U10', 'wind_V10', ...
                   'ua', 'va', ...
                   'salinity_std', 'salinity_sgm', 'salinity_avg', ...
                   'temperature_std', 'temperature_sgm', 'temperature_avg', ...
                   'u_std', 'u_sgm', 'u_avg', ...
                   'v_std', 'v_sgm', 'v_avg', ...
                   'chlo_std', 'chlo_sgm', 'chlo_avg', ...
                   'adt','swh', 'ice', 'aice','tice', ...
                   'tide_u', 'tide_v'};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'ua', 'va'}))
            [VarStruct.uva_spd, VarStruct.uva_dir] = calc_uv2sd(VarStruct.ua, VarStruct.va, "current");
        end
        if all(isfield(VarStruct,{'tide_u', 'tide_v'}))
            [VarStruct.tide_uv_spd, VarStruct.tide_uv_dir] = calc_uv2sd(VarStruct.tide_u, VarStruct.tide_v, "current");
        end
        if all(isfield(VarStruct,{'u_std', 'v_std'}))
            [VarStruct.uv_std_spd, VarStruct.uv_std_dir] = calc_uv2sd(VarStruct.u_std, VarStruct.v_std, "current");
        end
        if nc_var_exist(fin, 'time')
            time = ncdateread(fin, 'time');
            Ttimes = Mdatetime(time);
        else
            Ttimes = Mdatetime();
        end
    case 'ECMWF'
        varList = {'u10', 'v10', '', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'u10', 'v10'}))
            [VarStruct.uv10_spd, VarStruct.uv10_dir] = calc_uv2sd(VarStruct.u10, VarStruct.v10, "wind");
        end
        if nc_var_exist(fin, 'time')
            Ttimes = Mdatetime(ncdateread(fin, 'time'));
        end
    case 'CMEMS'
        varList = {'adt', 'ugos', 'vgos', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'ugos', 'vgos'}))
            [VarStruct.uvgos_spd, VarStruct.uvgos_dir] = calc_uv2sd(VarStruct.ugos, VarStruct.vgos, "current");
        end
        if nc_var_exist(fin, 'time')
            Ttimes = Mdatetime(ncdateread(fin, 'time'));
        end
    case 'CCMP-RSS'
        varList = {'uwnd', 'vwnd', '', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'uwnd', 'vwnd'}))
            [VarStruct.uvwnd_spd, VarStruct.uvwnd_dir] = calc_uv2sd(VarStruct.uwnd, VarStruct.vwnd, "wind");
        end
        if nc_var_exist(fin, 'time')
            Ttimes = Mdatetime(ncdateread(fin, 'time'));
        end

    otherwise
        warning('Want read, but read nothing !!! ');
        VarStruct = struct('');
        Ttimes = Mdatetime(); 
    end
end


function VarStruct = read_var_list(fin,varlist)

    VarStruct = struct('');

    nc_info = ncinfo(fin);
    var_name_nc = {nc_info.Variables.Name};
    var_name_pub = intersect(varlist,var_name_nc,'stable');
    for iname = var_name_pub
        VarStruct(1).(iname{1}) = ncread(fin, iname{1});
    end
end
