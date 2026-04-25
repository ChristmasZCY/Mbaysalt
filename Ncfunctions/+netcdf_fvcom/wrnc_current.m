function rtn = wrnc_current(NC, Lon, Lat, Delement, time, Velement, varargin)
    %       This function is used to write the current data u/v/w(optional) to the netcdf file at std or sigma levels.
    %       If NC = ncid, no compression will be applied, and the data will be written directly to the nc file using netcdf.putVar;
    %       If NC = ncname, a new nc file will be created, and the data will be written to the nc file using ncwrite.
    % =================================================================================================================
    % Parameter:
    %       NC:             netCDF                      || required: one of || type: int/char
    %           ncid:       netcdf file id                                  || type: int       || example: 1
    %           ncname:     netcdf file name                                || type: char      || example: 'tide.nc'
    %       Lon:             longitude                  || required: True   || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                   || required: True   || type: double    || format: [30.5, 31.5]
    %       Delement:        depth struct               || required: True   || type: struct    || format: struct
    %           .Depth_std:  depth of standard level    || required: False  || type: double    || format: vector
    %           .Bathy:      bathy of ocean             || required: False  || type: double    || format: vector
    %           .Siglay:     levels of siglay           || required: False  || type: double    || format: matrix
    %           .Depth_avg:  depth of average level     || required: False  || type: double    || example: [0,100;20,300]
    %       time:            time                       || required: True   || type: double    || format: posixtime
    %       Velement:        value struct               || required: True   || type: struct    || format: struct
    %           .U_std:      u at standard levels       || required: False  || type: double    || format: matrix
    %           .V_std:      v at standard levels       || required: True   || type: double    || format: matrix
    %           .W_std:      w at standard levels       || required: False  || type: double    || format: matrix
    %           .U_sgm:      u at sigma levels          || required: False  || type: double    || format: matrix
    %           .V_sgm:      v at sigma levels          || required: False  || type: double    || format: matrix
    %           .W_sgm:      w at sigma levels          || required: False  || type: double    || format: matrix
    %           .U_avg:      u at average levels        || required: False  || type: double    || format: matrix
    %           .V_avg:      v at average levels        || required: False  || type: double    || format: matrix
    %           .W_avg:      w at average levels        || required: False  || type: double    || format: matrix
    %           .Ua   :      u at all average levels    || required: False  || type: double    || format: matrix
    %           .Va   :      v at all average levels    || required: False  || type: double    || format: matrix
    %       varargin:        optional parameters
    %           conf:        configuration struct       || required: False  || type: namevalue || format: struct
    %           INFO:        Whether print msg          || required: False  || type: flag      || format: 'INFO'
    %           Text_len:    Length of msg str          || required: False  || type: namevalue || format: 'Text_len',45
    %           dtype:       data type of variable      || required: False  || type: namevalue || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created,                                by Christmas;
    %       2023-12-29:     Added, for average levels,              by Christmas;
    %       2024-04-07:     Added ua va, change judge input levels, by Christmas;
    %       2026-03-31:     Added ncwrite support,                  by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_current('curr.nc',Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_current('curr.nc',Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_current('curr.nc',Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_current('curr.nc',Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45)
    %       netcdf_fvcom.wrnc_current('curr.nc',Lon,Lat,Delement,time,Velement,'dtype','int16')
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

    SWITCH.std = false;
    SWITCH.sgm = false;
    SWITCH.avg = false;
    SWITCH.u = false;
    SWITCH.v = false;
    SWITCH.w = false;
    SWITCH.ua = false;
    SWITCH.va = false;

    if isfield(Delement, 'Depth_std')
        SWITCH.std = true; % Depth_std
        Depth_std = Delement.Depth_std;
    end

    if isfield(Delement, 'Bathy') && isfield(Delement, 'Siglay')
        SWITCH.sgm = true; % Bathy Siglay
        Bathy = Delement.Bathy; Siglay = Delement.Siglay;
    end

    if isfield(Delement, 'Depth_avg')
        SWITCH.avg = true; % Depth_avg
        Depth_avg = Delement.Depth_avg;
    end

    fields = fieldnames(Velement);

    if any(ismember(fields, {'U_sgm', 'U_std', 'U_avg'}))
        SWITCH.u = true;
    end

    if any(ismember(fields, {'V_sgm', 'V_std', 'V_avg'}))
        SWITCH.v = true;
    end

    if any(ismember(fields, {'W_sgm', 'W_std', 'W_avg'}))
        SWITCH.w = true;
    end

    clear fields

    if isfield(Velement, 'Ua')
        SWITCH.ua = true;
    end

    if isfield(Velement, 'Va')
        SWITCH.va = true;
    end

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME, TIME_reference, TIME_start_date, TIME_end_date, time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1 / mean(diff(Lon), "omitnan"), '%2.f');
    S_name = standard_filename('current', Lon, Lat, time_filename, ResName); % 标准文件名

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

            if SWITCH.std
                depStddimID = netcdf.defDim(ncid, 'depth_std', length(Depth_std)); % 定义depth维度
            end

            if SWITCH.sgm
                sigdimID = netcdf.defDim(ncid, 'sigma', size(Siglay, 3)); % 定义sigma维度
            end

            if SWITCH.avg
                depAvgdimID = netcdf.defDim(ncid, 'depth_avg', size(Depth_avg, 1)); % 定义depth维度
                twodimID = netcdf.defDim(ncid, 'two', 2); % 定义depth维度
            end

            % 定义变量
            lon_id = netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID); % 经度
            lat_id = netcdf.defVar(ncid, 'latitude', 'NC_FLOAT', latdimID); % 纬度
            time_id = netcdf.defVar(ncid, 'time', 'double', timedimID); % 时间
            TIME_id = netcdf.defVar(ncid, 'TIME', 'NC_CHAR', [TIMEdimID, timedimID]); % 时间char
            netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
            netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
            netcdf.defVarDeflate(ncid, time_id, true, true, 5)
            netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

            if SWITCH.std
                dep_std_id = netcdf.defVar(ncid, 'depth_std', 'NC_FLOAT', [depStddimID]); % 深度
                netcdf.defVarDeflate(ncid, dep_std_id, true, true, 5)

                if SWITCH.u
                    u_std_id = netcdf.defVar(ncid, 'u_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % u_std
                    netcdf.defVarFill(ncid, u_std_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, u_std_id, true, true, 5)
                    U_std = Velement.U_std;
                end

                if SWITCH.v
                    v_std_id = netcdf.defVar(ncid, 'v_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % v_std
                    netcdf.defVarFill(ncid, v_std_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, v_std_id, true, true, 5)
                    V_std = Velement.V_std;
                end

                if SWITCH.w
                    w_std_id = netcdf.defVar(ncid, 'w_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % w_std
                    netcdf.defVarFill(ncid, w_std_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, w_std_id, true, true, 5)
                    W_std = Velement.W_std;
                end

            end

            if SWITCH.sgm
                bathy_id = netcdf.defVar(ncid, 'bathy', 'NC_FLOAT', [londimID, latdimID]); % 深度
                siglay_id = netcdf.defVar(ncid, 'siglay', 'NC_FLOAT', [londimID, latdimID, sigdimID]); % 深度
                netcdf.defVarFill(ncid, bathy_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                netcdf.defVarFill(ncid, siglay_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                netcdf.defVarDeflate(ncid, bathy_id, true, true, 5)
                netcdf.defVarDeflate(ncid, siglay_id, true, true, 5)

                if SWITCH.u
                    u_sgm_id = netcdf.defVar(ncid, 'u_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]); % 深度
                    netcdf.defVarFill(ncid, u_sgm_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, u_sgm_id, true, true, 5)
                    U_sgm = Velement.U_sgm;
                end

                if SWITCH.v
                    v_sgm_id = netcdf.defVar(ncid, 'v_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]); % 深度
                    netcdf.defVarFill(ncid, v_sgm_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, v_sgm_id, true, true, 5)
                    V_sgm = Velement.V_sgm;
                end

                if SWITCH.w
                    w_sgm_id = netcdf.defVar(ncid, 'w_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]); % 深度
                    netcdf.defVarFill(ncid, w_sgm_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, w_sgm_id, true, true, 5)
                    W_sgm = Velement.W_sgm;
                end

            end

            if SWITCH.avg
                dep_avg_id = netcdf.defVar(ncid, 'depth_avg', 'NC_FLOAT', [depAvgdimID, twodimID]); % 深度
                netcdf.defVarDeflate(ncid, dep_avg_id, true, true, 5)

                if SWITCH.u
                    u_avg_id = netcdf.defVar(ncid, 'u_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % u_avg
                    netcdf.defVarFill(ncid, u_avg_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, u_avg_id, true, true, 5)
                    U_avg = Velement.U_avg;
                end

                if SWITCH.v
                    v_avg_id = netcdf.defVar(ncid, 'v_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % v_avg
                    netcdf.defVarFill(ncid, v_avg_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, v_avg_id, true, true, 5)
                    V_avg = Velement.V_avg;
                end

                if SWITCH.w
                    w_avg_id = netcdf.defVar(ncid, 'w_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % w_avg
                    netcdf.defVarFill(ncid, w_avg_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                    netcdf.defVarDeflate(ncid, w_avg_id, true, true, 5)
                    W_avg = Velement.W_avg;
                end

            end

            if SWITCH.ua
                ua_id = netcdf.defVar(ncid, 'ua', 'NC_FLOAT', [londimID, latdimID, timedimID]); % ua
                netcdf.defVarFill(ncid, ua_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                netcdf.defVarDeflate(ncid, ua_id, true, true, 5)
                Ua = Velement.Ua;
            end

            if SWITCH.va
                va_id = netcdf.defVar(ncid, 'va', 'NC_FLOAT', [londimID, latdimID, timedimID]); % va
                netcdf.defVarFill(ncid, va_id, false, calc_fillvalue('NC_FLOAT', 'LowLevel')); % 设置缺省值
                netcdf.defVarDeflate(ncid, va_id, true, true, 5)
                Va = Velement.Va;
            end

            % -----
            netcdf.endDef(ncid); % 结束nc文件定义
            % 将数据放入相应的变量
            netcdf.putVar(ncid, lon_id, Lon); % 经度
            netcdf.putVar(ncid, lat_id, Lat); % 纬度
            netcdf.putVar(ncid, time_id, 0, length(time), time); % 时间
            netcdf.putVar(ncid, TIME_id, [0, 0], [size(char(TIME), 2), size(char(TIME), 1)], char(TIME)'); % 时间char

            if SWITCH.std
                netcdf.putVar(ncid, dep_std_id, Depth_std); % 深度

                if SWITCH.u
                    netcdf.putVar(ncid, u_std_id, [0, 0, 0, 0], [size(U_std, 1), size(U_std, 2), size(U_std, 3), size(U_std, 4)], U_std); % u
                end

                if SWITCH.v
                    netcdf.putVar(ncid, v_std_id, [0, 0, 0, 0], [size(V_std, 1), size(V_std, 2), size(V_std, 3), size(V_std, 4)], V_std); % v
                end

                if SWITCH.w
                    netcdf.putVar(ncid, w_std_id, [0, 0, 0, 0], [size(W_std, 1), size(W_std, 2), size(W_std, 3), size(W_std, 4)], W_std); % w
                end

            end

            if SWITCH.sgm
                netcdf.putVar(ncid, bathy_id, Bathy); % bathy
                netcdf.putVar(ncid, siglay_id, Siglay); % Siglay

                if SWITCH.u
                    netcdf.putVar(ncid, u_sgm_id, [0, 0, 0, 0], [size(U_sgm, 1), size(U_sgm, 2), size(U_sgm, 3), size(U_sgm, 4)], U_sgm); % u_sgm
                end

                if SWITCH.v
                    netcdf.putVar(ncid, v_sgm_id, [0, 0, 0, 0], [size(V_sgm, 1), size(V_sgm, 2), size(V_sgm, 3), size(V_sgm, 4)], V_sgm); % v_sgm
                end

                if SWITCH.w
                    netcdf.putVar(ncid, w_sgm_id, [0, 0, 0, 0], [size(W_sgm, 1), size(W_sgm, 2), size(W_sgm, 3), size(W_sgm, 4)], W_sgm); % w_sgm
                end

            end

            if SWITCH.avg
                netcdf.putVar(ncid, dep_avg_id, Depth_avg); % 深度

                if SWITCH.u
                    netcdf.putVar(ncid, u_avg_id, [0, 0, 0, 0], [size(U_avg, 1), size(U_avg, 2), size(U_avg, 3), size(U_avg, 4)], U_avg); % u
                end

                if SWITCH.v
                    netcdf.putVar(ncid, v_avg_id, [0, 0, 0, 0], [size(V_avg, 1), size(V_avg, 2), size(V_avg, 3), size(V_avg, 4)], V_avg); % v
                end

                if SWITCH.w
                    netcdf.putVar(ncid, w_avg_id, [0, 0, 0, 0], [size(W_avg, 1), size(W_avg, 2), size(W_avg, 3), size(W_avg, 4)], W_avg); % w
                end

            end

            if SWITCH.ua
                netcdf.putVar(ncid, ua_id, [0, 0, 0], [size(Ua, 1), size(Ua, 2), size(Ua, 3)], Ua); % ua
            end

            if SWITCH.va
                netcdf.putVar(ncid, va_id, [0, 0, 0], [size(Va, 1), size(Va, 2), size(Va, 3)], Va); % va
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

            if SWITCH.std
                % ATTRS.depth_std.key = ATTRS.depth_std.value; % depth_std
                for key = fieldnames(ATTRS.depth_std)'
                    netcdf.putAtt(ncid, dep_std_id, key{1}, ATTRS.depth_std.(key{1}));
                end % depth_std

                if SWITCH.u
                    % ATTRS.u_std.key = ATTRS.u_std.value; % u_std
                    for key = fieldnames(ATTRS.u_std)'
                        netcdf.putAtt(ncid, u_std_id, key{1}, ATTRS.u_std.(key{1}));
                    end % u_std % u

                end

                if SWITCH.v
                    % ATTRS.v_std.key = ATTRS.v_std.value; % v_std
                    for key = fieldnames(ATTRS.v_std)'
                        netcdf.putAtt(ncid, v_std_id, key{1}, ATTRS.v_std.(key{1}));
                    end % v_std % v % v

                end

                if SWITCH.w
                    % ATTRS.w_std.key = ATTRS.w_std.value; % w_std
                    for key = fieldnames(ATTRS.w_std)'
                        netcdf.putAtt(ncid, w_std_id, key{1}, ATTRS.w_std.(key{1}));
                    end % w_std % w % w

                end

            end

            if SWITCH.sgm
                % ATTRS.bathy.key = ATTRS.bathy.value; % bathy
                for key = fieldnames(ATTRS.bathy)'
                    netcdf.putAtt(ncid, bathy_id, key{1}, ATTRS.bathy.(key{1}));
                end % bathy

                % ATTRS.siglay.key = ATTRS.siglay.value; % siglay
                for key = fieldnames(ATTRS.siglay)'
                    netcdf.putAtt(ncid, siglay_id, key{1}, ATTRS.siglay.(key{1}));
                end % siglay

                if SWITCH.u
                    % ATTRS.u_sgm.key = ATTRS.u_sgm.value; % u_sgm
                    for key = fieldnames(ATTRS.u_sgm)'
                        netcdf.putAtt(ncid, u_sgm_id, key{1}, ATTRS.u_sgm.(key{1}));
                    end % u_sgm % u

                end

                if SWITCH.v
                    % ATTRS.v_sgm.key = ATTRS.v_sgm.value; % v_sgm
                    for key = fieldnames(ATTRS.v_sgm)'
                        netcdf.putAtt(ncid, v_sgm_id, key{1}, ATTRS.v_sgm.(key{1}));
                    end % v_sgm % v

                end

                if SWITCH.w
                    % ATTRS.w_sgm.key = ATTRS.w_sgm.value; % w_sgm
                    for key = fieldnames(ATTRS.w_sgm)'
                        netcdf.putAtt(ncid, w_sgm_id, key{1}, ATTRS.w_sgm.(key{1}));
                    end % w_sgm % w

                end

            end

            if SWITCH.avg
                % ATTRS.depth_avg.key = ATTRS.depth_avg.value; % depth_avg
                for key = fieldnames(ATTRS.depth_avg)'
                    netcdf.putAtt(ncid, dep_avg_id, key{1}, ATTRS.depth_avg.(key{1}));
                end % depth_avg

                netcdf.putAtt(ncid, dep_avg_id, 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1, 1), Depth_avg(1, 2))); % Depth_avg

                if SWITCH.u
                    % ATTRS.u_avg.key = ATTRS.u_avg.value; % u_avg
                    for key = fieldnames(ATTRS.u_avg)'
                        netcdf.putAtt(ncid, u_avg_id, key{1}, ATTRS.u_avg.(key{1}));
                    end % u_avg % u

                end

                if SWITCH.v
                    % ATTRS.v_avg.key = ATTRS.v_avg.value; % v_avg
                    for key = fieldnames(ATTRS.v_avg)'
                        netcdf.putAtt(ncid, v_avg_id, key{1}, ATTRS.v_avg.(key{1}));
                    end % v_avg % v

                end

                if SWITCH.w
                    % ATTRS.w_avg.key = ATTRS.w_avg.value; % w_avg
                    for key = fieldnames(ATTRS.w_avg)'
                        netcdf.putAtt(ncid, w_avg_id, key{1}, ATTRS.w_avg.(key{1}));
                    end % w_avg % w

                end

            end

            if SWITCH.ua
                % ATTRS.ua.key = ATTRS.ua.value; % ua
                for key = fieldnames(ATTRS.ua)'
                    netcdf.putAtt(ncid, ua_id, key{1}, ATTRS.ua.(key{1}));
                end % ua

            end

            if SWITCH.va
                % ATTRS.va.key = ATTRS.va.value; % va
                for key = fieldnames(ATTRS.va)'
                    netcdf.putAtt(ncid, va_id, key{1}, ATTRS.va.(key{1}));
                end % va

            end

            % 写入global attribute
            varid_GA = netcdf.getConstant('NC_GLOBAL');

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
            netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'WriteProgram', ['netcdf_fvcom:', mfilename, ' V', Version]); % 写入程序信息
            netcdf.putAtt(ncid, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
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

            if SWITCH.std
                [scale_factor, add_offset] = calc_scale_offset(Depth_std, dtype);
                nccreate(ncname, 'depth_std', ...
                    'Dimensions', {'depth_std', length(Depth_std)}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.depth_std)'
                    ncwriteatt(ncname, 'depth_std', key{1}, ATTRS.depth_std.(key{1}));
                end

                ncwriteatt(ncname, 'depth_std', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'depth_std', 'add_offset', add_offset);
                ncwrite(ncname, 'depth_std', Depth_std);

                if SWITCH.u
                    [scale_factor, add_offset] = calc_scale_offset(Velement.U_std, dtype);
                    nccreate(ncname, 'u_std', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_std', length(Depth_std), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.u_std)'
                        ncwriteatt(ncname, 'u_std', key{1}, ATTRS.u_std.(key{1}));
                    end

                    ncwriteatt(ncname, 'u_std', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'u_std', 'add_offset', add_offset);
                    ncwrite(ncname, 'u_std', Velement.U_std);
                end

                if SWITCH.v
                    [scale_factor, add_offset] = calc_scale_offset(Velement.V_std, dtype);
                    nccreate(ncname, 'v_std', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_std', length(Depth_std), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.v_std)'
                        ncwriteatt(ncname, 'v_std', key{1}, ATTRS.v_std.(key{1}));
                    end

                    ncwriteatt(ncname, 'v_std', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'v_std', 'add_offset', add_offset);
                    ncwrite(ncname, 'v_std', Velement.V_std);
                end

                if SWITCH.w
                    [scale_factor, add_offset] = calc_scale_offset(Velement.W_std, dtype);
                    nccreate(ncname, 'w_std', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_std', length(Depth_std), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.w_std)'
                        ncwriteatt(ncname, 'w_std', key{1}, ATTRS.w_std.(key{1}));
                    end

                    ncwriteatt(ncname, 'w_std', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'w_std', 'add_offset', add_offset);
                    ncwrite(ncname, 'w_std', Velement.W_std);
                end

            end

            if SWITCH.sgm
                [scale_factor, add_offset] = calc_scale_offset(Bathy, dtype);
                nccreate(ncname, 'bathy', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat)}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
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
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.siglay)'
                    ncwriteatt(ncname, 'siglay', key{1}, ATTRS.siglay.(key{1}));
                end

                ncwriteatt(ncname, 'siglay', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'siglay', 'add_offset', add_offset);
                ncwrite(ncname, 'siglay', Siglay);

                if SWITCH.u
                    [scale_factor, add_offset] = calc_scale_offset(Velement.U_sgm, dtype);
                    nccreate(ncname, 'u_sgm', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'sigma', size(Siglay, 3), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.u_sgm)'
                        ncwriteatt(ncname, 'u_sgm', key{1}, ATTRS.u_sgm.(key{1}));
                    end

                    ncwriteatt(ncname, 'u_sgm', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'u_sgm', 'add_offset', add_offset);
                    ncwrite(ncname, 'u_sgm', Velement.U_sgm);
                end

                if SWITCH.v
                    [scale_factor, add_offset] = calc_scale_offset(Velement.V_sgm, dtype);
                    nccreate(ncname, 'v_sgm', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'sigma', size(Siglay, 3), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.v_sgm)'
                        ncwriteatt(ncname, 'v_sgm', key{1}, ATTRS.v_sgm.(key{1}));
                    end

                    ncwriteatt(ncname, 'v_sgm', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'v_sgm', 'add_offset', add_offset);
                    ncwrite(ncname, 'v_sgm', Velement.V_sgm);
                end

                if SWITCH.w
                    [scale_factor, add_offset] = calc_scale_offset(Velement.W_sgm, dtype);
                    nccreate(ncname, 'w_sgm', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'sigma', size(Siglay, 3), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.w_sgm)'
                        ncwriteatt(ncname, 'w_sgm', key{1}, ATTRS.w_sgm.(key{1}));
                    end

                    ncwriteatt(ncname, 'w_sgm', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'w_sgm', 'add_offset', add_offset);
                    ncwrite(ncname, 'w_sgm', Velement.W_sgm);
                end

            end

            if SWITCH.avg
                [scale_factor, add_offset] = calc_scale_offset(Depth_avg, dtype);
                nccreate(ncname, 'depth_avg', ...
                    'Dimensions', {'depth_avg', size(Depth_avg, 1), 'two', 2}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.depth_avg)'
                    ncwriteatt(ncname, 'depth_avg', key{1}, ATTRS.depth_avg.(key{1}));
                end

                ncwriteatt(ncname, 'depth_avg', 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1, 1), Depth_avg(1, 2)));
                ncwriteatt(ncname, 'depth_avg', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'depth_avg', 'add_offset', add_offset);
                ncwrite(ncname, 'depth_avg', Depth_avg);

                if SWITCH.u
                    [scale_factor, add_offset] = calc_scale_offset(Velement.U_avg, dtype);
                    nccreate(ncname, 'u_avg', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_avg', size(Depth_avg, 1), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.u_avg)'
                        ncwriteatt(ncname, 'u_avg', key{1}, ATTRS.u_avg.(key{1}));
                    end

                    ncwriteatt(ncname, 'u_avg', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'u_avg', 'add_offset', add_offset);
                    ncwrite(ncname, 'u_avg', Velement.U_avg);
                end

                if SWITCH.v
                    [scale_factor, add_offset] = calc_scale_offset(Velement.V_avg, dtype);
                    nccreate(ncname, 'v_avg', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_avg', size(Depth_avg, 1), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.v_avg)'
                        ncwriteatt(ncname, 'v_avg', key{1}, ATTRS.v_avg.(key{1}));
                    end

                    ncwriteatt(ncname, 'v_avg', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'v_avg', 'add_offset', add_offset);
                    ncwrite(ncname, 'v_avg', Velement.V_avg);
                end

                if SWITCH.w
                    [scale_factor, add_offset] = calc_scale_offset(Velement.W_avg, dtype);
                    nccreate(ncname, 'w_avg', ...
                        'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'depth_avg', size(Depth_avg, 1), 'time', Inf}, ...
                        'Datatype', dtype, ...
                        'Format', 'netcdf4', ...
                        'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                        'DeflateLevel', 5, ...
                        'Shuffle', true);

                    for key = fieldnames(ATTRS.w_avg)'
                        ncwriteatt(ncname, 'w_avg', key{1}, ATTRS.w_avg.(key{1}));
                    end

                    ncwriteatt(ncname, 'w_avg', 'scale_factor', scale_factor);
                    ncwriteatt(ncname, 'w_avg', 'add_offset', add_offset);
                    ncwrite(ncname, 'w_avg', Velement.W_avg);
                end

            end

            if SWITCH.ua
                [scale_factor, add_offset] = calc_scale_offset(Velement.Ua, dtype);
                nccreate(ncname, 'ua', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.ua)'
                    ncwriteatt(ncname, 'ua', key{1}, ATTRS.ua.(key{1}));
                end

                ncwriteatt(ncname, 'ua', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'ua', 'add_offset', add_offset);
                ncwrite(ncname, 'ua', Velement.Ua);
            end

            if SWITCH.va
                [scale_factor, add_offset] = calc_scale_offset(Velement.Va, dtype);
                nccreate(ncname, 'va', ...
                    'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
                    'Datatype', dtype, ...
                    'Format', 'netcdf4', ...
                    'FillValue', calc_fillvalue(dtype, 'HighLevel'), ...
                    'DeflateLevel', 5, ...
                    'Shuffle', true);

                for key = fieldnames(ATTRS.va)'
                    ncwriteatt(ncname, 'va', key{1}, ATTRS.va.(key{1}));
                end

                ncwriteatt(ncname, 'va', 'scale_factor', scale_factor);
                ncwriteatt(ncname, 'va', 'add_offset', add_offset);
                ncwrite(ncname, 'va', Velement.Va);
            end

            % 写入global attribute
            for key = fieldnames(ATTRS.GLOBAL)'
                ncwriteatt(ncname, '/', key{1}, ATTRS.GLOBAL.(key{1}));
            end

            if ~isempty(conf)
                NC = read_NC(conf);
                fields = fieldnames(NC);

                for iname = 1:length(fields)
                    %  netcdf.putAtt(ncid, varid_GA, 'source', conf.P_Source); % 数据源
                    ncwriteatt(ncname, '/', fields{iname}, NC.(fields{iname}));
                end

            end

            ncwriteatt(ncname, '/', 'product_name', S_name); % 文件名
            ncwriteatt(ncname, '/', 'WriteProgram', ['netcdf_fvcom:', mfilename, ' V', Version]); % 写入程序信息
            ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now", "Inputformat", "yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录

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
