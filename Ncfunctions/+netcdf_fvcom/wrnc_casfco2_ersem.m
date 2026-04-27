function rtn = wrnc_casfco2_ersem(NC, Lon, Lat, time, Casfco2, varargin)
    %       This function is used to write the carbonate air-sea flux of CO2 into the netcdf file.
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % Parameter:
    %       NC:             netCDF                          || required: one of || type: int/char
    %           ncid:       netcdf file id                                      || type: int       || example: 1
    %           ncname:     netcdf file name                                    || type: char      || example: 'tide.nc'
    %       Lon:             longitude                      || required: True   || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                       || required: True   || type: double    || format: [30.5, 31.5]
    %       time:            time                           || required: True   || type: double    || format: posixtime
    %       Casfco2:         carbonate air-sea flux of CO2  || required: True   || type: double    || format: matrix
    %       varargin:        optional parameters
    %           conf:        configuration struct           || required: False  || type: namevalue || format: struct
    %           INFO:        Whether print msg              || required: False  || type: flag      || format: 'INFO'
    %           Text_len:    Length of msg str              || required: False  || type: namevalue || format: 'Text_len',45
    %           dtype:       data type of variable          || required: False  || type: namevalue || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-12-29:     Created,                by Christmas;
    %       2026-03-31:     Added ncwrite support,  by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,'dtype','int16')
    % =================================================================================================================

    varargin = read_varargin(varargin, {'conf'}, {struct('')});
    varargin = read_varargin2(varargin, {'INFO'});
    varargin = read_varargin(varargin, {'Text_len'}, {false});
    varargin = read_varargin(varargin, {'dtype'}, {'int16'});

    if isnumeric(NC)
        ncid = NC;
        Version = '1.3 (netcdf.putVar)';
        Method = 'LowLevel';
        cleanupObj = onCleanup(@() netcdf.close(ncid));
    elseif ischar(NC) || isstring(NC)
        ncname = NC;
        Version = '2.0 (ncwrite)';
        Method = 'HighLevel';
    end

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1 / mean(diff(Lon), "omitnan"), '%2.f');
    S_name = standard_filename('casfco2', Lon, Lat, time_filename, ResName); % 标准文件名

    if ~isempty(INFO)

        if ~Text_len
            osprint2('INFO', ['Transfor --> ', S_name]);
        else
            osprint2('INFO', [pad('Transfor ', Text_len, 'right'), '--> ', S_name]);
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
            casfco2_id = netcdf.defVar(ncid, 'casfco2', 'NC_FLOAT', [londimID, latdimID, timedimID]); % casfco2

            netcdf.defVarFill(ncid, casfco2_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值

            netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
            netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
            netcdf.defVarDeflate(ncid, time_id, true, true, 5)
            netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
            netcdf.defVarDeflate(ncid, casfco2_id, true, true, 5)

            % -----
            netcdf.endDef(ncid); % 结束nc文件定义
            % 将数据放入相应的变量
            netcdf.putVar(ncid, lon_id, Lon); % 经度
            netcdf.putVar(ncid, lat_id, Lat); % 纬度
            netcdf.putVar(ncid, time_id, 0, length(time), time); % 时间
            netcdf.putVar(ncid, TIME_id, [0, 0], [size(char(TIME), 2), size(char(TIME), 1)], char(TIME)'); % 时间char
            netcdf.putVar(ncid, casfco2_id, [0, 0, 0], [length(Lon), length(Lat), length(time)], Casfco2); % CASFco2

            % -----
            netcdf.reDef(ncid); % 使打开的nc文件重新进入定义模式
            % 添加变量属性
            % ATTRS.longitude.key = ATTRS.longitude.value; % 经度
            for key = fieldnames(ATTRS.longitude)'
                netcdf.putAtt(ncid, lon_id, key{1}, ATTRS.longitude.(key{1}));
            end % 经度

            netcdf.putAtt(ncid, lon_id, 'westernmost', num2str(min(Lon, [], "all"), '%3.2f')); % 经度
            netcdf.putAtt(ncid, lon_id, 'easternmost', num2str(max(Lon, [], "all"), '%3.2f')); % 经度

            % ATTRS.latitude.key = ATTRS.latitude.value; % 纬度
            for key = fieldnames(ATTRS.latitude)'
                netcdf.putAtt(ncid, lat_id, key{1}, ATTRS.latitude.(key{1}));
            end % 纬度

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

            % ATTRS.casfco2.key = ATTRS.casfco2.value; % CASFco2
            for key = fieldnames(ATTRS.casfco2)'
                netcdf.putAtt(ncid, casfco2_id, key{1}, ATTRS.casfco2.(key{1}));
            end % CASFco2

            netcdf.putAtt(ncid, casfco2_id, 'clim', [-300, 300])

            varid_GA = netcdf.getConstant('NC_GLOBAL');
            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                netcdf.putAtt(ncid, varid_GA, key{1}, ATTRS.GLOBAL.(key{1}));
            end % global attribute

            if ~isempty(conf)
                NC = read_NC(conf);
                fields = fieldnames(NC);

                for iname = 1:length(fields)
                    %  netcdf.putAtt(ncid, varid_GA, 'source', conf.P_Source); % 数据源
                    netcdf.putAtt(ncid, varid_GA, fields{iname}, NC.(fields{iname}));
                end

            end

            netcdf.putAtt(ncid, varid_GA, 'product_name', S_name); % 文件名
            netcdf.putAtt(ncid, varid_GA, 'WriteProgram', sprintf('netcdf_fvcom:%s_V%s', mfilename, Version)); % 写入程序信息
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

            [scale_factor, add_offset] = calc_scale_offset(Casfco2, dtype);
            nccreate(ncname, 'casfco2', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', calc_fillvalue(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.casfco2)'
                ncwriteatt(ncname, 'casfco2', key{1}, ATTRS.casfco2.(key{1}));
            end

            ncwriteatt(ncname, 'casfco2', 'clim', [-300, 300]);
            ncwriteatt(ncname, 'casfco2', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'casfco2', 'add_offset', add_offset);
            ncwrite(ncname, 'casfco2', Casfco2, [1, 1, 1]);

            varid_GA = netcdf.getConstant('NC_GLOBAL');
            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                ncwriteatt(ncname, varid_GA, key{1}, ATTRS.GLOBAL.(key{1}));
            end % global attribute

            if ~isempty(conf)
                NC = read_NC(conf);
                fields = fieldnames(NC);

                for iname = 1:length(fields)
                    ncwriteatt(ncname, varid_GA, fields{iname}, NC.(fields{iname}));
                end

            end

            ncwriteatt(ncname, varid_GA, 'product_name', S_name); % 文件名
            ncwriteatt(ncname, varid_GA, 'WriteProgram', sprintf('netcdf_fvcom:%s_V%s', mfilename, Version)); % 写入程序信息
            ncwriteatt(ncname, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
            ncwriteatt(ncname, varid_GA, 'Mbaysalt_version', ver('Mbaysalt').Version); % Mbaysalt版本信息
            ncwriteatt(ncname, varid_GA, 'Mbaysalt_gitHash', getGitHash(ST_Mbaysalt('cd'), 'long')); % Mbaysalt git hash
            ncwriteatt(ncname, varid_GA, 'MATLAB_version', version); % MATLAB版本信息

    end

    rtn.Version = Version;
    rtn.Method = Method;

    return
end

function NC = read_NC(structIn)
    % 从structIn中读取以NC_开头的变量，将变量写入到SWITCH结构体中
    % eg: 将structIn中的NC_source写入到SWITCH.source中
    NC = struct();
    key = fieldnames(structIn);

    for i = 1:length(key)

        if ~isempty(regexp(key{i}, '^NC_', 'once'))
            NC.(key{i}(4:end)) = structIn.(key{i});
        end

    end

end
