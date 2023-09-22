function wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,GA_start_date,varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to write the salinity data to the netcdf file
    % =================================================================================================================
    % parameter:
    %       ncid:            netcdf file id                   || required: True  || type: int    || format: 1
    %       Lon:             longitude                        || required: True  || type: double || format: [120.5, 121.5]
    %       Lat:             latitude                         || required: True  || type: double || format: [30.5, 31.5]
    %       Delement:        depth struct                     || required: True  || type: struct || format: struct
    %           .Depth_std:  depth of standard level          || required: False || type: double || format: vector
    %           .Bathy:      bathy of ocean                   || required: False || type: double || format: vector
    %           .Sigma:      levels of sigma                  || required: False || type: double || format: vector
    %           .Siglay:     levels of siglay                 || required: False || type: double || format: matrix
    %       time:            time                             || required: True  || type: double || format: posixtime
    %       Velement:        value struct                     || required: True  || type: struct || format: struct
    %           .Salt:       sea salinity                     || required: True  || type: double || format: matrix
    %           .Salt_sgm:   sea salinity at sigma levels     || required: False || type: double || format: matrix
    %       GA_start_date:   time of forecast start           || required: True  || type: string || format: '2023-05-30_00:00:00'
    %       varargin:        optional parameters     
    %           conf:        configuration struct    || required: False || type: struct || format: struct
    % =================================================================================================================
    % example:
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,GA_start_date)
    %       netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement,GA_start_date,'conf',conf)
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{false});

    if length(fieldnames(Delement)) == 1  % Delement --> Depth_std
        SWITCH.std = true;
        SWITCH.sgm = false;
        Depth = Delement.Depth_std;
        Salt = Velement.Salt;
    elseif length(fieldnames(Delement)) == 3  % Delement --> Bathy Sigma Siglay
        SWITCH.std = false;
        SWITCH.sgm = true;
        Sigma = Delement.Sigma; Bathy = Delement.Bathy; Siglay = Delement.Siglay;
        Salt_sgm = Velement.Salt_sgm;
    elseif length(fieldnames(Delement)) == 4  % Delement --> Depth_std Bathy Sigma Siglay
        SWITCH.std = true;
        SWITCH.sgm = true;
        Depth = Delement.Depth_std;
        Sigma = Delement.Sigma; Bathy = Delement.Bathy; Siglay = Delement.Siglay;
        Salt = Velement.Salt; Salt_sgm = Velement.Salt_sgm;
    else
        error('The number of input parameters is wrong!')
    end

    % check sigma levels input value
    if SWITCH.sgm
        if ~isvector(Sigma)
            error('Sigma must be a vector 1D!')
        end
        if ndims(Bathy) ~= 2
            error('Bathy must be a matrix 2D!')
        end
        if ndims(Salt_sgm) > 4 || isvector(Salt_sgm)
            error('Salt_sgm must be a matrix 2D, 3D or 4D!')
        end
    end

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/nanmean(diff(Lon)), '%2.f');
    S_name = standard_filename('salinity',Lon,Lat,time_filename,ResName); % 标准文件名
    osprints('INFO',['Transfor --> ',S_name])

    % 定义维度
    londimID = netcdf.defDim(ncid, 'longitude',length(Lon));                        % 定义lon维度
    latdimID = netcdf.defDim(ncid, 'latitude', length(Lat));                        % 定义lat纬度
    timedimID = netcdf.defDim(ncid,'time',    netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid,'DateStr',  size(char(TIME),2));                 % 定义TIME维度
    if SWITCH.std
        depdimID = netcdf.defDim(ncid, 'depth',    length(Depth));                  % 定义depth维度
    end
    if SWITCH.sgm
        sigdimID = netcdf.defDim(ncid, 'sigma',    length(Sigma));                  % 定义sigma维度
    end

    % 定义变量
    lon_id  =  netcdf.defVar(ncid,  'longitude', 'NC_FLOAT', londimID);                       % 经度
    lat_id  =  netcdf.defVar(ncid,  'latitude',  'NC_FLOAT', latdimID);                       % 纬度
    time_id =  netcdf.defVar(ncid, 'time',      'double', timedimID);                      % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID,timedimID]);          % 时间char
    netcdf.defVarDeflate(ncid, lon_id, true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id, true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

    if SWITCH.std
        dep_id  =  netcdf.defVar(ncid,  'depth',     'NC_FLOAT', [depdimID]);  % 深度
        salt_id =  netcdf.defVar(ncid, 'salinity',    'NC_FLOAT', [londimID, latdimID,depdimID,timedimID]); % 盐度
        netcdf.defVarFill(ncid,      salt_id,      false,      9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, dep_id, true, true, 5)
        netcdf.defVarDeflate(ncid, salt_id, true, true, 5)
    end

    if SWITCH.sgm
        bathy_id = netcdf.defVar(ncid, 'bathy',     'NC_FLOAT', [londimID, latdimID]);  % 深度
        siglay_id = netcdf.defVar(ncid, 'siglay',    'NC_FLOAT', [londimID, latdimID,sigdimID]);  % 深度
        salt_sgm_id = netcdf.defVar(ncid, 'salinity_sgm',     'NC_FLOAT', [londimID, latdimID,sigdimID,timedimID]);  % 深度

        netcdf.defVarFill(ncid,      bathy_id,      false,      9.9692100e+36); % 设置缺省值
        netcdf.defVarFill(ncid,      siglay_id,     false,      9.9692100e+36); % 设置缺省值
        netcdf.defVarFill(ncid,      salt_sgm_id,   false,      9.9692100e+36); % 设置缺省值

        netcdf.defVarDeflate(ncid, bathy_id, true, true, 5)
        netcdf.defVarDeflate(ncid, siglay_id, true, true, 5)
        netcdf.defVarDeflate(ncid, salt_sgm_id, true, true, 5)
    end

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid,lon_id,                                                 Lon);         % 经度
    netcdf.putVar(ncid,lat_id,                                                 Lat);         % 纬度
    netcdf.putVar(ncid,time_id,  0,      length(time),                          time);       % 时间
    netcdf.putVar(ncid,TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)],char(TIME)');% 时间char

    if SWITCH.std
        netcdf.putVar(ncid,dep_id,                                                Depth);       % 深度
        netcdf.putVar(ncid,salt_id,  [0,0,0,0],[size(Salt,1), size(Salt,2), size(Salt,3),size(Salt,4)],  Salt);     % 盐度
    end

    if SWITCH.sgm
        netcdf.putVar(ncid,bathy_id,Bathy);        % bathy
        netcdf.putVar(ncid,siglay_id,Siglay);        % Siglay
        netcdf.putVar(ncid,salt_sgm_id,  [0,0,0,0],[size(Salt_sgm,1), size(Salt_sgm,2), size(Salt_sgm,3),size(Salt_sgm,4)],  Salt_sgm);        % Salt_sgm
    end

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

    if SWITCH.std
        netcdf.putAtt(ncid,dep_id, 'units',        'm');                                 % 深度
        netcdf.putAtt(ncid,dep_id, 'long_name',    'depth');                             % 深度
        netcdf.putAtt(ncid,dep_id, 'positive',     'down');                              % 深度

        netcdf.putAtt(ncid,salt_id, 'units',        'psu');                               % 盐度
        netcdf.putAtt(ncid,salt_id, 'long_name',    'sea water salinity');                % 盐度
        netcdf.putAtt(ncid,salt_id, 'coordinates',  'standard_levels');                   % 盐度
    end

    if SWITCH.sgm
        netcdf.putAtt(ncid,bathy_id, 'units',        'm');                                 % bathy
        netcdf.putAtt(ncid,bathy_id, 'long_name',    'bathy_of_ocean');                     % bathy

        netcdf.putAtt(ncid,siglay_id, 'units',        '1');                                 % Siglay
        netcdf.putAtt(ncid,siglay_id, 'long_name',    'sigma layers');                      % Siglay
        netcdf.putAtt(ncid,siglay_id, 'positive',     'down');                              % Siglay
        netcdf.putAtt(ncid,siglay_id, 'standard_name','ocean_sigma_coordinate');            % Siglay

        netcdf.putAtt(ncid,salt_sgm_id, 'units',        'psu');                                 % salt_sgm
        netcdf.putAtt(ncid,salt_sgm_id, 'long_name',    'sea water salinity at sigma levels');             % salt_sgm
        netcdf.putAtt(ncid,salt_sgm_id, 'coordinates',  'sigma_levels');                     % salt_sgm
    end

    % 写入global attribute
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_name',   S_name);         % 文件名
    if class(conf) == "struct"
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source',         conf.P_Source); % 数据源
    end
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'start',          GA_start_date);               % 起报时间
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',        ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    if class(conf) == "struct"
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program_version',['V',num2str(conf.P_Version)]);    % 程序版本号
    end
    netcdf.close(ncid);    % 关闭nc文件
    return 
end