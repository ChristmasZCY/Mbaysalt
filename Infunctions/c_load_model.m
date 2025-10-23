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
    %       2024-04-03:     Created,                            by Christmas; 
    %       2024-05-13:     Added calculating uv2sd, sd2uv,     by Christmas;
    %       2025-02-14:     Recorrect match WRF file,           by Christmas;
    %       2025-04-11:     Added for FVCOM-MET,                by Christmas;
    %       2025-09-01:     Added TIME format for WRF2FVCOM,    by Christmas;
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
                GridStruct = f_load_grid(lon, lat, nv, 'MaxLon', MaxLon, 'PLOT');
                GridStruct.grid = 'TRI';
            else
                GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
                GridStruct.grid = 'GRID';
            end
            GridStruct.ModelName = 'WW3'; 
        elseif nc_attrName_exist(fin, 'product_name', 'method','START')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'Standard'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin, 'FVCOM', 'method','START')
            GridStruct = f_load_grid(fin, Global, "Coordinate", Coordinate, 'MaxLon', MaxLon, 'PLOT');
            GridStruct.ModelName = 'FVCOM'; 
            GridStruct.grid = 'TRI';
        elseif nc_attrValue_exist(fin, 'fvcom grid (unstructured) surface forcing', 'method','CONTAINS')
            GridStruct = f_load_grid(fin, Global, "Coordinate", Coordinate, 'MaxLon', MaxLon, 'PLOT');
            GridStruct.ModelName = 'FVCOM-MET'; 
            GridStruct.grid = 'TRI';
        elseif nc_attrValue_exist(fin, 'wrf2fvcom version', 'method','START')
            GridStruct = w_load_grid(fin, Global, "Coordinate", Coordinate, 'MaxLon', MaxLon, 'PLOT');
            GridStruct.ModelName = 'WRF2FVCOM'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'WRF\s*(V\d+(\.\d+)?)?\s*MODEL')
        elseif nc_attrValue_exist(fin,'WRF\s*(V\d+(\.\d+)*)?\s*MODEL')
            % WRF\s*(V\d+(\.\d+)?)?\s*MODEL --> 匹配 WRF V4.4 MODEL 不匹配 WRF V4.6.1 MODEL
            % WRF\s*(V\d+(\.\d+)?)?\s*MODEL --> 匹配 WRF V4.4 MODEL   匹配 WRF V4.6.1 MODEL
            % 匹配{"WRF V4.4 MODEL", "WRF V4.1 MODEL", "WRF V1.2 MODEL", "WRF MODEL", "WRFMODEL"};
            % \s*       : 匹配零个或多个空白字符。
            % V\d+      : 匹配 "V" + 一个或多个数字（如 "V4"）
            % (\.\d+)*  : 匹配 零个或多个 ".数字"（如 ".6"、".1"）。
            % \s*MODEL  : 匹配 "MODEL" 及其前后的 空格
            GridStruct = w_load_grid(fin,Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'WRF'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CF-1.6') && nc_attrValue_exist(fin,'ecmwf/mars-client/bin/grib_to_netcdf.bin','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'ECMWF'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CF-1.7') && nc_attrValue_exist(fin,'European Centre for Medium-Range Weather Forecasts','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'ECMWF'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CMEMS','method','START') && nc_attrValue_exist(fin,'marine.copernicus.eu','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'CMEMS'; 
            GridStruct.grid = 'GRID';
        elseif nc_attrValue_exist(fin,'CCMP','method','CONTAINS') && nc_attrValue_exist(fin,'RSS','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'CCMP-RSS'; 
            GridStruct.grid = 'GRID';
        elseif  nc_attrValue_exist(fin,'COARDS','method','STRCMP') && nc_attrValue_exist(fin,'created by wgrib2','method','CONTAINS')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'GFS-GRIB'; 
            GridStruct.grid = 'GRID';
        elseif  nc_attrValue_exist(fin,'NCAR','method','START') && nc_attrValue_exist(fin,'CF-1.5','method','STRCMP')
            lon = ncread(fin, 'lon');
            lat = ncread(fin, 'lat');
            GridStruct = w_load_grid(lon, lat, Global, 'MaxLon', MaxLon);
            GridStruct.ModelName = 'NCAR-FNL'; 
            GridStruct.grid = 'GRID';
        else
            error('Just for WRF, WRF2FVCOM, WW3, FVCOM, FVCOM-MET, ECMWF, CMEMS, CCMP-RSS, GFS-GRIB, NCAR-FNL or Standard now !!!')
        end
        SWITCH.read_var = true;
    elseif endsWith(fin, '.2dm') || endsWith(fin, '.msh') || endsWith(fin, '.14')
        GridStruct = f_load_grid(fin, 'Global', 'PLOT');
        GridStruct.ModelName = fin(end-2:end); 
        GridStruct.grid = 'TRI';
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

    if ~isfield(GridStruct, 'PLOT')
        switch GridStruct.grid
        case 'TRI'
            GridStruct.PLOT.range           = @(varargin) f_2d_range(GridStruct, varargin{:});
            GridStruct.PLOT.mesh            = @(varargin) f_2d_mesh(GridStruct, varargin{:});
            GridStruct.PLOT.coast           = @(varargin) f_2d_coast(GridStruct, varargin{:});
            GridStruct.PLOT.image           = @(varargin) f_2d_image(GridStruct, varargin{:});
            GridStruct.PLOT.contour         = @(varargin) f_2d_contour(GridStruct, varargin{:});
            GridStruct.PLOT.boundary        = @(varargin) f_2d_boundary(GridStruct, varargin{:});
            GridStruct.PLOT.mask_boundary   = @(varargin) f_2d_mask_boundary(GridStruct, varargin{:});
            GridStruct.PLOT.lonlat          = @(varargin) f_2d_lonlat(GridStruct, varargin{:});
            GridStruct.PLOT.cell            = @(varargin) f_2d_cell(GridStruct, varargin{:});
        case 'GRID'
            GridStruct.PLOT.mesh            = @(varargin) w_2d_mesh(GridStruct, varargin{:});
            GridStruct.PLOT.coast           = @(varargin) w_2d_coast(GridStruct, varargin{:});
            GridStruct.PLOT.boundary        = @(varargin) w_2d_boundary(GridStruct, varargin{:});
            GridStruct.PLOT.image           = @(varargin) w_2d_image(GridStruct, varargin{:});
            GridStruct.PLOT.mask_boundary   = @(varargin) w_2d_mask_boundary(GridStruct, varargin{:});
            GridStruct.PLOT.contour         = @(varargin) w_2d_contour(GridStruct, varargin{:});
        end
    end

    return

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
        varList = {'u', 'v', 'ww', 'temp', 'salinity', 'zeta', 'ua', 'va', 'aice', 'vice', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'u', 'v'}))
            [VarStruct.uv_spd, VarStruct.uv_dir] = calc_uv2sd(VarStruct.u, VarStruct.v, "current");
        end
        if all(isfield(VarStruct,{'ua', 'va'}))
            [VarStruct.uva_spd, VarStruct.uva_dir] = calc_uv2sd(VarStruct.ua, VarStruct.va, "current");
        end
        if nc_var_exist(fin, 'Times')
            ftime = f_load_time(fin, 'Times');
        elseif nc_var_exist(fin, 'Itime')
            ftime = f_load_time(fin);
        else
            Ttimes = Mdatetime();
            return
        end
        Ttimes = Mdatetime(ftime,'Cdatenum');
    case 'FVCOM-MET'
        varList = {'uwind_speed', 'vwind_speed', 'air_pressure'};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'uwind_speed', 'vwind_speed'}))
            [VarStruct.uvwind_speed, VarStruct.uvwind_dir] = calc_uv2sd(VarStruct.uwind_speed, VarStruct.vwind_speed, "wind");
        end
        if nc_var_exist(fin, 'Times')
            ftime = f_load_time(fin, 'Times');
        elseif nc_var_exist(fin, 'Itime')
            ftime = f_load_time(fin);
        else
            Ttimes = Mdatetime();
            return
        end
        Ttimes = Mdatetime(ftime,'Cdatenum');
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
            try
                Ttimes = Mdatetime(Times,'fmt','yyyy-MM-dd_HH:mm:ss');
            catch ME1
                Ttimes = Mdatetime(Times,'fmt',"yyyy-MM-dd'T'HH:mm:ss");
            end
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
        varList = {'wind_U10', 'wind_V10', 'slp', ...
                   'precipitation', 'temperature', ...
                   'ua', 'va', ...
                   'salinity_std', 'salinity_sgm', 'salinity_avg', ...
                   'temperature_std', 'temperature_sgm', 'temperature_avg', ...
                   'u_std', 'u_sgm', 'u_avg', ...
                   'v_std', 'v_sgm', 'v_avg', ...
                   'chlo_std', 'chlo_sgm', 'chlo_avg', ...
                   'NO3_std', 'NO3_sgm', 'NO3_avg', ...
                   'pH_std', 'pH_sgm', 'pH_avg', ...
                   'adt','swh', 'ice', 'aice','tice', ...
                   'casfco2', 'bathy', ...
                   'tide_u', 'tide_v', 'tide_h'};
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
        if all(isfield(VarStruct,{'wind_U10', 'wind_V10'}))
            [VarStruct.UV10_spd, VarStruct.UV10_dir] = calc_uv2sd(VarStruct.wind_U10, VarStruct.wind_V10, "wind");
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
        elseif nc_var_exist(fin, 'valid_time')
            Ttimes = Mdatetime(ncdateread(fin, 'valid_time'));
        end
    case 'CMEMS'
        varList = {'adt', 'ugos', 'vgos', 'uo', 'vo', 'so', 'zos', 'thetao', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'ugos', 'vgos'}))
            [VarStruct.uvgos_spd, VarStruct.uvgos_dir] = calc_uv2sd(VarStruct.ugos, VarStruct.vgos, "current");
        end
        if all(isfield(VarStruct,{'uo', 'vo'}))
            [VarStruct.uvo_spd, VarStruct.uvo_dir] = calc_uv2sd(VarStruct.uo, VarStruct.vo, "current");
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
    case 'GFS-GRIB'
        varList = {'UGRD_10maboveground', 'VGRD_10maboveground', 'PRES_surface', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'UGRD_10maboveground', 'VGRD_10maboveground'}))
            [VarStruct.UVGRD_10maboveground_spd, VarStruct.UVGRD_10maboveground_dir] = calc_uv2sd(VarStruct.UGRD_10maboveground, VarStruct.VGRD_10maboveground, "wind");
        end
        if nc_var_exist(fin, 'time')
            Ttimes = Mdatetime(ncdateread(fin, 'time'));
        end
    case 'NCAR-FNL'
        varList = {'U_GRD_L103', 'V_GRD_L103', '', '', '', '', '', '', '', '', ''};
        VarStruct = read_var_list(fin, varList);
        if all(isfield(VarStruct,{'U_GRD_L103', 'V_GRD_L103'}))
            [VarStruct.UV_GRD_L103_spd, VarStruct.UV_GRD_L103_dir] = calc_uv2sd(VarStruct.U_GRD_L103, VarStruct.V_GRD_L103, "wind");
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
