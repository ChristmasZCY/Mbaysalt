function rtn = wrnc_wave(NC,Lon,Lat,time,Velement,varargin)
    %       This function is used to write the WW3 wave data to the netcdf file
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % parameter:
    %       NC:             netCDF                  || required: one of || type: int/char
    %           ncid:       netcdf file id                              || type: int        || example: 1
    %           ncname:     netcdf file name                            || type: char       || example: 'tide.nc'
    %       Lon:             longitude              || required: True   || type: double     || format: [120.5, 121.5]
    %       Lat:             latitude               || required: True   || type: double     || format: [30.5, 31.5]
    %       time:            time                   || required: True   || type: double     || format: posixtime
    %       Velement:        wave struct            || required: True   || type: struct     || format: struct
    %       varargin:        optional parameters     
    %           conf:        configuration struct   || required: False  || type: namevalue  || format: struct
    %           INFO:        Whether print msg      || required: False  || type: flag       || format: 'INFO'
    %           Text_len:    Length of msg str      || required: False  || type: namevalue  || format: 'Text_len',45
    %           dtype:       data type of variables || required: False  || type: namevalue  || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                by Christmas;
    %       2025-01-21:     Added hmax,             by Christmas;
    %       2026-03-31:     Added ncwrite support,  by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct)
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf)
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf,'INFO')
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf,'INFO','Text_len',45)
    %       netcdf_ww3.wrnc_wave('wave.nc',Lon,Lat,time,wave_Struct)
    %       netcdf_ww3.wrnc_wave('wave.nc',Lon,Lat,time,wave_Struct,'conf',conf)
    %       netcdf_ww3.wrnc_wave('wave.nc',Lon,Lat,time,wave_Struct,'conf',conf,'INFO')
    %       netcdf_ww3.wrnc_wave('wave.nc',Lon,Lat,time,wave_Struct,'conf',conf,'INFO','Text_len',45)
    %       netcdf_ww3.wrnc_wave('wave.nc',Lon,Lat,time,wave_Struct,'dtype','int16')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{struct('')});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});
    varargin = read_varargin(varargin,{'dtype'},{'int16'});

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

    if isfield(Velement, 'Swh')
        SWITCH.swh = true;
    else
        SWITCH.swh = false;
    end
    if isfield(Velement, 'Mwd')
        SWITCH.mwd = true;
    else
        SWITCH.mwd = false;
    end
    if isfield(Velement, 'Mwp')
        SWITCH.mwp = true;
    else
        SWITCH.mwp = false;
    end
    if isfield(Velement, 'Hmax')
        SWITCH.hmax = true;
    else
        SWITCH.hmax = false;
    end
    if isfield(Velement, 'Shww')
        SWITCH.shww = true;
    else
        SWITCH.shww = false;
    end
    if isfield(Velement, 'Mdww')
        SWITCH.mdww = true;
    else
        SWITCH.mdww = false;
    end
    if isfield(Velement, 'Mpww')
        SWITCH.mpww = true;
    else
        SWITCH.mpww = false;
    end
    if isfield(Velement, 'Shts')
        SWITCH.shts = true;
    else
        SWITCH.shts = false;
    end
    if isfield(Velement, 'Mdts')
        SWITCH.mdts = true;
    else
        SWITCH.mdts = false;
    end
    if isfield(Velement, 'Mpts')
        SWITCH.mpts = true;
    else
        SWITCH.mpts = false;
    end
    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('wave',Lon,Lat,time_filename,ResName); % 标准文件名
    if ~isempty(INFO)
        if ~Text_len
            osprint2('INFO', ['Transfor --> ', S_name]);
        else
            osprint2('INFO', [pad('Transfor ', Text_len, 'right'),'--> ', S_name]);
        end
    end

    switch Method
    case 'LowLevel'
        % 定义维度
        londimID  = netcdf.defDim(ncid, 'longitude', length(Lon));                        % 定义lon维度
        latdimID  = netcdf.defDim(ncid, 'latitude',  length(Lat));                        % 定义lat纬度
        timedimID = netcdf.defDim(ncid, 'time',      netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
        TIMEdimID = netcdf.defDim(ncid, 'DateStr',   size(char(TIME),2));                 % 定义TIME维度

        % 定义变量
        lon_id  = netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);                    % 经度
        lat_id  = netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);                    % 纬度
        time_id = netcdf.defVar(ncid, 'time',      'double',   timedimID);                   % 时间
        TIME_id = netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID, timedimID]);      % 时间char
        netcdf.defVarDeflate(ncid, lon_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, lat_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, time_id, true, true, 5)
        netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

        if SWITCH.swh
            swh_id = netcdf.defVar(ncid, 'swh', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪有效波高
            netcdf.defVarFill(ncid, swh_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, swh_id, true, true, 5)
        end
        if SWITCH.mwd
            mwd_id = netcdf.defVar(ncid, 'mwd', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪波向
            netcdf.defVarFill(ncid, mwd_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mwd_id, true, true, 5)
        end
        if SWITCH.mwp
            mwp_id = netcdf.defVar(ncid, 'mwp', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪周期
            netcdf.defVarFill(ncid, mwp_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mwp_id, true, true, 5)
        end
        if SWITCH.hmax
            hmax_id = netcdf.defVar(ncid, 'hmax', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 最大波高
            netcdf.defVarFill(ncid, hmax_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, hmax_id, true, true, 5)
        end
        if SWITCH.shww
            shww_id = netcdf.defVar(ncid, 'shww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪波高
            netcdf.defVarFill(ncid, shww_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, shww_id, true, true, 5)
        end
        if SWITCH.mdww
            mdww_id = netcdf.defVar(ncid, 'mdww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪波向
            netcdf.defVarFill(ncid, mdww_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mdww_id, true, true, 5)
        end
        if SWITCH.mpww
            mpww_id = netcdf.defVar(ncid, 'mpww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪周期
            netcdf.defVarFill(ncid, mpww_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mpww_id, true, true, 5)
        end
        if SWITCH.shts
            shts_id = netcdf.defVar(ncid, 'shts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪波高
            netcdf.defVarFill(ncid, shts_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, shts_id, true, true, 5)
        end
        if SWITCH.mdts
            mdts_id = netcdf.defVar(ncid, 'mdts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪波向
            netcdf.defVarFill(ncid, mdts_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mdts_id, true, true, 5)
        end
        if SWITCH.mpts
            mpts_id = netcdf.defVar(ncid, 'mpts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪周期
            netcdf.defVarFill(ncid, mpts_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, mpts_id, true, true, 5)
        end

        % -----
        netcdf.endDef(ncid);    % 结束nc文件定义
        % 将数据放入相应的变量
        netcdf.putVar(ncid, lon_id,                                                        Lon);         % 经度
        netcdf.putVar(ncid, lat_id,                                                        Lat);         % 纬度
        netcdf.putVar(ncid, time_id, 0,       length(time),                                time);        % 时间
        netcdf.putVar(ncid, TIME_id, [0,0],   [size(char(TIME),2),size(char(TIME),1)],     char(TIME)'); % 时间char
        if SWITCH.swh
            netcdf.putVar(ncid, swh_id,  [0,0,0], [size(Velement.Swh,1), size(Velement.Swh,2), size(Velement.Swh,3)],  Velement.Swh); % 海浪有效波高
        end
        if SWITCH.mwd
            netcdf.putVar(ncid, mwd_id,  [0,0,0], [size(Velement.Mwd,1), size(Velement.Mwd,2), size(Velement.Mwd,3)],  Velement.Mwd); % 海浪波向
        end
        if SWITCH.mwp
            netcdf.putVar(ncid, mwp_id,  [0,0,0], [size(Velement.Mwp,1), size(Velement.Mwp,2), size(Velement.Mwp,3)],  Velement.Mwp); % 海浪周期
        end
        if SWITCH.hmax
            netcdf.putVar(ncid, hmax_id, [0,0,0], [size(Velement.Hmax,1), size(Velement.Hmax,2), size(Velement.Hmax,3)],  Velement.Hmax); % 最大波高
        end
        if SWITCH.shww
            netcdf.putVar(ncid, shww_id, [0,0,0], [size(Velement.Shww,1), size(Velement.Shww,2), size(Velement.Shww,3)],  Velement.Shww); % 风浪波高
        end
        if SWITCH.mdww
            netcdf.putVar(ncid, mdww_id, [0,0,0], [size(Velement.Mdww,1), size(Velement.Mdww,2), size(Velement.Mdww,3)],  Velement.Mdww); % 风浪波向
        end
        if SWITCH.mpww
            netcdf.putVar(ncid, mpww_id, [0,0,0], [size(Velement.Mpww,1), size(Velement.Mpww,2), size(Velement.Mpww,3)],  Velement.Mpww); % 风浪周期
        end
        if SWITCH.shts
            netcdf.putVar(ncid, shts_id, [0,0,0], [size(Velement.Shts,1), size(Velement.Shts,2), size(Velement.Shts,3)],  Velement.Shts); % 涌浪波高
        end
        if SWITCH.mdts
            netcdf.putVar(ncid, mdts_id, [0,0,0], [size(Velement.Mdts,1), size(Velement.Mdts,2), size(Velement.Mdts,3)],  Velement.Mdts); % 涌浪波向
        end
        if SWITCH.mpts
            netcdf.putVar(ncid, mpts_id, [0,0,0], [size(Velement.Mpts,1), size(Velement.Mpts,2), size(Velement.Mpts,3)],  Velement.Mpts); % 涌浪周期
        end

        % -----
        netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
        % 添加变量属性
        % ATTRS.longitude.key = ATTRS.longitude.value; % 经度
        for key = fieldnames(ATTRS.longitude)'
            netcdf.putAtt(ncid, lon_id, key{1}, ATTRS.longitude.(key{1}));
        end
        netcdf.putAtt(ncid, lon_id, 'westernmost', num2str(min(Lon,[],"all"),'%3.2f')); % 经度
        netcdf.putAtt(ncid, lon_id, 'easternmost', num2str(max(Lon,[],"all"),'%3.2f')); % 经度

        % ATTRS.latitude.key = ATTRS.latitude.value; % 纬度
        for key = fieldnames(ATTRS.latitude)'
            netcdf.putAtt(ncid, lat_id, key{1}, ATTRS.latitude.(key{1}));
        end
        netcdf.putAtt(ncid, lat_id, 'southernmost', num2str(min(Lat,[],"all"),'%2.2f')); % 纬度
        netcdf.putAtt(ncid, lat_id, 'northernmost', num2str(max(Lat,[],"all"),'%2.2f')); % 纬度

        % ATTRS.time.key = ATTRS.time.value; % 时间
        for key = fieldnames(ATTRS.time)'
            netcdf.putAtt(ncid, time_id, key{1}, ATTRS.time.(key{1}));
        end

        % ATTRS.TIME.key = ATTRS.TIME.value; % 时间char
        for key = fieldnames(ATTRS.TIME)'
            netcdf.putAtt(ncid, TIME_id, key{1}, ATTRS.TIME.(key{1}));
        end
        netcdf.putAtt(ncid, TIME_id, 'reference',  TIME_reference);  % 时间char
        netcdf.putAtt(ncid, TIME_id, 'start_date', TIME_start_date); % 时间char
        netcdf.putAtt(ncid, TIME_id, 'end_date',   TIME_end_date);   % 时间char

        if SWITCH.swh
            % ATTRS.swh.key = ATTRS.swh.value; % 海浪有效波高
            for key = fieldnames(ATTRS.swh)'
                netcdf.putAtt(ncid, swh_id, key{1}, ATTRS.swh.(key{1}));
            end
        end
        if SWITCH.mwd
            % ATTRS.mwd.key = ATTRS.mwd.value; % 海浪波向
            for key = fieldnames(ATTRS.mwd)'
                netcdf.putAtt(ncid, mwd_id, key{1}, ATTRS.mwd.(key{1}));
            end
        end
        if SWITCH.mwp
            % ATTRS.mwp.key = ATTRS.mwp.value; % 海浪周期
            for key = fieldnames(ATTRS.mwp)'
                netcdf.putAtt(ncid, mwp_id, key{1}, ATTRS.mwp.(key{1}));
            end
        end
        if SWITCH.hmax
            % ATTRS.hmax.key = ATTRS.hmax.value; % 最大波高
            for key = fieldnames(ATTRS.hmax)'
                netcdf.putAtt(ncid, hmax_id, key{1}, ATTRS.hmax.(key{1}));
            end
        end
        if SWITCH.shww
            % ATTRS.shww.key = ATTRS.shww.value; % 风浪波高
            for key = fieldnames(ATTRS.shww)'
                netcdf.putAtt(ncid, shww_id, key{1}, ATTRS.shww.(key{1}));
            end
        end
        if SWITCH.mdww
            % ATTRS.mdww.key = ATTRS.mdww.value; % 风浪波向
            for key = fieldnames(ATTRS.mdww)'
                netcdf.putAtt(ncid, mdww_id, key{1}, ATTRS.mdww.(key{1}));
            end
        end
        if SWITCH.mpww
            % ATTRS.mpww.key = ATTRS.mpww.value; % 风浪周期
            for key = fieldnames(ATTRS.mpww)'
                netcdf.putAtt(ncid, mpww_id, key{1}, ATTRS.mpww.(key{1}));
            end
        end
        if SWITCH.shts
            % ATTRS.shts.key = ATTRS.shts.value; % 涌浪波高
            for key = fieldnames(ATTRS.shts)'
                netcdf.putAtt(ncid, shts_id, key{1}, ATTRS.shts.(key{1}));
            end
        end
        if SWITCH.mdts
            % ATTRS.mdts.key = ATTRS.mdts.value; % 涌浪波向
            for key = fieldnames(ATTRS.mdts)'
                netcdf.putAtt(ncid, mdts_id, key{1}, ATTRS.mdts.(key{1}));
            end
        end
        if SWITCH.mpts
            % ATTRS.mpts.key = ATTRS.mpts.value; % 涌浪周期
            for key = fieldnames(ATTRS.mpts)'
                netcdf.putAtt(ncid, mpts_id, key{1}, ATTRS.mpts.(key{1}));
            end
        end

        % 写入global attribute
        varid_GA = netcdf.getConstant('NC_GLOBAL');
        for key = fieldnames(ATTRS.GLOBAL)'
            netcdf.putAtt(ncid, varid_GA, key{1}, ATTRS.global.(key{1}));
        end                     % global attribute
        if ~isempty(conf)
            NC = read_NC(conf);
            fields = fieldnames(NC);
            for iname = 1 : length(fields)
                netcdf.putAtt(ncid, varid_GA, fields{iname}, NC.(fields{iname}));
            end
        end
        netcdf.putAtt(ncid, varid_GA, 'product_name', S_name);  % 文件名
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'WriteProgram',   ['netcdf_ww3:', mfilename, ' V', Version]); % 写入程序信息
        netcdf.putAtt(ncid, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]);  % 操作历史记录
        netcdf.close(ncid);  % 关闭nc文件

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
        ncwriteatt(ncname, 'longitude', 'westernmost', num2str(min(Lon,[],"all"),'%3.2f'));
        ncwriteatt(ncname, 'longitude', 'easternmost', num2str(max(Lon,[],"all"),'%3.2f'));
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
        ncwriteatt(ncname, 'latitude', 'southernmost', num2str(min(Lat,[],"all"),'%2.2f'));
        ncwriteatt(ncname, 'latitude', 'northernmost', num2str(max(Lat,[],"all"),'%2.2f'));
        ncwrite(ncname, 'latitude', Lat);

        nccreate(ncname, 'time', ...
            'Dimensions', {'time', Inf}, ...
            'Datatype', 'double', ...
            'Format', 'netcdf4', ...
            'DeflateLevel', 5, ...
            'Shuffle', true);
        for key = fieldnames(ATTRS.time)'
            ncwriteatt(ncname, 'time', key{1}, ATTRS.time.(key{1}));
        end
        ncwrite(ncname, 'time', time);

        nccreate(ncname, 'TIME', ...
            'Dimensions', {'DateStr', size(char(TIME),2), 'time', Inf}, ...
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
        ncwrite(ncname, 'TIME', char(TIME)', [1,1]);

        if SWITCH.swh
            [scale_factor, add_offset] = calc_scale_offset(Velement.Swh, dtype);
            nccreate(ncname, 'swh', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.swh)'
                ncwriteatt(ncname, 'swh', key{1}, ATTRS.swh.(key{1}));
            end
            ncwriteatt(ncname, 'swh', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'swh', 'add_offset', add_offset);
            ncwrite(ncname, 'swh', Velement.Swh, [1,1,1]);
        end

        if SWITCH.mwd
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mwd, dtype);
            nccreate(ncname, 'mwd', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mwd)'
                ncwriteatt(ncname, 'mwd', key{1}, ATTRS.mwd.(key{1}));
            end
            ncwriteatt(ncname, 'mwd', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mwd', 'add_offset', add_offset);
            ncwrite(ncname, 'mwd', Velement.Mwd, [1,1,1]);
        end

        if SWITCH.mwp
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mwp, dtype);
            nccreate(ncname, 'mwp', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mwp)'
                ncwriteatt(ncname, 'mwp', key{1}, ATTRS.mwp.(key{1}));
            end
            ncwriteatt(ncname, 'mwp', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mwp', 'add_offset', add_offset);
            ncwrite(ncname, 'mwp', Velement.Mwp, [1,1,1]);
        end

        if SWITCH.hmax
            [scale_factor, add_offset] = calc_scale_offset(Velement.Hmax, dtype);
            nccreate(ncname, 'hmax', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.hmax)'
                ncwriteatt(ncname, 'hmax', key{1}, ATTRS.hmax.(key{1}));
            end
            ncwriteatt(ncname, 'hmax', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'hmax', 'add_offset', add_offset);
            ncwrite(ncname, 'hmax', Velement.Hmax, [1,1,1]);
        end

        if SWITCH.shww
            [scale_factor, add_offset] = calc_scale_offset(Velement.Shww, dtype);
            nccreate(ncname, 'shww', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.shww)'
                ncwriteatt(ncname, 'shww', key{1}, ATTRS.shww.(key{1}));
            end
            ncwriteatt(ncname, 'shww', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'shww', 'add_offset', add_offset);
            ncwrite(ncname, 'shww', Velement.Shww, [1,1,1]);
        end

        if SWITCH.mdww
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mdww, dtype);
            nccreate(ncname, 'mdww', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mdww)'
                ncwriteatt(ncname, 'mdww', key{1}, ATTRS.mdww.(key{1}));
            end
            ncwriteatt(ncname, 'mdww', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mdww', 'add_offset', add_offset);
            ncwrite(ncname, 'mdww', Velement.Mdww, [1,1,1]);
        end

        if SWITCH.mpww
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mpww, dtype);
            nccreate(ncname, 'mpww', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mpww)'
                ncwriteatt(ncname, 'mpww', key{1}, ATTRS.mpww.(key{1}));
            end
            ncwriteatt(ncname, 'mpww', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mpww', 'add_offset', add_offset);
            ncwrite(ncname, 'mpww', Velement.Mpww, [1,1,1]);
        end

        if SWITCH.shts
            [scale_factor, add_offset] = calc_scale_offset(Velement.Shts, dtype);
            nccreate(ncname, 'shts', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.shts)'
                ncwriteatt(ncname, 'shts', key{1}, ATTRS.shts.(key{1}));
            end
            ncwriteatt(ncname, 'shts', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'shts', 'add_offset', add_offset);
            ncwrite(ncname, 'shts', Velement.Shts, [1,1,1]);
        end

        if SWITCH.mdts
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mdts, dtype);
            nccreate(ncname, 'mdts', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mdts)'
                ncwriteatt(ncname, 'mdts', key{1}, ATTRS.mdts.(key{1}));
            end
            ncwriteatt(ncname, 'mdts', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mdts', 'add_offset', add_offset);
            ncwrite(ncname, 'mdts', Velement.Mdts, [1,1,1]);
        end

        if SWITCH.mpts
            [scale_factor, add_offset] = calc_scale_offset(Velement.Mpts, dtype);
            nccreate(ncname, 'mpts', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.mpts)'
                ncwriteatt(ncname, 'mpts', key{1}, ATTRS.mpts.(key{1}));
            end
            ncwriteatt(ncname, 'mpts', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'mpts', 'add_offset', add_offset);
            ncwrite(ncname, 'mpts', Velement.Mpts, [1,1,1]);
        end

        % 写入global attribute
        for key = fieldnames(ATTRS.GLOBAL)'
            ncwriteatt(ncname, '/', key{1}, ATTRS.GLOBAL.(key{1}));
        end
        if ~isempty(conf)
            NC = read_NC(conf);
            fields = fieldnames(NC);
            for iname = 1 : length(fields)
                ncwriteatt(ncname, '/', fields{iname}, NC.(fields{iname}));
            end
        end
        ncwriteatt(ncname, '/', 'product_name', S_name);
        ncwriteatt(ncname, '/', 'WriteProgram', ['netcdf_ww3:', mfilename, ' V', Version]);
        ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]);

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
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^NC_','once'))
            NC.(key{i}(4:end)) = structIn.(key{i});
        end
    end
end
