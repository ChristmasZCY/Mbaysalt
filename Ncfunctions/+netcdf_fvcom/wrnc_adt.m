function rtn = wrnc_adt(NC, Lon, Lat, time, Zeta, varargin)
    %       This function is used to write the adt data to the netcdf file
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % Parameter:
    %       NC:             netCDF                  || required: one of || type: int/char
    %           ncid:       netcdf file id                              || type: int        || example: 1
    %           ncname:     netcdf file name                            || type: char       || example: 'tide.nc'
    %       Lon:             longitude              || required: True   || type: double     || format: [120.5, 121.5]
    %       Lat:             latitude               || required: True   || type: double     || format: [30.5, 31.5]
    %       time:            time                   || required: True   || type: double     || format: posixtime
    %       Zeta:            adt                    || required: True   || type: double     || format: matrix
    %       varargin:        optional parameters
    %           Wet_nodes:   wet point              || required: False  || type: namevalue  || format: matrix
    %           Bathy:       water depth            || required: False  || type: namevalue  || format: matrix
    %           conf:        configuration struct   || required: False  || type: namevalue  || format: struct
    %           INFO:        Whether print msg      || required: False  || type: flag       || format: 'INFO'
    %           Text_len:    Length of msg str      || required: False  || type: namevalue  || format: 'Text_len',45
    %           dtype:       data type of variable  || required: False  || type: namevalue  || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created,                            by Christmas;
    %       2023-12-29:     Fixed comments,                     by Christmas;
    %       2024-12-27;     Added Bathy, Wet_nodes for wet_dry, by Christmas;
    %       2026-03-31:     Added ncwrite support,              by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'Bathy',Bathy,'Wet_nodes',Wet_nodes);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO');
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO','Text_len',45);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'Bathy',Bathy,'Wet_nodes',Wet_nodes);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO');
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO','Text_len',45);
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'dtype','int16');
    % =================================================================================================================

    varargin = read_varargin(varargin, {'conf'}, {struct('')});
    varargin = read_varargin2(varargin, {'INFO'});
    varargin = read_varargin(varargin, {'Text_len'}, {false});
    varargin = read_varargin(varargin, {'Wet_nodes'}, {[]});
    varargin = read_varargin(varargin, {'Bathy'}, {[]});
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

    if isempty(Wet_nodes)
        SWITCH.Wet_nodes = false;
    else
        SWITCH.Wet_nodes = true;
    end

    if isempty(Bathy)
        SWITCH.Bathy = false;
    else
        SWITCH.Bathy = true;
    end

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1 / mean(diff(Lon), 'omitnan'), '%2.f');
    S_name = standard_filename('adt', Lon, Lat, time_filename, ResName); % 标准文件名

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
            adt_id = netcdf.defVar(ncid, 'adt', 'NC_FLOAT', [londimID, latdimID, timedimID]); % 海平面高度

            if SWITCH.Wet_nodes
                wet_nodes_id = netcdf.defVar(ncid, 'wet_nodes', 'NC_BYTE', [londimID, latdimID, timedimID]); % 湿点
                netcdf.defVarFill(ncid, wet_nodes_id, false, -1); % 设置缺省值
            end

            if SWITCH.Bathy
                bathy_id = netcdf.defVar(ncid, 'bathy', 'NC_FLOAT', [londimID, latdimID]); % 深度
                netcdf.defVarFill(ncid, bathy_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值
            end

            netcdf.defVarFill(ncid, adt_id, false, calc_fillvalue('NC_FLOAT')); % 设置缺省值

            netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
            netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
            netcdf.defVarDeflate(ncid, time_id, true, true, 5)
            netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
            netcdf.defVarDeflate(ncid, adt_id, true, true, 5)

            if SWITCH.Wet_nodes
                netcdf.defVarDeflate(ncid, wet_nodes_id, true, true, 5)
            end

            if SWITCH.Bathy
                netcdf.defVarDeflate(ncid, bathy_id, true, true, 5)
            end

            % -----
            netcdf.endDef(ncid); % 结束nc文件定义
            % 将数据放入相应的变量
            netcdf.putVar(ncid, lon_id, Lon); % 经度
            netcdf.putVar(ncid, lat_id, Lat); % 纬度
            netcdf.putVar(ncid, time_id, 0, length(time), time); % 时间
            netcdf.putVar(ncid, TIME_id, [0, 0], [size(char(TIME), 2), size(char(TIME), 1)], char(TIME)'); % 时间char
            netcdf.putVar(ncid, adt_id, [0, 0, 0], [size(Zeta, 1), size(Zeta, 2), size(Zeta, 3)], Zeta); % 海平面高度

            if SWITCH.Wet_nodes
                netcdf.putVar(ncid, wet_nodes_id, [0, 0, 0], [size(Wet_nodes, 1), size(Wet_nodes, 2), size(Wet_nodes, 3)], Wet_nodes); % wet_nodes
            end

            if SWITCH.Bathy
                netcdf.putVar(ncid, bathy_id, Bathy); % bathy
            end

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

            % ATTRS.adt.key = ATTRS.adt.value; % 海平面高度
            for key = fieldnames(ATTRS.adt)'
                netcdf.putAtt(ncid, adt_id, key{1}, ATTRS.adt.(key{1}));
            end % 海平面高度

            if SWITCH.Wet_nodes
                % ATTRS.wet_nodes.key = ATTRS.wet_nodes.value; % wet nodes
                for key = fieldnames(ATTRS.wet_nodes)'
                    netcdf.putAtt(ncid, wet_nodes_id, key{1}, ATTRS.wet_nodes.(key{1}));
                end % wet nodes

            end

            if SWITCH.Bathy
                % ATTRS.bathy.key = ATTRS.bathy.value; % bathy
                for key = fieldnames(ATTRS.bathy)'
                    netcdf.putAtt(ncid, bathy_id, key{1}, ATTRS.bathy.(key{1}));
                end % bathy

            end

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
            % netcdf.close(ncid);  % ncid is closed automatically by cleanupObj. % 关闭nc文件

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

            [scale_factor, add_offset] = calc_scale_offset(Zeta, dtype);
            nccreate(ncname, 'adt', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', calc_fillvalue(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);

            for key = fieldnames(ATTRS.adt)'
                ncwriteatt(ncname, 'adt', key{1}, ATTRS.adt.(key{1}));
            end

            ncwriteatt(ncname, 'adt', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'adt', 'add_offset', add_offset);
            ncwrite(ncname, 'adt', Zeta, [1, 1, 1]);

            if SWITCH.Wet_nodes
                nccreate(ncname, 'wet_nodes', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', 'int8', ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue('int8'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.wet_nodes)'
                    ncwriteatt(ncname, 'wet_nodes', key{1}, ATTRS.wet_nodes.(key{1}));
                end

                ncwrite(ncname, 'wet_nodes', Wet_nodes, [1, 1, 1]);
            end

            if SWITCH.Bathy
                [scale_factor, add_offset] = calc_scale_offset(Bathy, dtype);
                nccreate(ncname, 'bathy', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat)}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.bathy)'
                    ncwriteatt(ncname, 'bathy', key{1}, ATTRS.bathy.(key{1}));
                end

                ncwriteatt(ncname, 'bathy', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'bathy', 'add_offset', add_offset);
                ncwrite(ncname, 'bathy', Bathy);
            end

            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                ncwriteatt(ncname, '/', key{1}, ATTRS.GLOBAL.(key{1}));
            end

            if ~isempty(conf)
                NC = read_NC(conf);
                fields = fieldnames(NC);

                for iname = 1:length(fields)
                    ncwriteatt(ncname, '/', fields{iname}, NC.(fields{iname}));
                end

            end

            ncwriteatt(ncname, '/', 'product_name', S_name); % 文件名
            ncwriteatt(ncname, '/', 'WriteProgram', sprintf('netcdf_fvcom:%s_V%s', mfilename, Version)); % 写入程序信息
            ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
            ncwriteatt(ncname, '/', 'Mbaysalt_version', ver('Mbaysalt').Version); % Mbaysalt版本信息
            ncwriteatt(ncname, '/', 'Mbaysalt_gitHash', getGitHash(ST_Mbaysalt('cd'), 'long')); % Mbaysalt git hash
            ncwriteatt(ncname, '/', 'MATLAB_version', version); % MATLAB版本信息

    end

    rtn.Version = Version;
    rtn.Method = Method;
    return;
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
