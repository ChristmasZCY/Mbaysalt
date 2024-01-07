function wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,GA_start_date,varargin)
    %       This function is used to write the carbonate air-sea flux of CO2 into the netcdf file.
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id                   || required: True  || type: int    || format: 1
    %       Lon:             longitude                        || required: True  || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                         || required: True  || type: double || format: [30.5, 31.5]
    %       time:            time                             || required: True  || type: double || format: posixtime
    %       Casfco2:         carbonate air-sea flux of CO2    || required: True  || type: double || format: matrix
    %       GA_start_date:   time of forecast start           || required: True  || type: string || format: '2023-05-30_00:00:00'
    %       varargin:        optional parameters     
    %           conf:        configuration struct             || required: False || type: struct || format: struct
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-12-29:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,GA_start_date)
    %       netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Casfco2,GA_start_date,'conf',conf)
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{false});

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),"omitnan"), '%2.f');
    S_name = standard_filename('casfco2',Lon,Lat,time_filename,ResName); % 标准文件名
    osprint2('INFO',['Transfor --> ',S_name])

    % 定义维度
    londimID = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
    latdimID = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
    timedimID = netcdf.defDim(ncid,'time',    netcdf.getConstant('NC_UNLIMITED'));  % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid,'DateStr',  size(char(TIME),2));                 % 定义TIME维度

    % 定义变量
    lon_id  =  netcdf.defVar(ncid,  'longitude', 'NC_FLOAT', londimID);                       % 经度
    lat_id  =  netcdf.defVar(ncid,  'latitude',  'NC_FLOAT', latdimID);                       % 纬度
    time_id =  netcdf.defVar(ncid, 'time',       'double', timedimID);                        % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',       'NC_CHAR',  [TIMEdimID,timedimID]);          % 时间char
    casfco2_id = netcdf.defVar(ncid, 'casfco2',   'NC_FLOAT', [londimID, latdimID, timedimID]); % casfco2

    netcdf.defVarFill(ncid,      casfco2_id,      false,      9.9692100e+36); % 设置缺省值

    netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
    netcdf.defVarDeflate(ncid, casfco2_id, true, true, 5)

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid,lon_id,                                                 Lon);          % 经度
    netcdf.putVar(ncid,lat_id,                                                 Lat);          % 纬度
    netcdf.putVar(ncid,time_id,  0,      length(time),                         time);         % 时间
    netcdf.putVar(ncid,TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)],char(TIME)'); % 时间char
    netcdf.putVar(ncid,casfco2_id,[0,0,0],[length(Lon),length(Lat),length(time)],Casfco2);    % CASFco2

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

    netcdf.putAtt(ncid,TIME_id,'reference',     TIME_reference);  % 时间char
    netcdf.putAtt(ncid,TIME_id,'long_name',    'UTC time');       % 时间char
    netcdf.putAtt(ncid,TIME_id,'start_date',    TIME_start_date); % 时间char
    netcdf.putAtt(ncid,TIME_id,'end_date',      TIME_end_date);   % 时间char

    netcdf.putAtt(ncid,casfco2_id, 'units',        'mmol C/m^2/d');                  % CASFco2
    netcdf.putAtt(ncid,casfco2_id, 'long_name',    'Carbonate air-sea flux of CO2'); % CASFco2
    netcdf.putAtt(ncid,casfco2_id, 'coordinates',  'longitude latitude time');       % CASFco2
    netcdf.putAtt(ncid,casfco2_id, 'clim',   [-300,300])

    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    if class(conf) == "struct" && isfield(conf,"P_Source")
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',         conf.P_Source); % 数据源
    end
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA_start_date);               % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    if class(conf) == "struct" && isfield(conf,"P_Version")
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',num2str(conf.P_Version)]);    % 程序版本号
    end
    if class(conf) == "struct" && isfield(conf,"Switch_ecology")
        if Switch_ecology
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'ecology_model',[conf.Ecology_model]);  % 生态模式
        end
    end
    netcdf.close(ncid);    % 关闭nc文件
    return 
end
