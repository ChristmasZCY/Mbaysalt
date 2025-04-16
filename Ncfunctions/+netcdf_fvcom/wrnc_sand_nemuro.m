function wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement,varargin)
    %       This function is used to write the sand data to the netcdf file
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id                   || required: True  || type: int       || format: 1
    %       Lon:             longitude                        || required: True  || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                         || required: True  || type: double    || format: [30.5, 31.5]
    %       Delement:        depth struct                     || required: True  || type: struct    || format: struct
    %           .Depth_std:  depth of standard level          || required: False || type: double    || format: vector
    %           .Bathy:      bathy of ocean                   || required: False || type: double    || format: vector
    %           .Siglay:     levels of siglay                 || required: False || type: double    || format: matrix
    %           .Depth_avg:  depth of average level           || required: False || type: double    || example: [0,100;20,300]
    %       time:            time                             || required: True  || type: double    || format: posixtime
    %       Velement:        value struct                     || required: True  || type: struct    || format: struct
    %           .Sand_std:   sand at standard levels          || required: False || type: double    || format: matrix
    %           .Sand_sgm:   sand at sigma levels             || required: False || type: double    || format: matrix
    %           .Sand_avg:   sand at average levels           || required: False || type: double    || format: matrix
    %       varargin:        optional parameters     
    %           conf:        configuration struct             || required: False || type: namevalue || format: struct
    %           INFO:        Whether print msg                || required: False || type: flag      || format: 'INFO' 
    %           Text_len:    Length of msg str                || required: False || type: namevalue || format: 'Text_len',45 
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2024-04-07:     New version, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45 )
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{false});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});

    SWITCH.std = false;
    SWITCH.sgm = false;
    SWITCH.avg = false;

    if isfield(Delement,'Depth_std')
        SWITCH.std = true;  % Depth_std
        Depth_std = Delement.Depth_std;
        Sand_std = Velement.Sand_std;
    end
    if isfield(Delement,'Bathy') && isfield(Delement,'Siglay')
        SWITCH.sgm = true;  % Bathy Siglay
        Bathy = Delement.Bathy; Siglay = Delement.Siglay;
        Sand_sgm = Velement.Sand_sgm;
    end
    if isfield(Delement,'Depth_avg')
        SWITCH.avg = true;  % Depth_avg
        Depth_avg = Delement.Depth_avg;
        Sand_avg = Velement.Sand_avg;
    end

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),"omitnan"), '%2.f');
    S_name = standard_filename('sand',Lon,Lat,time_filename,ResName); % 标准文件名
    if ~isempty(INFO)
        if ~Text_len
            osprint2('INFO', ['Transfor --> ', S_name]);
        else
            osprint2('INFO', [pad('Transfor ', Text_len, 'right'),'--> ', S_name]);
        end
    end

    % 定义维度
    londimID  = netcdf.defDim(ncid, 'longitude', length(Lon));                         % 定义lon维度
    latdimID  = netcdf.defDim(ncid, 'latitude',  length(Lat));                         % 定义lat纬度
    timedimID = netcdf.defDim(ncid, 'time',      netcdf.getConstant('NC_UNLIMITED'));  % 定义时间维度为unlimited
    TIMEdimID = netcdf.defDim(ncid, 'DateStr',   size(char(TIME),2));                  % 定义TIME维度
    if SWITCH.std
        depStddimID = netcdf.defDim(ncid, 'depth_std', length(Depth_std));  % 定义depth维度
    end
    if SWITCH.sgm
        sigdimID = netcdf.defDim(ncid, 'sigma', size(Siglay, 3));  % 定义sigma维度
    end
    if SWITCH.avg
        depAvgdimID = netcdf.defDim(ncid, 'depth_avg',    size(Depth_avg,1));  % 定义depth维度
        twodimID    = netcdf.defDim(ncid, 'two',          2);                  % 定义depth维度
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
        dep_std_id = netcdf.defVar(ncid, 'depth_std', 'NC_FLOAT', [depStddimID]);  % 深度
        sand_std_id  = netcdf.defVar(ncid, 'sand_std',    'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % Sand
        netcdf.defVarFill(ncid, sand_std_id, false, 9.9692100e+36);  % 设置缺省值
        netcdf.defVarDeflate(ncid, dep_std_id, true, true, 5)
        netcdf.defVarDeflate(ncid, sand_std_id,  true, true, 5)
    end

    if SWITCH.sgm
        bathy_id  = netcdf.defVar(ncid, 'bathy',      'NC_FLOAT', [londimID, latdimID]);  % 深度
        siglay_id = netcdf.defVar(ncid, 'siglay',     'NC_FLOAT', [londimID, latdimID, sigdimID]);  % 深度
        sand_sgm_id = netcdf.defVar(ncid, 'sand_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]);  % 深度

        netcdf.defVarFill(ncid, bathy_id,  false, 9.9692100e+36);  % 设置缺省值
        netcdf.defVarFill(ncid, siglay_id, false, 9.9692100e+36);  % 设置缺省值
        netcdf.defVarFill(ncid, sand_sgm_id, false, 9.9692100e+36);  % 设置缺省值

        netcdf.defVarDeflate(ncid, bathy_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, siglay_id, true, true, 5)
        netcdf.defVarDeflate(ncid, sand_sgm_id, true, true, 5)
    end

    if SWITCH.avg
        dep_avg_id = netcdf.defVar(ncid, 'depth_avg', 'NC_FLOAT', [depAvgdimID, twodimID]);  % 深度
        sand_avg_id  = netcdf.defVar(ncid, 'sand_avg',    'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % Sand
        netcdf.defVarFill(ncid, sand_avg_id, false,  9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, dep_avg_id, true, true, 5)
        netcdf.defVarDeflate(ncid, sand_avg_id,  true, true, 5)
    end

    % -----
    netcdf.endDef(ncid);  % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id,                                                   Lon);         % 经度
    netcdf.putVar(ncid, lat_id,                                                   Lat);         % 纬度
    netcdf.putVar(ncid, time_id, 0,      length(time),                            time);        % 时间
    netcdf.putVar(ncid, TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)], char(TIME)'); % 时间char

    if SWITCH.std
        netcdf.putVar(ncid, dep_std_id, Depth_std);  % 深度
        netcdf.putVar(ncid, sand_std_id, [0,0,0,0], [size(Sand_std,1), size(Sand_std,2), size(Sand_std,3), size(Sand_std,4)], Sand_std);  % Sand_std
    end

    if SWITCH.sgm
        netcdf.putVar(ncid, bathy_id,  Bathy);  % bathy
        netcdf.putVar(ncid, siglay_id, Siglay); % Siglay
        netcdf.putVar(ncid, sand_sgm_id, [0,0,0,0], [size(Sand_sgm,1), size(Sand_sgm,2), size(Sand_sgm,3), size(Sand_sgm,4)], Sand_sgm);  % Sand_sgm
    end

    if SWITCH.avg
        netcdf.putVar(ncid, dep_avg_id, Depth_avg);  % 深度
        netcdf.putVar(ncid, sand_avg_id, [0,0,0,0], [size(Sand_avg,1), size(Sand_avg,2), size(Sand_avg,3), size(Sand_avg,4)], Sand_avg); % Sand_avg
    end

    % -----
    netcdf.reDef(ncid);    % 使打开的nc文件重新进入定义模式
    % 添加变量属性
    netcdf.putAtt(ncid, lon_id, 'units',      'degrees_east');                      % 经度
    netcdf.putAtt(ncid, lon_id, 'long_name',  'longitude');                         % 经度
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

    if SWITCH.std
        netcdf.putAtt(ncid, dep_std_id, 'units',     'm');     % Sand
        netcdf.putAtt(ncid, dep_std_id, 'long_name', 'depth'); % Sand
        netcdf.putAtt(ncid, dep_std_id, 'positive',  'down');  % Sand

        netcdf.putAtt(ncid, sand_std_id, 'units',       'g/L');  % Sand
        netcdf.putAtt(ncid, sand_std_id, 'long_name',   'sand at standard levels');  % Sand
        netcdf.putAtt(ncid, sand_std_id, 'coordinates', 'standard levels');  % Sand
    end

    if SWITCH.sgm
        netcdf.putAtt(ncid, bathy_id, 'units',     'm');              % bathy
        netcdf.putAtt(ncid, bathy_id, 'long_name', 'bathy of ocean'); % bathy

        netcdf.putAtt(ncid, siglay_id, 'units',        '1');                      % Siglay
        netcdf.putAtt(ncid, siglay_id, 'long_name',    'sigma layers');           % Siglay
        netcdf.putAtt(ncid, siglay_id, 'positive',     'down');                   % Siglay
        netcdf.putAtt(ncid, siglay_id, 'standard_name','ocean sigma coordinate'); % Siglay

        netcdf.putAtt(ncid, sand_sgm_id, 'units',       'g/L');  % Sand_sgm
        netcdf.putAtt(ncid, sand_sgm_id, 'long_name',   'sand at sigma levels');  % Sand_sgm
        netcdf.putAtt(ncid, sand_sgm_id, 'coordinates', 'sigma levels');  % Sand_sgm
    end

    if SWITCH.avg
        netcdf.putAtt(ncid, dep_avg_id, 'units',     'm');  % Sand
        netcdf.putAtt(ncid, dep_avg_id, 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1,1),Depth_avg(1,2)));  % Depth_avg
        netcdf.putAtt(ncid, dep_avg_id, 'positive',  'down');  % Sand
  
        netcdf.putAtt(ncid, sand_avg_id, 'units',       'g/L');  % Sand
        netcdf.putAtt(ncid, sand_avg_id, 'long_name',   'sand at average levels');  % Sand
        netcdf.putAtt(ncid, sand_avg_id, 'coordinates', 'average levels');          % Sand
    end

    % 写入global attribute
    varid_GA = netcdf.getConstant('NC_GLOBAL');
    if ~isempty(conf)
        NC = read_NC(conf);
        fields = fieldnames(NC);
        for iname = 1 : length(fields)
            %  netcdf.putAtt(ncid, varid_GA, 'source', conf.P_Source); % 数据源
            netcdf.putAtt(ncid, varid_GA, fields{iname}, NC.(fields{iname}));
        end
    end
    netcdf.putAtt(ncid, varid_GA, 'product_name', S_name);  % 文件名
    netcdf.putAtt(ncid, varid_GA, 'history', ['Created by Matlab at ' char(datetime("now","Inputformat","yyyy-MM-dd HH:mm:SS"))]);  % 操作历史记录
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
            NC.(key{i}(4:end)) = structIn.(key{i});
        end
    end
end
