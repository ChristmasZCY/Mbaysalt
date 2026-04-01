function rtn = wrnc_salt(NC,Lon,Lat,Delement,time,Velement,varargin)
    %       This function is used to write the salinity data to the netcdf file
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % Parameter:
    %       NC:             netCDF                              || required: one of || type: int/char
    %           ncid:       netcdf file id                                          || type: int       || example: 1
    %           ncname:     netcdf file name                                        || type: char      || example: 'tide.nc'
    %       Lon:             longitude                          || required: True   || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                           || required: True   || type: double    || format: [30.5, 31.5]
    %       Delement:        depth struct                       || required: True   || type: struct    || format: struct
    %           .Depth_std:  depth of standard level            || required: False  || type: double    || format: vector
    %           .Bathy:      bathy of ocean                     || required: False  || type: double    || format: vector
    %           .Siglay:     levels of siglay                   || required: False  || type: double    || format: matrix
    %           .Depth_avg:  depth of average level             || required: False  || type: double    || example: [0,100;20,300]
    %       time:            time                               || required: True   || type: double    || format: posixtime
    %       Velement:        value struct                       || required: True   || type: struct    || format: struct
    %           .Salt_std:   sea salinity at standard levels    || required: False  || type: double    || format: matrix
    %           .Salt_sgm:   sea salinity at sigma levels       || required: False  || type: double    || format: matrix
    %           .Salt_avg:   sea salinity at average levels     || required: False  || type: double    || format: matrix
    %       varargin:        optional parameters     
    %           conf:        configuration struct               || required: False  || type: namevalue || format: struct
    %           INFO:        Whether print msg                  || required: False  || type: flag      || format: 'INFO'
    %           Text_len:    Length of msg str                  || required: False  || type: namevalue || format: 'Text_len',45
    %           dtype:       data type of variable          || required: False  || type: namevalue || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created,                    by Christmas;
    %       2023-12-29:     Added, for average levels,  by Christmas;
    %       2026-03-31:     Added ncwrite support,      by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_salt('salt.nc',Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_salt('salt.nc',Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_salt('salt.nc',Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_salt('salt.nc',Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_salt('salt.nc',Lon,Lat,Delement,time,Velement,'dtype','int16')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{struct('')});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});
    varargin = read_varargin(varargin,{'dtype'},{'int16'});

    if isnumeric(NC)
        ncid = NC;
        Version = '1.3 (netcdf.putVar)';
        Method = 'LowLevel';
    elseif ischar(NC) || isstring(NC)
        ncname = NC;
        Version = '2.0 (ncwrite)';
        Method = 'HighLevel';
    end

    SWITCH.std = false;
    SWITCH.sgm = false;
    SWITCH.avg = false;

    if isfield(Delement,'Depth_std')
        SWITCH.std = true;  % Depth_std
        Depth_std = Delement.Depth_std;
        Salt_std = Velement.Salt_std;
    end
    if isfield(Delement,'Bathy') && isfield(Delement,'Siglay')
        SWITCH.sgm = true;  % Bathy Siglay
        Bathy = Delement.Bathy; Siglay = Delement.Siglay;
        Salt_sgm = Velement.Salt_sgm;
    end
    if isfield(Delement,'Depth_avg')
        SWITCH.avg = true;  % Depth_avg
        Depth_avg = Delement.Depth_avg;
        Salt_avg = Velement.Salt_avg;
    end

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),"omitnan"), '%2.f');
    S_name = standard_filename('salinity',Lon,Lat,time_filename,ResName); % 标准文件名
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
        londimID  = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
        latdimID  = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
        timedimID = netcdf.defDim(ncid, 'time',     netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
        TIMEdimID = netcdf.defDim(ncid, 'DateStr',  size(char(TIME),2));                 % 定义TIME维度
        if SWITCH.std
            depStddimID = netcdf.defDim(ncid, 'depth_std', length(Depth_std));  % 定义depth维度
        end
        if SWITCH.sgm
            sigdimID = netcdf.defDim(ncid, 'sigma', size(Siglay, 3));  % 定义sigma维度
        end
        if SWITCH.avg
            depAvgdimID = netcdf.defDim(ncid, 'depth_avg',    size(Depth_avg,1));  % 定义depth维度
            twodimID    = netcdf.defDim(ncid, 'two',          2);  % 定义depth维度
        end

        % 定义变量
        lon_id  = netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);              % 经度
        lat_id  = netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);              % 纬度
        time_id = netcdf.defVar(ncid, 'time',      'double',   timedimID);             % 时间
        TIME_id = netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID,timedimID]); % 时间char
        netcdf.defVarDeflate(ncid, lon_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, lat_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, time_id, true, true, 5)
        netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

        if SWITCH.std
            dep_std_id =  netcdf.defVar(ncid, 'depth_std',    'NC_FLOAT', [depStddimID]);  % 深度
            salt_std_id = netcdf.defVar(ncid, 'salinity_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % 盐度
            netcdf.defVarFill(ncid, salt_std_id, false, realmax('single'));   % 设置缺省值
            netcdf.defVarDeflate(ncid, dep_std_id,  true, true, 5)
            netcdf.defVarDeflate(ncid, salt_std_id, true, true, 5)
        end

        if SWITCH.sgm
            bathy_id    = netcdf.defVar(ncid, 'bathy',        'NC_FLOAT', [londimID, latdimID]);  % 深度
            siglay_id   = netcdf.defVar(ncid, 'siglay',       'NC_FLOAT', [londimID, latdimID, sigdimID]);  % 深度
            salt_sgm_id = netcdf.defVar(ncid, 'salinity_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]);  % 深度

            netcdf.defVarFill(ncid, bathy_id,    false, realmax('single')); % 设置缺省值
            netcdf.defVarFill(ncid, siglay_id,   false, realmax('single')); % 设置缺省值
            netcdf.defVarFill(ncid, salt_sgm_id, false, realmax('single')); % 设置缺省值

            netcdf.defVarDeflate(ncid, bathy_id,    true, true, 5)
            netcdf.defVarDeflate(ncid, siglay_id,   true, true, 5)
            netcdf.defVarDeflate(ncid, salt_sgm_id, true, true, 5)
        end

        if SWITCH.avg
            dep_avg_id  = netcdf.defVar(ncid, 'depth_avg',    'NC_FLOAT', [depAvgdimID, twodimID]);  % 深度
            salt_avg_id = netcdf.defVar(ncid, 'salinity_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % 盐度
            netcdf.defVarFill(ncid, salt_avg_id, false, realmax('single')); % 设置缺省值
            netcdf.defVarDeflate(ncid, dep_avg_id,  true, true, 5)
            netcdf.defVarDeflate(ncid, salt_avg_id, true, true, 5)
        end

        % -----
        netcdf.endDef(ncid);    % 结束nc文件定义
        % 将数据放入相应的变量
        netcdf.putVar(ncid, lon_id,                                                  Lon);         % 经度
        netcdf.putVar(ncid, lat_id,                                                  Lat);         % 纬度
        netcdf.putVar(ncid, time_id,  0,    length(time),                            time);        % 时间
        netcdf.putVar(ncid, TIME_id, [0,0], [size(char(TIME),2),size(char(TIME),1)], char(TIME)'); % 时间char

        if SWITCH.std
            netcdf.putVar(ncid, dep_std_id, Depth_std); % 深度
            netcdf.putVar(ncid, salt_std_id, [0,0,0,0], [size(Salt_std,1), size(Salt_std,2), size(Salt_std,3), size(Salt_std,4)], Salt_std);  % 盐度
        end

        if SWITCH.sgm
            netcdf.putVar(ncid, bathy_id, Bathy);  % bathy
            netcdf.putVar(ncid, siglay_id,Siglay); % Siglay
            netcdf.putVar(ncid, salt_sgm_id, [0,0,0,0], [size(Salt_sgm,1), size(Salt_sgm,2), size(Salt_sgm,3), size(Salt_sgm,4)], Salt_sgm);  % Salt_sgm
        end

        if SWITCH.avg
            netcdf.putVar(ncid, dep_avg_id, Depth_avg);  % 深度
            netcdf.putVar(ncid, salt_avg_id, [0,0,0,0], [size(Salt_avg,1), size(Salt_avg,2), size(Salt_avg,3), size(Salt_avg,4)], Salt_avg); % 盐度
        end

        % -----
        netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
        % 添加变量属性
        % ATTRS.longitude.key = ATTRS.longitude.value; % 经度
        for key = fieldnames(ATTRS.longitude)'
            netcdf.putAtt(ncid, lon_id, key{1}, ATTRS.longitude.(key{1}));
        end                            % 经度
        netcdf.putAtt(ncid, lon_id, 'westernmost', num2str(min(Lon,[],"all"),'%3.2f'));  % 经度
        netcdf.putAtt(ncid, lon_id, 'easternmost', num2str(max(Lon,[],"all"),'%3.2f'));  % 经度

        % ATTRS.latitude.key = ATTRS.latitude.value; % 纬度
        for key = fieldnames(ATTRS.latitude)'
            netcdf.putAtt(ncid, lat_id, key{1}, ATTRS.latitude.(key{1}));
        end                     % 纬度
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

        if SWITCH.std
            % ATTRS.depth_std.key = ATTRS.depth_std.value; % depth_std
            for key = fieldnames(ATTRS.depth_std)'
                netcdf.putAtt(ncid, dep_std_id, key{1}, ATTRS.depth_std.(key{1}));
            end                     % depth_std

            % ATTRS.salinity_std.key = ATTRS.salinity_std.value; % salinity_std
            for key = fieldnames(ATTRS.salinity_std)'
                netcdf.putAtt(ncid, salt_std_id, key{1}, ATTRS.salinity_std.(key{1}));
            end                     % salinity_std
        end

        if SWITCH.sgm
            % ATTRS.bathy.key = ATTRS.bathy.value; % bathy
            for key = fieldnames(ATTRS.bathy)'
                netcdf.putAtt(ncid, bathy_id, key{1}, ATTRS.bathy.(key{1}));
            end                     % bathy

            % ATTRS.siglay.key = ATTRS.siglay.value; % siglay
            for key = fieldnames(ATTRS.siglay)'
                netcdf.putAtt(ncid, siglay_id, key{1}, ATTRS.siglay.(key{1}));
            end                     % siglay

            % ATTRS.salinity_sgm.key = ATTRS.salinity_sgm.value; % salinity_sgm
            for key = fieldnames(ATTRS.salinity_sgm)'
                netcdf.putAtt(ncid, salt_sgm_id, key{1}, ATTRS.salinity_sgm.(key{1}));
            end                     % salinity_sgm
        end

        if SWITCH.avg
            % ATTRS.depth_avg.key = ATTRS.depth_avg.value; % depth_avg
            for key = fieldnames(ATTRS.depth_avg)'
                netcdf.putAtt(ncid, dep_avg_id, key{1}, ATTRS.depth_avg.(key{1}));
            end                     % depth_avg
            netcdf.putAtt(ncid, dep_avg_id, 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1,1),Depth_avg(1,2)));  % Depth_avg

            % ATTRS.salinity_avg.key = ATTRS.salinity_avg.value; % salinity_avg
            for key = fieldnames(ATTRS.salinity_avg)'
                netcdf.putAtt(ncid, salt_avg_id, key{1}, ATTRS.salinity_avg.(key{1}));
            end                     % salinity_avg
        end

        % 写入global attribute
        varid_GA = netcdf.getConstant('NC_GLOBAL');
        for key = fieldnames(ATTRS.GLOBAL)'
            netcdf.putAtt(ncid, varid_GA, key{1}, ATTRS.GLOBAL.(key{1}));
        end                     % global attribute
        if ~isempty(conf)
            NC = read_NC(conf);
            fields = fieldnames(NC);
            for iname = 1 : length(fields)
                %  netcdf.putAtt(ncid, varid_GA, 'source', conf.P_Source); % 数据源
                netcdf.putAtt(ncid, varid_GA, fields{iname}, NC.(fields{iname}));
            end
        end
        netcdf.putAtt(ncid, varid_GA, 'product_name', S_name);  % 文件名
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'WriteProgram',   ['netcdf_fvcom:', mfilename, ' V', Version]); % 写入程序信息
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

        if SWITCH.std
            [scale_factor, add_offset] = calc_scale_offset(Depth_std, dtype);
            nccreate(ncname, 'depth_std', ...
                'Dimensions', {'depth_std', length(Depth_std)}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.depth_std)'
                ncwriteatt(ncname, 'depth_std', key{1}, ATTRS.depth_std.(key{1}));
            end
            ncwriteatt(ncname, 'depth_std', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'depth_std', 'add_offset', add_offset);
            ncwrite(ncname, 'depth_std', Depth_std);

            [scale_factor, add_offset] = calc_scale_offset(Salt_std, dtype);
            nccreate(ncname, 'salinity_std', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_std', length(Depth_std), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.salinity_std)'
                ncwriteatt(ncname, 'salinity_std', key{1}, ATTRS.salinity_std.(key{1}));
            end
            ncwriteatt(ncname, 'salinity_std', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'salinity_std', 'add_offset', add_offset);
            ncwrite(ncname, 'salinity_std', Salt_std, [1,1,1,1]);
        end

        if SWITCH.sgm
            [scale_factor, add_offset] = calc_scale_offset(Bathy, dtype);
            nccreate(ncname, 'bathy', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat)}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.bathy)'
                ncwriteatt(ncname, 'bathy', key{1}, ATTRS.bathy.(key{1}));
            end
            ncwriteatt(ncname, 'bathy', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'bathy', 'add_offset', add_offset);
            ncwrite(ncname, 'bathy', Bathy);

            [scale_factor, add_offset] = calc_scale_offset(Siglay, dtype);
            nccreate(ncname, 'siglay', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'sigma', size(Siglay, 3)}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.siglay)'
                ncwriteatt(ncname, 'siglay', key{1}, ATTRS.siglay.(key{1}));
            end
            ncwriteatt(ncname, 'siglay', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'siglay', 'add_offset', add_offset);
            ncwrite(ncname, 'siglay', Siglay, [1,1,1]);

            [scale_factor, add_offset] = calc_scale_offset(Salt_sgm, dtype);
            nccreate(ncname, 'salinity_sgm', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'sigma', size(Siglay, 3), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.salinity_sgm)'
                ncwriteatt(ncname, 'salinity_sgm', key{1}, ATTRS.salinity_sgm.(key{1}));
            end
            ncwriteatt(ncname, 'salinity_sgm', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'salinity_sgm', 'add_offset', add_offset);
            ncwrite(ncname, 'salinity_sgm', Salt_sgm, [1,1,1,1]);
        end

        if SWITCH.avg
            [scale_factor, add_offset] = calc_scale_offset(Depth_avg, dtype);
            nccreate(ncname, 'depth_avg', ...
                'Dimensions', {'depth_avg', size(Depth_avg,1), 'two', 2}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.depth_avg)'
                ncwriteatt(ncname, 'depth_avg', key{1}, ATTRS.depth_avg.(key{1}));
            end
            ncwriteatt(ncname, 'depth_avg', 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1,1),Depth_avg(1,2)));
            ncwriteatt(ncname, 'depth_avg', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'depth_avg', 'add_offset', add_offset);
            ncwrite(ncname, 'depth_avg', Depth_avg);

            [scale_factor, add_offset] = calc_scale_offset(Salt_avg, dtype);
            nccreate(ncname, 'salinity_avg', ...
                'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_avg', size(Depth_avg,1), 'time', Inf}, ...
                'Datatype', dtype, ...
                'Format', 'netcdf4', ...
                'FillValue', intmin(dtype), ...
                'DeflateLevel', 5, ...
                'Shuffle', true);
            for key = fieldnames(ATTRS.salinity_avg)'
                ncwriteatt(ncname, 'salinity_avg', key{1}, ATTRS.salinity_avg.(key{1}));
            end
            ncwriteatt(ncname, 'salinity_avg', 'scale_factor', scale_factor);
            ncwriteatt(ncname, 'salinity_avg', 'add_offset', add_offset);
            ncwrite(ncname, 'salinity_avg', Salt_avg, [1,1,1,1]);
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
        ncwriteatt(ncname, '/', 'product_name', S_name);  % 文件名
        ncwriteatt(ncname, '/', 'WriteProgram', ['netcdf_fvcom:', mfilename, ' V', Version]); % 写入程序信息
        ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]);  % 操作历史记录
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
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^NC_','once'))
            NC.(key{i}(4:end)) = structIn.(key{i});
        end
    end
end
