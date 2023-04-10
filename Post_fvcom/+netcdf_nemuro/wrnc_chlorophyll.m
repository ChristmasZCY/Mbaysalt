function wrnc_chlorophyll(ncid,Lon,Lat,Depth,time,Chlo,start_date_gb)
    % =================================================================================================================
    % discription:
    %       This function is used to write the chlorophyll data to the netcdf file
    % =================================================================================================================
    % parameter:
    %       ncid:            netcdf file id          || required: True || type: int    || format: 1
    %       Lon:             longitude               || required: True || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True || type: double || format: [30.5, 31.5]
    %       Depth:           depth of each level     || required: True || type: double || format: matrix
    %       time:            time                    || required: True || type: double || format: posixtime
    %       Chlo:            chlorophyll             || required: True || type: double || format: matrix
    %       start_date_gb:   time of forecast start  || required: True || type: string || format: '20221110'
    % =================================================================================================================
    % example:
    %       netcdf_nemuro.wrnc_chlorophyll(ncid,Lon,Lat,Depth,time,Chlo,start_date_gb)
    % =================================================================================================================

    % version
    Version = '2.1';
    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/nanmean(diff(Lon)), '%2.f');
    S_name = standard_filename('chlorophyll',Lon,Lat,time_filename,ResName); % 标准文件名
    osprint(['Transfor --> ',S_name])

    % 定义维度
    londimID = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
    latdimID = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
    if isvector(Depth)
        depdimID = netcdf.defDim(ncid, 'depth',    length(Depth));                  % 定义depth维度
    else
        depdimID = netcdf.defDim(ncid, 'depth',    size(Depth,3));                  % 定义depth维度
    end
    timedimID = netcdf.defDim(ncid,'time',    netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid,'DateStr',  size(char(TIME),2));                 % 定义TIME维度

    % 定义变量
    lon_id  =  netcdf.defVar(ncid,  'longitude', 'NC_FLOAT', londimID);                       % 经度
    lat_id  =  netcdf.defVar(ncid,  'latitude',  'NC_FLOAT', latdimID);                       % 纬度
    if isvector(Depth)
        dep_id  =  netcdf.defVar(ncid,  'depth',     'NC_FLOAT', [depdimID]);  % 深度
    else
        dep_id  =  netcdf.defVar(ncid,  'Depth',     'NC_FLOAT', [londimID, latdimID,depdimID]);  % 深度
    end
    time_id =  netcdf.defVar(ncid, 'time',      'double', timedimID);                      % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID,timedimID]);          % 时间char
    chlo_id =  netcdf.defVar(ncid, 'chlorophyll',    'NC_FLOAT', [londimID, latdimID,depdimID,timedimID]); % 叶绿素

    netcdf.defVarFill(ncid,      chlo_id,      false,      9.9692100e+36); % 设置缺省值

    netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
    netcdf.defVarDeflate(ncid, dep_id, true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
    netcdf.defVarDeflate(ncid, chlo_id, true, true, 5)

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid,lon_id,                                                 Lon);         % 经度
    netcdf.putVar(ncid,lat_id,                                                 Lat);         % 纬度
    netcdf.putVar(ncid,dep_id,                                                Depth);       % 深度
    netcdf.putVar(ncid,time_id,  0,      length(time),                          time);       % 时间
    netcdf.putVar(ncid,TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)],char(TIME)');% 时间char
    netcdf.putVar(ncid,chlo_id,  [0,0,0,0],[size(Chlo,1), size(Chlo,2), size(Chlo,3),size(Chlo,4)],  Chlo);     % 叶绿素

    % -----
    netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
    % 添加变量属性
    netcdf.putAtt(ncid,lon_id, 'units',        'degrees_east');                      % 经度
    netcdf.putAtt(ncid,lon_id, 'long_name',    'longitude');                         % 经度
    netcdf.putAtt(ncid,lon_id, 'westernmost',   num2str(min(Lon,[],"all"),'%3.2f')); % 经度
    netcdf.putAtt(ncid,lon_id, 'easternmost',   num2str(max(Lon,[],"all"),'%3.2f')); % 经度

    netcdf.putAtt(ncid,lat_id, 'units',        'degrees_north');                     % 纬度
    netcdf.putAtt(ncid,lat_id, 'long_name',    'latitude');                          % 纬度
    netcdf.putAtt(ncid,lat_id, 'southernmost',  num2str(min(Lat,[],"all"),'%2.2f')); % 纬度
    netcdf.putAtt(ncid,lat_id, 'northernmost',  num2str(max(Lat,[],"all"),'%2.2f')); % 纬度

    netcdf.putAtt(ncid,dep_id, 'units',        'm');                                 % 深度
    netcdf.putAtt(ncid,dep_id, 'long_name',    'depth');                             % 深度
    netcdf.putAtt(ncid,dep_id, 'positive',     'down');                              % 深度

    netcdf.putAtt(ncid,time_id,'units',        'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid,time_id,'long_name',    'UTC time');                          % 时间
    netcdf.putAtt(ncid,time_id,'calendar',     'gregorian');                         % 时间

    netcdf.putAtt(ncid,TIME_id,'reference',     TIME_reference);       % 时间char
    netcdf.putAtt(ncid,TIME_id,'long_name',    'UTC time');             % 时间char
    netcdf.putAtt(ncid,TIME_id,'start_date',    TIME_start_date); % 时间char
    netcdf.putAtt(ncid,TIME_id,'end_date',      TIME_end_date);   % 时间char

    netcdf.putAtt(ncid,chlo_id, 'units',        'mg/m^3');                            % 叶绿素
    netcdf.putAtt(ncid,chlo_id, 'long_name',    'chlorophyll');                       % 叶绿素

    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',         '147-NEMURO_SCS'); % 数据源
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          start_date_gb);    % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',Version]);    % 程序版本号
    netcdf.close(ncid);    % 关闭nc文件

end