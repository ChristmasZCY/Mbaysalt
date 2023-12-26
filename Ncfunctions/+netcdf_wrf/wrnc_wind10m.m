function wrnc_wind10m(ncid,Lon,Lat,time,U10,V10,options)
    %       This function is used to write wind speed at 10m to netcdf file.
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id          || required: True || type: int    || example: 1
    %       Lon:             longitude               || required: True || type: double || example: [120.5, 121.5]
    %       Lat:             latitude                || required: True || type: double || example: [30.5, 31.5]
    %       time:            time                    || required: True || type: double || format: posixtime
    %       U10:             wind speed at 10m       || required: True || type: double || format: matrix
    %       V10:             wind speed at 10m       || required: True || type: double || format: matrix
    %       options:         optional parameters      
    %           GA:          global attribute        || required: False|| type: struct || example: struct('GA_START_DATE','2020-01-01 00:00:00')
    %           conf:        configuration struct    || required: False|| type: struct || example: struct
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-12-24:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'conf',conf)
    %       netcdf_wrf.wrnc_wind10m(ncid,Lon,Lat,time,U10,V10，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'),'conf',conf)
    % =================================================================================================================

    arguments(Input)
        ncid {mustBeNumeric}
        Lon {mustBeNumeric}
        Lat {mustBeNumeric}
        time {mustBeNumeric}
        U10 {mustBeNumeric}
        V10 {mustBeNumeric}
        options.GA struct = struct()
        options.conf {struct} = struct()
    end

    GA = options.GA;
    conf = options.conf;

    % version
    Version = '3.0';
    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('wind',Lon,Lat,time_filename,ResName); % 标准文件名
    osprint2('INFO',['Transfor --> ',S_name])

    if ~isempty(GA)
        if ~isfield(GA,'START_DATE')
            GA.START_DATE = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));
        end
    end
   
    % 定义维度
    londimID = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
    latdimID = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
    timedimID = netcdf.defDim(ncid,'time',    netcdf.getConstant('NC_UNLIMITED'));  % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid,'DateStr',  size(char(TIME),2));                 % 定义TIME维度

    % 定义变量
    lon_id  =  netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);                       % 经度
    lat_id  =  netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);                       % 纬度
    time_id =  netcdf.defVar(ncid, 'time',      'double',   timedimID);                      % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID, timedimID]);          % 时间char
    U10_id  =  netcdf.defVar(ncid, 'wind_U10',  'NC_FLOAT', [londimID, latdimID, timedimID]); % U10
    V10_id  =  netcdf.defVar(ncid, 'wind_V10',  'NC_FLOAT', [londimID, latdimID, timedimID]); % V10

    netcdf.defVarFill(ncid,      U10_id,      false,      9.9692100e+36); % 设置缺省值
    netcdf.defVarFill(ncid,      V10_id,      false,      9.9692100e+36); % 设置缺省值

    netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
    netcdf.defVarDeflate(ncid, U10_id, true, true, 5)
    netcdf.defVarDeflate(ncid, V10_id, true, true, 5)

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id, Lon);  % 经度
    netcdf.putVar(ncid, lat_id, Lat);  % 纬度
    netcdf.putVar(ncid, time_id, 0, length(time), time);  % 时间
    netcdf.putVar(ncid, TIME_id, [0,0], [size(char(TIME),2),size(char(TIME),1)],char(TIME)');% 时间char
    netcdf.putVar(ncid, U10_id, [0,0,0], [size(U10,1), size(U10,2), size(U10,3)], U10);        % U10
    netcdf.putVar(ncid, V10_id, [0,0,0], [size(V10,1), size(V10,2), size(V10,3)], V10);        % V10

    % -----
    netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
    % 添加变量属性

    netcdf.putAtt(ncid,lon_id, 'units',        'degrees_east');                      % 经度
    netcdf.putAtt(ncid,lon_id, 'long_name',    'longitude');                         % 经度
    netcdf.putAtt(ncid,lon_id, 'standard_name','longitude');                         % 经度
    netcdf.putAtt(ncid,lon_id, 'axis',         'X');                                 % 经度
    netcdf.putAtt(ncid,lon_id, 'westernmost',   num2str(min(Lon,[],"all"),'%3.2f')); % 经度
    netcdf.putAtt(ncid,lon_id, 'easternmost',   num2str(max(Lon,[],"all"),'%3.2f')); % 经度

    netcdf.putAtt(ncid,lat_id, 'units',        'degrees_north');                     % 纬度
    netcdf.putAtt(ncid,lat_id, 'long_name',    'latitude');                          % 纬度
    netcdf.putAtt(ncid,lon_id, 'standard_name','latitude');                          % 纬度
    netcdf.putAtt(ncid,lon_id, 'axis',         'Y');                                 % 纬度
    netcdf.putAtt(ncid,lat_id, 'southernmost',  num2str(min(Lat,[],"all"),'%2.2f')); % 纬度
    netcdf.putAtt(ncid,lat_id, 'northernmost',  num2str(max(Lat,[],"all"),'%2.2f')); % 纬度

    netcdf.putAtt(ncid,time_id,'units',        'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid,time_id,'long_name',    'UTC time');                          % 时间
    netcdf.putAtt(ncid,time_id,'standard_name','UTC time');                          % 时间
    netcdf.putAtt(ncid,time_id,'calendar',     'gregorian');                         % 时间

    netcdf.putAtt(ncid,TIME_id,'reference_time', TIME_reference);       % 时间char
    netcdf.putAtt(ncid,TIME_id,'long_name',    'UTC time');             % 时间char
    netcdf.putAtt(ncid,TIME_id,'standard_name','UTC time');             % 时间char
    netcdf.putAtt(ncid,TIME_id,'start_time',    TIME_start_date); % 时间char
    netcdf.putAtt(ncid,TIME_id,'end_time',      TIME_end_date);   % 时间char

    netcdf.putAtt(ncid,U10_id, 'units',        'm/s');                       % U10
    netcdf.putAtt(ncid,U10_id, 'long_name',    '10 meter U wind component'); % U10
    netcdf.putAtt(ncid,U10_id, 'standard_name','eastward_wind');             % U10

    netcdf.putAtt(ncid,V10_id, 'units',        'm/s');                      % V10
    netcdf.putAtt(ncid,V10_id, 'long_name',    '10 meter V wind component');% V10
    netcdf.putAtt(ncid,V10_id, 'standard_name','northward_wind');           % V10


    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    if class(conf) == "struct" && isfield(conf,"P_Source")
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',     conf.P_Source); % 数据源
    end
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA.START_DATE);               % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    if class(conf) == "struct" && isfield(conf,"P_Version")
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',num2str(conf.P_Version)]);    % 程序版本号
    end
    netcdf.close(ncid);    % 关闭nc文件
end

