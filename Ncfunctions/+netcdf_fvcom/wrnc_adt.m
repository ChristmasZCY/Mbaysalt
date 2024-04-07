function wrnc_adt(ncid,Lon,Lat,time,Zeta,varargin)
    %       This function is used to write the adt data to the netcdf file
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id          || required: True  || type: int       || format: 1
    %       Lon:             longitude               || required: True  || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True  || type: double    || format: [30.5, 31.5]
    %       time:            time                    || required: True  || type: double    || format: posixtime
    %       Zeta:            adt                     || required: True. || type: double    || format: matrix
    %       varargin:        optional parameters     
    %           conf:        configuration struct    || required: False || type: namevalue || format: struct
    %           INFO:        Whether print msg       || required: False || type: flag      || format: 'INFO' 
    %           Text_len:    Length of msg str       || required: False || type: namevalue || format: 'Text_len',45 
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2023-12-29:     Fixed comments, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta)
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf)
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,'conf',conf,'INFO','Text_len',45 )
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{false});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('adt',Lon,Lat,time_filename,ResName); % 标准文件名
    if ~isempty(INFO)
        if ~Text_len
            osprint2('INFO', ['Transfor --> ', S_name]);
        else
            osprint2('INFO', [pad('Transfor ', Text_len, 'right'),'--> ', S_name]);
        end
    end

    % 定义维度
    londimID  = netcdf.defDim(ncid, 'longitude', length(Lon));                        % 定义lon维度
    latdimID  = netcdf.defDim(ncid, 'latitude',  length(Lat));                        % 定义lat纬度
    timedimID = netcdf.defDim(ncid, 'time',      netcdf.getConstant('NC_UNLIMITED')); % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid, 'DateStr',   size(char(TIME),2));                 % 定义TIME维度

    % 定义变量
    lon_id  =  netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);                       % 经度
    lat_id  =  netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);                       % 纬度
    time_id =  netcdf.defVar(ncid, 'time',      'double',   timedimID);                      % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID,timedimID]);          % 时间char
    adt_id  =  netcdf.defVar(ncid, 'adt',       'NC_FLOAT', [londimID, latdimID,timedimID]); % 海平面高度

    netcdf.defVarFill(ncid, adt_id, false, 9.9692100e+36); % 设置缺省值

    netcdf.defVarDeflate(ncid, lon_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)
    netcdf.defVarDeflate(ncid, adt_id,  true, true, 5)

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id,                                                      Lon);         % 经度
    netcdf.putVar(ncid, lat_id,                                                      Lat);         % 纬度
    netcdf.putVar(ncid, time_id, 0,      length(time),                               time);        % 时间
    netcdf.putVar(ncid, TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)],    char(TIME)'); % 时间char
    netcdf.putVar(ncid, adt_id,  [0,0,0],[size(Zeta,1), size(Zeta,2), size(Zeta,3)], Zeta);        % 海平面高度

    % -----
    netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
    % 添加变量属性
    netcdf.putAtt(ncid, lon_id, 'units',       'degrees_east');                     % 经度
    netcdf.putAtt(ncid, lon_id, 'long_name',   'longitude');                        % 经度
    netcdf.putAtt(ncid, lon_id, 'westernmost', num2str(min(Lon,[],"all"),'%3.2f')); % 经度
    netcdf.putAtt(ncid, lon_id, 'easternmost', num2str(max(Lon,[],"all"),'%3.2f')); % 经度

    netcdf.putAtt(ncid, lat_id, 'units',        'degrees_north');                    % 纬度
    netcdf.putAtt(ncid, lat_id, 'long_name',    'latitude');                         % 纬度
    netcdf.putAtt(ncid, lat_id, 'southernmost', num2str(min(Lat,[],"all"),'%2.2f')); % 纬度
    netcdf.putAtt(ncid, lat_id, 'northernmost', num2str(max(Lat,[],"all"),'%2.2f')); % 纬度

    netcdf.putAtt(ncid, time_id, 'units',     'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid, time_id, 'long_name', 'UTC time');                          % 时间
    netcdf.putAtt(ncid, time_id, 'calendar',  'gregorian');                         % 时间

    netcdf.putAtt(ncid, TIME_id, 'reference',  TIME_reference);  % 时间char
    netcdf.putAtt(ncid, TIME_id, 'long_name',  'UTC time');      % 时间char
    netcdf.putAtt(ncid, TIME_id, 'start_date', TIME_start_date); % 时间char
    netcdf.putAtt(ncid, TIME_id, 'end_date',   TIME_end_date);   % 时间char

    netcdf.putAtt(ncid, adt_id, 'units',     'm');                              % 海平面高度
    netcdf.putAtt(ncid, adt_id, 'long_name', 'absolute dynamic topography');    % 海平面高度

    % 写入global attribute
    varid_GA = netcdf.getConstant('NC_GLOBAL');
    if ~isempty(conf)
        NC = read_NC(conf);
        fields = fieldnames(NC);
        for iname = 1 : length(fields)
            %  netcdf.putAtt(ncid, varid_GA, 'source', conf.P_Source); % 数据源
            netcdf.putAtt(ncid, varid_GA, fields(iname), NC.(fields(iname)));
        end
    end
    netcdf.putAtt(ncid, varid_GA, 'product_name', S_name);  % 文件名
    netcdf.putAtt(ncid, varid_GA, 'history',      ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]); % 操作历史记录
    netcdf.close(ncid);  % 关闭nc文件
    return 
end


function NC = read_NC(structIn)
    % 从structIn中读取以NC_开头的变量，将变量写入到SWITCH结构体中
    % eg: 将structIn中的NC_source写入到SWITCH.source中
    NC = struct();
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^NC_','once'))
            NC.(key{i}(8:end)) = structIn.(key{i});
        end
    end
end
