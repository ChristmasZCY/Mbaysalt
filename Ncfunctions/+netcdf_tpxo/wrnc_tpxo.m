function wrnc_tpxo(ncid,Lon,Lat,time,U,V,Zeta)
    %       This function is used to write the tide current (u/v/zeta) to the netcdf file
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id          || required: True || type: int    || format: 1
    %       Lon:             longitude               || required: True || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True || type: double || format: [30.5, 31.5]
    %       time:            time                    || required: True || type: double || format: posixtime
    %       U:               u                       || required: True || type: double || format: matrix
    %       V:               v                       || required: True || type: double || format: matrix
    %       Zeta:            zeta                    || required: True || type: double || format: matrix
    % =================================================================================================================
    % Example:
    %       netcdf_tpxo.wrnc_tpxo(ncid,Lon,Lat,time,U,V,Zeta)
    % =================================================================================================================

    % version
    Version = '2.1';
    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('tide',Lon,Lat,time_filename,ResName); % 标准文件名
    osprints('INFO',['Transfor --> ',S_name])
    
    GA_start_date = char(datetime("now","Format","yyyy-MM-dd_HH:mm:ss"));

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
    u_id    =  netcdf.defVar(ncid, 'tide_u',    'NC_FLOAT', [londimID, latdimID, timedimID]); % u
    v_id    =  netcdf.defVar(ncid, 'tide_v',    'NC_FLOAT', [londimID, latdimID, timedimID]); % v
    h_id    =  netcdf.defVar(ncid, 'tide_h',    'NC_FLOAT', [londimID, latdimID, timedimID]); % h

    netcdf.defVarFill(ncid,      u_id,      false,      9.9692100e+36); % 设置缺省值
    netcdf.defVarFill(ncid,      v_id,      false,      9.9692100e+36); % 设置缺省值
    netcdf.defVarFill(ncid,      h_id,      false,      9.9692100e+36); % 设置缺省值

    netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
    netcdf.defVarDeflate(ncid, u_id, true, true, 5)
    netcdf.defVarDeflate(ncid, v_id, true, true, 5)
    netcdf.defVarDeflate(ncid, h_id, true, true, 5)

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id, Lon);  % 经度
    netcdf.putVar(ncid, lat_id, Lat);  % 纬度
    netcdf.putVar(ncid, time_id, 0, length(time), time);  % 时间
    netcdf.putVar(ncid, TIME_id, [0,0], [size(char(TIME),2),size(char(TIME),1)],char(TIME)');% 时间char
    netcdf.putVar(ncid, u_id, [0,0,0], [size(U,1), size(U,2), size(U,3)], U);        % u
    netcdf.putVar(ncid, v_id, [0,0,0], [size(V,1), size(V,2), size(V,3)], V);        % v
    netcdf.putVar(ncid, h_id, [0,0,0], [size(Zeta,1), size(Zeta,2), size(Zeta,3)], Zeta); % h

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

    netcdf.putAtt(ncid,time_id,'units',        'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid,time_id,'long_name',    'UTC time');                          % 时间
    netcdf.putAtt(ncid,time_id,'calendar',     'gregorian');                         % 时间

    netcdf.putAtt(ncid,TIME_id,'reference',     TIME_reference);       % 时间char
    netcdf.putAtt(ncid,TIME_id,'long_name',    'UTC time');             % 时间char
    netcdf.putAtt(ncid,TIME_id,'start_date',    TIME_start_date); % 时间char
    netcdf.putAtt(ncid,TIME_id,'end_date',      TIME_end_date);   % 时间char

    netcdf.putAtt(ncid,u_id, 'units',        'm/s');                                 % u
    netcdf.putAtt(ncid,u_id, 'long_name',    'tide eastward water velocity');        % u

    netcdf.putAtt(ncid,v_id, 'units',        'm/s');                                 % v
    netcdf.putAtt(ncid,v_id, 'long_name',    'tide northward water velocity');       % v

    netcdf.putAtt(ncid,h_id, 'units',        'm');                                   % h
    netcdf.putAtt(ncid,h_id, 'long_name',    'tide water level');                    % h

    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',         '213-TPXO_Global'); % 数据源
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA_start_date);               % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',Version]);    % 程序版本号
    netcdf.close(ncid);    % 关闭nc文件

end
