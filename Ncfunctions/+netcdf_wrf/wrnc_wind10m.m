function rtn = wrnc_wind10m(NC, Lon, Lat, time, U10, V10, options)
    %       This function is used to write wind speed at 10m to netcdf file.
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % parameter:
    %       NC:             netCDF                  || required: one of || type: int/char
    %           ncid:       netcdf file id                              || type: int        || example: 1
    %           ncname:     netcdf file name                            || type: char       || example: 'tide.nc'
    %       Lon:             longitude              || required: True   || type: double     || example: [120.5, 121.5]
    %       Lat:             latitude               || required: True   || type: double     || example: [30.5, 31.5]
    %       time:            time                   || required: True   || type: double     || format: posixtime
    %       U10:             wind speed at 10m      || required: True   || type: double     || format: matrix
    %       V10:             wind speed at 10m      || required: True   || type: double     || format: matrix
    %       options:         optional parameters
    %           GA:          global attribute       || required: False  || type: struct     || example: struct('GA_START_DATE','2020-01-01 00:00:00')
    %           conf:        configuration struct   || required: False  || type: struct     || example: struct
    %           dtype:       data type of variable  || required: False  || type: namevalue  || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-12-24:     Created,                by Christmas;
    %       2026-03-31:     Added ncwrite support,  by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'conf',conf)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'),'conf',conf)
    %       netcdf_wrf.wrnc_wind10m('wind.nc',,Lon,Lat,time,U10,V10)
    %       netcdf_wrf.wrnc_wind10m('wind.nc',,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_wind10m('wind.nc',,Lon,Lat,time,U10,V10，'conf',conf)
    %       netcdf_wrf.wrnc_wind10m('wind.nc',,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'),'conf',conf)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'dtype', 'int16')
    % =================================================================================================================

    arguments (Input)
        % NC can be int or char, but must be one of them
        NC {mustBeValidNC}
        Lon {mustBeNumeric}
        Lat {mustBeNumeric}
        time {mustBeNumeric}
        U10 {mustBeNumeric}
        V10 {mustBeNumeric}
        options.GA struct = struct()
        options.conf {struct} = struct()
        options.dtype char {mustBeMember(options.dtype, {'int16', 'int32', 'int8'})} = 'int16'
    end

    if isnumeric(NC)
        ncid = NC;
        Version = '1.3 (netcdf.putVar)';
        Method = 'LowLevel';
        cleanupObj = onCleanup(@() netcdf.close(ncid));
    elseif ischar(NC) || isstring(NC)
        ncname = NC;
        Version = '2.0 (ncwrite)';
        Method = 'HighLevel';
        dtype = options.dtype;
    end

    GA = options.GA;
    conf = options.conf;
    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1 / mean(diff(Lon), 'omitnan'), '%2.f');
    S_name = standard_filename('wind', Lon, Lat, time_filename, ResName); % 标准文件名
    osprint2('INFO', ['Transfor --> ', S_name])

    if ~isempty(GA)

        if ~isfield(GA, 'START_DATE')
            GA.START_DATE = char(datetime("now", "Format", "yyyy-MM-dd_HH:mm:ss"));
        end

    end

    switch Method
        case 'LowLevel'
            % 定义维度
            londimID = netcdf.defDim(ncid, 'longitude', length(Lon)); % 定义lon维度
            latdimID = netcdf.defDim(ncid, 'latitude', length(Lat)); % 定义lat纬度
            timedimID = netcdf.defDim(ncid, 'time', netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
            TIMEdimID = netcdf.defDim(ncid, 'DateStr', size(char(TIME), 2)); % 定义TIME维度

            % 定义变量
            lon_id = netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID); % 经度
            lat_id = netcdf.defVar(ncid, 'latitude', 'NC_FLOAT', latdimID); % 纬度
            time_id = netcdf.defVar(ncid, 'time', 'double', timedimID); % 时间
            TIME_id = netcdf.defVar(ncid, 'TIME', 'NC_CHAR', [TIMEdimID, timedimID]); % 时间char
            U10_id = netcdf.defVar(ncid, 'wind_U10', 'NC_FLOAT', [londimID, latdimID, timedimID]); % U10
            V10_id = netcdf.defVar(ncid, 'wind_V10', 'NC_FLOAT', [londimID, latdimID, timedimID]); % V10

            netcdf.defVarFill(ncid, U10_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
            netcdf.defVarFill(ncid, V10_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值

            netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
            netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
            netcdf.defVarDeflate(ncid, time_id, true, true, 5)
            netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
            netcdf.defVarDeflate(ncid, U10_id, true, true, 5)
            netcdf.defVarDeflate(ncid, V10_id, true, true, 5)

            % -----
            netcdf.endDef(ncid); % 结束nc文件定义
            % 将数据放入相应的变量
            netcdf.putVar(ncid, lon_id, Lon); % 经度
            netcdf.putVar(ncid, lat_id, Lat); % 纬度
            netcdf.putVar(ncid, time_id, 0, length(time), time); % 时间
            netcdf.putVar(ncid, TIME_id, [0, 0], [size(char(TIME), 2), size(char(TIME), 1)], char(TIME)'); % 时间char
            netcdf.putVar(ncid, U10_id, [0, 0, 0], [size(U10, 1), size(U10, 2), size(U10, 3)], U10); % U10
            netcdf.putVar(ncid, V10_id, [0, 0, 0], [size(V10, 1), size(V10, 2), size(V10, 3)], V10); % V10

            % -----
            netcdf.reDef(ncid); % 使打开的nc文件重新进入定义模式
            % 添加变量属性
            % ATTRS.longitude.key = ATTRS.longitude.value; % 经度
            for key = fieldnames(ATTRS.longitude)'
                netcdf.putAtt(ncid, lon_id, key{1}, ATTRS.longitude.(key{1}));
            end

            netcdf.putAtt(ncid, lon_id, 'westernmost', num2str(min(Lon, [], "all"), '%3.2f')); % 经度
            netcdf.putAtt(ncid, lon_id, 'easternmost', num2str(max(Lon, [], "all"), '%3.2f')); % 经度

            % ATTRS.latitude.key = ATTRS.latitude.value; % 纬度
            for key = fieldnames(ATTRS.latitude)'
                netcdf.putAtt(ncid, lat_id, key{1}, ATTRS.latitude.(key{1}));
            end

            netcdf.putAtt(ncid, lat_id, 'southernmost', num2str(min(Lat, [], "all"), '%2.2f')); % 纬度
            netcdf.putAtt(ncid, lat_id, 'northernmost', num2str(max(Lat, [], "all"), '%2.2f')); % 纬度

            % ATTRS.time.key = ATTRS.time.value; % 时间
            for key = fieldnames(ATTRS.time)'
                netcdf.putAtt(ncid, time_id, key{1}, ATTRS.time.(key{1}));
            end

            % ATTRS.TIME.key = ATTRS.TIME.value; % 时间char
            for key = fieldnames(ATTRS.TIME)'
                netcdf.putAtt(ncid, TIME_id, key{1}, ATTRS.TIME.(key{1}));
            end

            netcdf.putAtt(ncid, TIME_id, 'reference_time', TIME_reference); % 时间char
            netcdf.putAtt(ncid, TIME_id, 'start_time', TIME_start_date); % 时间char
            netcdf.putAtt(ncid, TIME_id, 'end_time', TIME_end_date); % 时间char

            for key = fieldnames(ATTRS.wind_U10)'
                netcdf.putAtt(ncid, U10_id, key{1}, ATTRS.wind_U10.(key{1}));
            end

            for key = fieldnames(ATTRS.wind_V10)'
                netcdf.putAtt(ncid, V10_id, key{1}, ATTRS.wind_V10.(key{1}));
            end

            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), key{1}, ATTRS.GLOBAL.(key{1}));
            end

            netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'product_name', S_name); % 文件名
            netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'WriteProgram', ['netcdf_wrf:', mfilename, ' V', Version]); % 写入程序信息

            if class(conf) == "struct" && isfield(conf, "P_Source")
                netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'source', conf.P_Source); % 数据源
            end

            netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'start', GA.START_DATE); % 起报时间
            netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
            netcdf.close(ncid); % 关闭nc文件

        case 'HighLevel'
            ncname = getPath(ncname);
            rmfiles(ncname);
            % 高级接口：定义变量和维度
            nccreate(ncname, 'longitude', ...
                'Dimensions', {'longitude', length(Lon)}, ...
                'Datatype', 'single', ...
                'Format', 'netcdf4', ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.longitude)'
                ncwriteatt(ncname, 'longitude', key{1}, ATTRS.longitude.(key{1}));
            end

            ncwriteatt(ncname, 'longitude', 'westernmost', num2str(min(Lon, [], "all"), '%3.2f'));
            ncwriteatt(ncname, 'longitude', 'easternmost', num2str(max(Lon, [], "all"), '%3.2f'));
            ncwrite(ncname, 'longitude', Lon);

            nccreate(ncname, 'latitude', ...
                'Dimensions', {'latitude', length(Lat)}, ...
                'Datatype', 'single', ...
                'Format', 'netcdf4', ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.latitude)'
                ncwriteatt(ncname, 'latitude', key{1}, ATTRS.latitude.(key{1}));
            end

            ncwriteatt(ncname, 'latitude', 'southernmost', num2str(min(Lat, [], "all"), '%2.2f'));
            ncwriteatt(ncname, 'latitude', 'northernmost', num2str(max(Lat, [], "all"), '%2.2f'));
            ncwrite(ncname, 'latitude', Lat);

            dtype_time = calc_dtype(time, 'HighLevel');
            nccreate(ncname, 'time', ...
                'Dimensions', {'time', Inf}, ...
                'Datatype', dtype_time, ...
                'Format', 'netcdf4', ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            clear dtype_time;

            for key = fieldnames(ATTRS.time)'
                ncwriteatt(ncname, 'time', key{1}, ATTRS.time.(key{1}));
            end

            ncwrite(ncname, 'time', time);
            nccreate(ncname, 'TIME', ...
                'Dimensions', {'DateStr', size(char(TIME), 2), 'time', Inf}, ...
                'Datatype', 'char', ...
                'Format', 'netcdf4', ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.TIME)'
                ncwriteatt(ncname, 'TIME', key{1}, ATTRS.TIME.(key{1}));
            end

            ncwriteatt(ncname, 'TIME', 'reference', TIME_reference);
            ncwriteatt(ncname, 'TIME', 'start_date', TIME_start_date);
            ncwriteatt(ncname, 'TIME', 'end_date', TIME_end_date);
            ncwrite(ncname, 'TIME', char(TIME)', [1, 1]);

            [scale_factor, add_offset] = calc_scale_offset(U10, dtype);
            nccreate(ncname, 'wind_U10', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.wind_U10)'
                ncwriteatt(ncname, 'wind_U10', key{1}, ATTRS.wind_U10.(key{1}));
            end

            ncwriteatt(ncname, 'wind_U10', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'wind_U10', 'add_offset', add_offset);
            ncwrite(ncname, 'wind_U10', U10, [1, 1, 1]);

            [scale_factor, add_offset] = calc_scale_offset(V10, dtype);
            nccreate(ncname, 'wind_V10', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.wind_V10)'
                ncwriteatt(ncname, 'wind_V10', key{1}, ATTRS.wind_V10.(key{1}));
            end

            ncwriteatt(ncname, 'wind_V10', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'wind_V10', 'add_offset', add_offset);
            ncwrite(ncname, 'wind_V10', V10, [1, 1, 1]);

            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                ncwriteatt(ncname, '/', key{1}, ATTRS.GLOBAL.(key{1}));
            end

            ncwriteatt(ncname, '/', 'product_name', S_name);
            ncwriteatt(ncname, '/', 'WriteProgram', ['netcdf_wrf:', mfilename, ' V', Version]);

            if class(conf) == "struct" && isfield(conf, "P_Source")
                ncwriteatt(ncname, '/', 'source', conf.P_Source);
            end

            ncwriteatt(ncname, '/', 'start', GA.START_DATE);
            ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]);

    end

    rtn.Version = Version;
    rtn.Method = Method;

end

function mustBeValidNC(x)

    if ~(isnumeric(x) || ischar(x) || isstring(x))
        error('NC must be a numeric ncid, char filename, or string filename.');
    end

end
