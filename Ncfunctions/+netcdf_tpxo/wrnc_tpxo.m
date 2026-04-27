function rtn = wrnc_tpxo(NC, Lon, Lat, time, options)
    %       This function is used to write the tide current (u/v/zeta) to the netcdf file;
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % Parameter:
    %       NC:             netCDF                  || required: one of || type: int/char
    %           ncid:       netcdf file id                              || type: int        || example: 1
    %           ncname:     netcdf file name                            || type: char       || example: 'tide.nc'
    %       Lon:             longitude              || required: True   || type: double     || example: [120.5, 121.5]
    %       Lat:             latitude               || required: True   || type: double     || example: [30.5, 31.5]
    %       time:            time                   || required: True   || type: double     || format: posixtime
    %       options.
    %           U:          u                       || required: True   || type: double     || format: matrix, 3D
    %           V:          v                       || required: True   || type: double     || format: matrix, 3D
    %           Zeta:       zeta                    || required: True   || type: double     || format: matrix, 3D
    %           dtype:      data type of variable   || required: False  || type: namevalue  || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created,                                        by Christmas;
    %       2024-01-10:     Fixed, auto for tide current or tide level,     by Christmas;
    %       2026-03-31:     Added ncwrite support,                          by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_tpxo.wrnc_tpxo(ncid,Lon,Lat,time,'U',U,'V',V,'Zeta',Zeta)
    %       netcdf_tpxo.wrnc_tpxo(ncid,Lon,Lat,time,'U',U,'V',V)
    %       netcdf_tpxo.wrnc_tpxo(ncid,Lon,Lat,time,'Zeta',Zeta)
    %       netcdf_tpxo.wrnc_tpxo('tide.nc',Lon,Lat,time,'U',U,'V',V,'Zeta',Zeta)
    %       netcdf_tpxo.wrnc_tpxo('tide.nc',Lon,Lat,time,'U',U,'V',V)
    %       netcdf_tpxo.wrnc_tpxo('tide.nc',Lon,Lat,time,'Zeta',Zeta)
    %       netcdf_tpxo.wrnc_tpxo('tide.nc',Lon,Lat,time,'U',U,'V',V,'Zeta',Zeta)
    %       netcdf_tpxo.wrnc_tpxo('tide.nc',Lon,Lat,time,'U',U,'V',V,'Zeta',Zeta,'dtype','int16')
    % =================================================================================================================

    arguments (Input)
        % NC can be int or char, but must be one of them
        NC {mustBeValidNC}
        Lon (:, 1) {mustBeNumeric}
        Lat (:, 1) {mustBeNumeric}
        time (:, 1) {mustBeNumeric}
        options.U (:, :, :) {mustBeNumeric}
        options.V (:, :, :) {mustBeNumeric}
        options.Zeta (:, :, :) {mustBeNumeric}
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

    SWITCH = struct('current', false, 'zeta', false);

    if isfield(options, 'U') && isfield(options, 'V')
        SWITCH.current = true;
        U = options.U;
        V = options.V;
    end

    if isfield(options, 'Zeta')
        SWITCH.zeta = true;
        Zeta = options.Zeta;
    end

    if ~SWITCH.current && ~SWITCH.zeta
        error('No data to write')
    end

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1 / mean(diff(Lon), 'omitnan'), '%2.f');
    S_name = standard_filename('tide', Lon, Lat, time_filename, ResName); % 标准文件名
    osprint2('INFO', ['Transfor --> ', S_name])

    GA_start_date = char(datetime("now", "Format", "yyyy-MM-dd_HH:mm:ss"));

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

            if SWITCH.current
                u_id = netcdf.defVar(ncid, 'tide_u', 'NC_FLOAT', [londimID, latdimID, timedimID]); % u
                v_id = netcdf.defVar(ncid, 'tide_v', 'NC_FLOAT', [londimID, latdimID, timedimID]); % v
                netcdf.defVarFill(ncid, u_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值
                netcdf.defVarFill(ncid, v_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值
                netcdf.defVarDeflate(ncid, u_id, true, true, 5)
                netcdf.defVarDeflate(ncid, v_id, true, true, 5)
            end

            if SWITCH.zeta
                h_id = netcdf.defVar(ncid, 'tide_h', 'NC_FLOAT', [londimID, latdimID, timedimID]); % h
                netcdf.defVarFill(ncid, h_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值
                netcdf.defVarDeflate(ncid, h_id, true, true, 5)
            end

            netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
            netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
            netcdf.defVarDeflate(ncid, time_id, true, true, 5)
            netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

            % -----
            netcdf.endDef(ncid); % 结束nc文件定义
            % 将数据放入相应的变量
            netcdf.putVar(ncid, lon_id, Lon); % 经度
            netcdf.putVar(ncid, lat_id, Lat); % 纬度
            netcdf.putVar(ncid, time_id, 0, length(time), time); % 时间
            netcdf.putVar(ncid, TIME_id, [0, 0], [size(char(TIME), 2), size(char(TIME), 1)], char(TIME)'); % 时间char

            if SWITCH.current
                netcdf.putVar(ncid, u_id, [0, 0, 0], [size(U, 1), size(U, 2), size(U, 3)], U); % u
                netcdf.putVar(ncid, v_id, [0, 0, 0], [size(V, 1), size(V, 2), size(V, 3)], V); % v
            end

            if SWITCH.zeta
                netcdf.putVar(ncid, h_id, [0, 0, 0], [size(Zeta, 1), size(Zeta, 2), size(Zeta, 3)], Zeta); % h
            end

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

            netcdf.putAtt(ncid, TIME_id, 'reference', TIME_reference); % 时间char
            netcdf.putAtt(ncid, TIME_id, 'start_date', TIME_start_date); % 时间char
            netcdf.putAtt(ncid, TIME_id, 'end_date', TIME_end_date); % 时间char

            if SWITCH.current
                % ATTRS.tide_u.key = ATTRS.tide_u.value; % u
                for key = fieldnames(ATTRS.tide_u)'
                    netcdf.putAtt(ncid, u_id, key{1}, ATTRS.tide_u.(key{1}));
                end

                % ATTRS.tide_v.key = ATTRS.tide_v.value; % v
                for key = fieldnames(ATTRS.tide_v)'
                    netcdf.putAtt(ncid, v_id, key{1}, ATTRS.tide_v.(key{1}));
                end

            end

            if SWITCH.zeta
                % ATTRS.tide_h.key = ATTRS.tide_h.value; % h
                for key = fieldnames(ATTRS.tide_h)'
                    netcdf.putAtt(ncid, h_id, key{1}, ATTRS.tide_h.(key{1}));
                end

            end

            varid_GA = netcdf.getConstant('NC_GLOBAL');
            % ATTRS.GLOBAL.key = ATTRS.GLOBAL.value; % global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                netcdf.putAtt(ncid, varid_GA, key{1}, ATTRS.GLOBAL.(key{1}));
            end

            netcdf.putAtt(ncid, varid_GA, 'product_name', S_name); % 文件名
            netcdf.putAtt(ncid, varid_GA, 'WriteProgram', sprintf('netcdf_tpxo:%s_V%s', mfilename, Version)); % 写入程序信息
            netcdf.putAtt(ncid, varid_GA, 'start', GA_start_date); % 起报时间
            netcdf.putAtt(ncid, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
            netcdf.putAtt(ncid, varid_GA, 'Mbaysalt_version', ver('Mbaysalt').Version); % Mbaysalt版本信息
            netcdf.putAtt(ncid, varid_GA, 'Mbaysalt_gitHash', getGitHash(ST_Mbaysalt('cd'), 'long')); % Mbaysalt git hash
            netcdf.putAtt(ncid, varid_GA, 'MATLAB_version', version); % MATLAB版本信息
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

            if SWITCH.current
                [scale_factor, add_offset] = calc_scale_offset(U, dtype);
                nccreate(ncname, 'tide_u', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.tide_u)'
                    ncwriteatt(ncname, 'tide_u', key{1}, ATTRS.tide_u.(key{1}));
                end

                ncwriteatt(ncname, 'tide_u', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'tide_u', 'add_offset', add_offset);
                ncwrite(ncname, 'tide_u', U, [1, 1, 1]);

                [scale_factor, add_offset] = calc_scale_offset(V, dtype);
                nccreate(ncname, 'tide_v', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.tide_v)'
                    ncwriteatt(ncname, 'tide_v', key{1}, ATTRS.tide_v.(key{1}));
                end

                ncwriteatt(ncname, 'tide_v', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'tide_v', 'add_offset', add_offset);
                ncwrite(ncname, 'tide_v', V, [1, 1, 1]);
            end

            if SWITCH.zeta
                [scale_factor, add_offset] = calc_scale_offset(Zeta, dtype);
                nccreate(ncname, 'tide_h', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.tide_h)'
                    ncwriteatt(ncname, 'tide_h', key{1}, ATTRS.tide_h.(key{1}));
                end

                ncwriteatt(ncname, 'tide_h', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'tide_h', 'add_offset', add_offset);
                ncwrite(ncname, 'tide_h', Zeta, [1, 1, 1]);
            end

            varid_GA = netcdf.getConstant('NC_GLOBAL');
            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                ncwriteatt(ncname, varid_GA, key{1}, ATTRS.GLOBAL.(key{1}));
            end

            ncwriteatt(ncname, varid_GA, 'product_name', S_name);
            ncwriteatt(ncname, varid_GA, 'WriteProgram', sprintf('netcdf_tpxo:%s_V%s', mfilename, Version));
            ncwriteatt(ncname, varid_GA, 'start', GA_start_date);
            ncwriteatt(ncname, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]);
            ncwriteatt(ncname, varid_GA, 'Mbaysalt_version', ver('Mbaysalt').Version);
            ncwriteatt(ncname, varid_GA, 'Mbaysalt_gitHash', getGitHash(ST_Mbaysalt('cd'), 'long'));
            ncwriteatt(ncname, varid_GA, 'MATLAB_version', version);

    end

    rtn.Version = Version;
    rtn.Method = Method;

    return;
end

function mustBeValidNC(x)

    if ~(isnumeric(x) || ischar(x) || isstring(x))
        error('NC must be a numeric ncid, char filename, or string filename.');
    end

end
