function rtn = wrnc_t2m(NC,Lon,Lat,time,T2,varargin)
    %       This function is used to write the temperature at 2m to the nc file
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
    %       T2:              temperature at 2m      || required: True   || type: double     || format: [120,120,120]
    %       varargin:        optional parameters      
    %           GA:          global attribute       || required: False  || type: struct     || format: struct('GA_START_DATE','2020-01-01 00:00:00')
    %           conf:        configuration struct   || required: False  || type: struct     || format: struct
    %           dtype:       data type of variable  || required: False  || type: namevalue  || format: 'dtype','int16'
    % =================================================================================================================
    % Returns:
    %       rtn:            return struct with info
    %           .Version:   version of this function
    %           .Method:    method used to write nc file
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                by Christmas;
    %       2026-03-31:     Added ncwrite support,  by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2)
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2，'conf',conf)
    %       netcdf_wrf.wrnc_t2m('t2.nc'',Lon,Lat,time,T2)
    %       netcdf_wrf.wrnc_t2m('t2.nc'',Lon,Lat,time,T2，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_t2m('t2.nc'',Lon,Lat,time,T2，'conf',conf)
    %       netcdf_wrf.wrnc_t2m('t2.nc'',Lon,Lat,time,T2,'dtype','int16')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'GA'},{''});
    varargin = read_varargin(varargin,{'conf'},{false});
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

    ATTRS = json_load(fullfile(fileparts(mfilename('fullpath')), 'attrs.json'));

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('temperature',Lon,Lat,time_filename,ResName); % 标准文件名
    osprint2('INFO',['Transfor --> ',S_name])

    if ~isempty(GA)
        if ~isfield(GA,'START_DATE')
            GA.START_DATE = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));
        end
    else
        GA.START_DATE = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));
    end

    switch Method
    case 'LowLevel'
        % 定义维度
        londimID = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
        latdimID = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
        timedimID = netcdf.defDim(ncid,'time',    netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
        TIMEdimID = netcdf.defDim(ncid,'DateStr',  size(char(TIME),2));                 % 定义TIME维度

        % 定义变量
        lon_id  =  netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);                       % 经度
        lat_id  =  netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);                       % 纬度
        time_id =  netcdf.defVar(ncid, 'time',      'double',   timedimID);                      % 时间
        TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID, timedimID]);          % 时间char
        T2_id   =  netcdf.defVar(ncid, 'temperature',    'NC_FLOAT', [londimID, latdimID, timedimID]); % T2

        netcdf.defVarFill(ncid,      T2_id,      false,      realmax('single')); % 设置缺省值

        netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
        netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
        netcdf.defVarDeflate(ncid, time_id, true, true, 5)
        netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
        netcdf.defVarDeflate(ncid, T2_id, true, true, 5)

        % -----
        netcdf.endDef(ncid);    % 结束nc文件定义
        % 将数据放入相应的变量
        netcdf.putVar(ncid, lon_id, Lon);  % 经度
        netcdf.putVar(ncid, lat_id, Lat);  % 纬度
        netcdf.putVar(ncid, time_id, 0, length(time), time);  % 时间
        netcdf.putVar(ncid, TIME_id, [0,0], [size(char(TIME),2),size(char(TIME),1)],char(TIME)');% 时间char
        netcdf.putVar(ncid, T2_id, [0,0,0], [size(T2,1), size(T2,2), size(T2,3)], T2);        % T2

        % -----
        netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
        % 添加变量属性
        % ATTRS.longitude.key = ATTRS.longitude.value; % 经度
        for key = fieldnames(ATTRS.longitude)'
            netcdf.putAtt(ncid, lon_id, key{1}, ATTRS.longitude.(key{1}));
        end                            % 经度
        netcdf.putAtt(ncid,lon_id, 'westernmost',   num2str(min(Lon,[],"all"),'%3.2f')); % 经度
        netcdf.putAtt(ncid,lon_id, 'easternmost',   num2str(max(Lon,[],"all"),'%3.2f')); % 经度

        % ATTRS.latitude.key = ATTRS.latitude.value; % 纬度
        for key = fieldnames(ATTRS.latitude)'
            netcdf.putAtt(ncid, lat_id, key{1}, ATTRS.latitude.(key{1}));
        end                     % 纬度
        netcdf.putAtt(ncid,lat_id, 'southernmost',  num2str(min(Lat,[],"all"),'%2.2f')); % 纬度
        netcdf.putAtt(ncid,lat_id, 'northernmost',  num2str(max(Lat,[],"all"),'%2.2f')); % 纬度

        % ATTRS.time.key = ATTRS.time.value; % 时间
        for key = fieldnames(ATTRS.time)'
            netcdf.putAtt(ncid, time_id, key{1}, ATTRS.time.(key{1}));
        end

        % ATTRS.TIME.key = ATTRS.TIME.value; % 时间char
        for key = fieldnames(ATTRS.TIME)'
            netcdf.putAtt(ncid, TIME_id, key{1}, ATTRS.TIME.(key{1}));
        end
        netcdf.putAtt(ncid,TIME_id,'reference_time', TIME_reference);       % 时间char
        netcdf.putAtt(ncid,TIME_id,'start_time',    TIME_start_date); % 时间char
        netcdf.putAtt(ncid,TIME_id,'end_time',      TIME_end_date);   % 时间char

        % ATTRS.temperature.key = ATTRS.temperature.value; % T2
        for key = fieldnames(ATTRS.temperature)'
            netcdf.putAtt(ncid, T2_id, key{1}, ATTRS.temperature.(key{1}));
        end

        % 写入global attribute
        varid_GA = netcdf.getConstant('NC_GLOBAL');
        for key = fieldnames(ATTRS.GLOBAL)'
            netcdf.putAtt(ncid, varid_GA, key{1}, ATTRS.global.(key{1}));
        end                     % global attribute
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'WriteProgram',   ['netcdf_wrf:', mfilename, ' V', Version]); % 写入程序信息
        if class(conf) == "struct" && isfield(conf,"P_Source")
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',     conf.P_Source); % 数据源
        end
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA.START_DATE);               % 起报时间
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
        netcdf.close(ncid);    % 关闭nc文件
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

        [scale_factor, add_offset] = calc_scale_offset(T2, dtype);
        nccreate(ncname, 'temperature', ...
            'Dimensions', {'longitude', length(Lon), 'latitude', length(Lat), 'time', Inf}, ...
            'Datatype', dtype, ...
            'Format', 'netcdf4', ...
            'FillValue', intmin(dtype), ...
            'DeflateLevel', 5, ...
            'Shuffle', true);
        for key = fieldnames(ATTRS.temperature)'
            ncwriteatt(ncname, 'temperature', key{1}, ATTRS.temperature.(key{1}));
        end
        ncwriteatt(ncname, 'temperature', 'scale_factor', scale_factor);
        ncwriteatt(ncname, 'temperature', 'add_offset', add_offset);
        ncwrite(ncname, 'temperature', T2, [1,1,1]);

        % 写入global attribute
        for key = fieldnames(ATTRS.GLOBAL)'
            ncwriteatt(ncname, '/', key{1}, ATTRS.GLOBAL.(key{1}));
        end
        ncwriteatt(ncname, '/', 'product_name', S_name);
        ncwriteatt(ncname, '/', 'WriteProgram', ['netcdf_wrf:', mfilename, ' V', Version]);
        if class(conf) == "struct" && isfield(conf,"P_Source")
            ncwriteatt(ncname, '/', 'source', conf.P_Source);
        end
        ncwriteatt(ncname, '/', 'start', GA.START_DATE);
        ncwriteatt(ncname, '/', 'history', ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]);

    end

    rtn.Version = Version;
    rtn.Method = Method;

    return;

end
