function wrnc_t2m(ncid,Lon,Lat,time,T2,varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to write the temperature at 2m to the nc file
    % =================================================================================================================
    % parameter:
    %       ncid:            netcdf file id          || required: True || type: int    || format: 1
    %       Lon:             longitude               || required: True || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True || type: double || format: [30.5, 31.5]
    %       time:            time                    || required: True || type: double || format: posixtime
    %       T2:              temperature at 2m       || required: True || type: double || format: [120,120,120]
    %       varargin:        optional parameters      
    %           GA:          global attribute        || required: False|| type: struct || format: struct('GA_START_DATE','2020-01-01 00:00:00')
    %           conf:        configuration struct    || required: False|| type: struct || format: struct
    % =================================================================================================================
    % example:
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2)
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2，'GA',struct('GA_START_DATE','2020-01-01 00:00:00'))
    %       netcdf_wrf.wrnc_t2m(ncid,Lon,Lat,time,T2，'conf',conf)
    % =================================================================================================================

    varargin = read_varargin(varargin,{'GA'},{''});
    varargin = read_varargin(varargin,{'conf'},{false});

    % version
    Version = '2.1';
    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('temperature',Lon,Lat,time_filename,ResName); % 标准文件名
    osprint(['Transfor --> ',S_name])

    if ~isempty(GA)
        if ~isfield(GA,'START_DATE')
            GA.START_DATE = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));
        end
    end
    
    % start_date_gb = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));

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

    netcdf.defVarFill(ncid,      T2_id,      false,      9.9692100e+36); % 设置缺省值

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

    netcdf.putAtt(ncid,T2_id, 'units',        'K');                        % T2
    netcdf.putAtt(ncid,T2_id, 'long_name',    'temperature at 2m');        % T2
    netcdf.putAtt(ncid,T2_id, 'standard_name','temperature_at_2m');        % T2


    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    if class(conf) == "struct"
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',     conf.P_Source); % 数据源
    end
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA.START_DATE);               % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    if class(conf) == "struct"
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',num2str(conf.P_Version)]);    % 程序版本号
    end
    netcdf.close(ncid);    % 关闭nc文件

end
