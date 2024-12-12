function wrnc_wave(ncid,Lon,Lat,time,Velement,varargin)
    %       This function is used to write the WW3 wave data to the netcdf file
    % =================================================================================================================
    % parameter:
    %       ncid:            netcdf file id          || required: True  || type: int       || format: 1
    %       Lon:             longitude               || required: True  || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True  || type: double    || format: [30.5, 31.5]
    %       time:            time                    || required: True  || type: double    || format: posixtime
    %       Velement:        wave struct             || required: True  || type: struct    || format: struct
    %       varargin:        optional parameters     
    %           conf:        configuration struct    || required: False || type: namevalue || format: struct
    %           INFO:        Whether print msg       || required: False || type: flag      || format: 'INFO' 
    %           Text_len:    Length of msg str       || required: False || type: namevalue || format: 'Text_len',45 
    % =================================================================================================================
    % Example:
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct)
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf)
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf,'INFO')
    %       netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',conf,'INFO','Text_len',45)
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{struct('')});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});

    if isfield(Velement, 'Swh')
        SWITCH.swh = true;
    else
        SWITCH.swh = false;
    end
    if isfield(Velement, 'Mwd')
        SWITCH.mwd = true;
    else
        SWITCH.mwd = false;
    end
    if isfield(Velement, 'Mwp')
        SWITCH.mwp = true;
    else
        SWITCH.mwp = false;
    end
    if isfield(Velement, 'Shww')
        SWITCH.shww = true;
    else
        SWITCH.shww = false;
    end
    if isfield(Velement, 'Mdww')
        SWITCH.mdww = true;
    else
        SWITCH.mdww = false;
    end
    if isfield(Velement, 'Mpww')
        SWITCH.mpww = true;
    else
        SWITCH.mpww = false;
    end
    if isfield(Velement, 'Shts')
        SWITCH.shts = true;
    else
        SWITCH.shts = false;
    end
    if isfield(Velement, 'Mdts')
        SWITCH.mdts = true;
    else
        SWITCH.mdts = false;
    end
    if isfield(Velement, 'Mpts')
        SWITCH.mpts = true;
    else
        SWITCH.mpts = false;
    end

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),'omitnan'), '%2.f');
    S_name = standard_filename('wave',Lon,Lat,time_filename,ResName); % 标准文件名
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
    lon_id  = netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);                    % 经度
    lat_id  = netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);                    % 纬度
    time_id = netcdf.defVar(ncid, 'time',      'double',   timedimID);                   % 时间
    TIME_id = netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID, timedimID]);      % 时间char
    netcdf.defVarDeflate(ncid, lon_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

    if SWITCH.swh
        swh_id = netcdf.defVar(ncid, 'swh', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪有效波高
        netcdf.defVarFill(ncid, swh_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, swh_id, true, true, 5)
    end
    if SWITCH.mwd
        mwd_id = netcdf.defVar(ncid, 'mwd', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪波向
        netcdf.defVarFill(ncid, mwd_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mwd_id, true, true, 5)
    end
    if SWITCH.mwp
        mwp_id = netcdf.defVar(ncid, 'mwp', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 海浪周期
        netcdf.defVarFill(ncid, mwp_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mwp_id, true, true, 5)
    end
    if SWITCH.shww
        shww_id = netcdf.defVar(ncid, 'shww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪波高
        netcdf.defVarFill(ncid, shww_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, shww_id, true, true, 5)
    end
    if SWITCH.mdww
        mdww_id = netcdf.defVar(ncid, 'mdww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪波向
        netcdf.defVarFill(ncid, mdww_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mdww_id, true, true, 5)
    end
    if SWITCH.mpww
        mpww_id = netcdf.defVar(ncid, 'mpww', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 风浪周期
        netcdf.defVarFill(ncid, mpww_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mpww_id, true, true, 5)
    end
    if SWITCH.shts
        shts_id = netcdf.defVar(ncid, 'shts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪波高
        netcdf.defVarFill(ncid, shts_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, shts_id, true, true, 5)
    end
    if SWITCH.mdts
        mdts_id = netcdf.defVar(ncid, 'mdts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪波向
        netcdf.defVarFill(ncid, mdts_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mdts_id, true, true, 5)
    end
    if SWITCH.mpts
        mpts_id = netcdf.defVar(ncid, 'mpts', 'NC_FLOAT', [londimID, latdimID,timedimID]); % 涌浪周期
        netcdf.defVarFill(ncid, mpts_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, mpts_id, true, true, 5)
    end

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id,                                                        Lon);         % 经度
    netcdf.putVar(ncid, lat_id,                                                        Lat);         % 纬度
    netcdf.putVar(ncid, time_id, 0,       length(time),                                time);        % 时间
    netcdf.putVar(ncid, TIME_id, [0,0],   [size(char(TIME),2),size(char(TIME),1)],     char(TIME)'); % 时间char
    if SWITCH.swh
        netcdf.putVar(ncid, swh_id,  [0,0,0], [size(Velement.Swh,1), size(Velement.Swh,2), size(Velement.Swh,3)],  Velement.Swh); % 海浪有效波高
    end
    if SWITCH.mwd
        netcdf.putVar(ncid, mwd_id,  [0,0,0], [size(Velement.Mwd,1), size(Velement.Mwd,2), size(Velement.Mwd,3)],  Velement.Mwd); % 海浪波向
    end
    if SWITCH.mwp
        netcdf.putVar(ncid, mwp_id,  [0,0,0], [size(Velement.Mwp,1), size(Velement.Mwp,2), size(Velement.Mwp,3)],  Velement.Mwp); % 海浪周期
    end
    if SWITCH.shww
        netcdf.putVar(ncid, shww_id,  [0,0,0], [size(Velement.Shww,1), size(Velement.Shww,2), size(Velement.Shww,3)],  Velement.Shww); % 风浪波高
    end
    if SWITCH.mdww
        netcdf.putVar(ncid, mdww_id,  [0,0,0], [size(Velement.Mdww,1), size(Velement.Mdww,2), size(Velement.Mdww,3)],  Velement.Mdww); % 风浪波向
    end
    if SWITCH.mpww
        netcdf.putVar(ncid, mpww_id,  [0,0,0], [size(Velement.Mpww,1), size(Velement.Mpww,2), size(Velement.Mpww,3)],  Velement.Mpww); % 风浪周期
    end
    if SWITCH.shts
        netcdf.putVar(ncid, shts_id,  [0,0,0], [size(Velement.Shts,1), size(Velement.Shts,2), size(Velement.Shts,3)],  Velement.Shts); % 涌浪波高
    end
    if SWITCH.mdts
        netcdf.putVar(ncid, mdts_id,  [0,0,0], [size(Velement.Mdts,1), size(Velement.Mdts,2), size(Velement.Mdts,3)],  Velement.Mdts); % 涌浪波向
    end
    if SWITCH.mpts
        netcdf.putVar(ncid, mpts_id,  [0,0,0], [size(Velement.Mpts,1), size(Velement.Mpts,2), size(Velement.Mpts,3)],  Velement.Mpts); % 涌浪周期
    end

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

    netcdf.putAtt(ncid, time_id,'units',     'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid, time_id,'long_name', 'UTC time');                          % 时间
    netcdf.putAtt(ncid, time_id,'calendar',  'gregorian');                         % 时间

    netcdf.putAtt(ncid, TIME_id, 'reference',  TIME_reference);  % 时间char
    netcdf.putAtt(ncid, TIME_id, 'long_name',  'UTC time');      % 时间char
    netcdf.putAtt(ncid, TIME_id, 'start_date', TIME_start_date); % 时间char
    netcdf.putAtt(ncid, TIME_id, 'end_date',   TIME_end_date);   % 时间char

    if SWITCH.swh
        netcdf.putAtt(ncid, swh_id, 'units',     'm');  % 海浪有效波高
        netcdf.putAtt(ncid, swh_id, 'long_name', 'significant height of combined wind waves and swell'); % 海浪有效波高
    end
    if SWITCH.mwd
        netcdf.putAtt(ncid, mwd_id, 'units',        'degree');                 % 海浪波向
        netcdf.putAtt(ncid, mwd_id, 'long_name',    'mean wave direction');    % 海浪波向
        netcdf.putAtt(ncid, mwd_id, 'direction_0',  'coming from the north');  % 海浪波向
        netcdf.putAtt(ncid, mwd_id, 'direction_90', 'coming from the east');   % 海浪波向
    end
    if SWITCH.mwp
        netcdf.putAtt(ncid, mwp_id, 'units',     's');                % 海浪周期
        netcdf.putAtt(ncid, mwp_id, 'long_name', 'mean wave period'); % 海浪周期
    end
    if SWITCH.shww
        netcdf.putAtt(ncid, shww_id, 'units',     'm');                                % 风浪波高
        netcdf.putAtt(ncid, shww_id, 'long_name', 'significant height of wind waves'); % 风浪波高
    end
    if SWITCH.mdww
        netcdf.putAtt(ncid, mdww_id, 'units',        'degree');                        % 风浪波向
        netcdf.putAtt(ncid, mdww_id, 'long_name',    'mean direction of wind waves');  % 风浪波向
        netcdf.putAtt(ncid, mdww_id, 'direction_0',  'coming from the north');         % 风浪波向
        netcdf.putAtt(ncid, mdww_id, 'direction_90', 'coming from the east');          % 风浪波向
    end
    if SWITCH.mpww
        netcdf.putAtt(ncid, mpww_id, 'units',     's');                          % 风浪周期
        netcdf.putAtt(ncid, mpww_id, 'long_name', 'mean period of wind waves');  % 风浪周期
    end
    if SWITCH.shts
        netcdf.putAtt(ncid, shts_id, 'units',     'm');                                  % 涌浪波高
        netcdf.putAtt(ncid, shts_id, 'long_name', 'significant height of total swell');  % 涌浪波高
    end
    if SWITCH.mdts
        netcdf.putAtt(ncid, mdts_id, 'units',        'degree');                         % 涌浪波向
        netcdf.putAtt(ncid, mdts_id, 'long_name',    'mean direction of total swell');  % 涌浪波向
        netcdf.putAtt(ncid, mdts_id, 'direction_0',  'coming from the north');          % 涌浪波向
        netcdf.putAtt(ncid, mdts_id, 'direction_90', 'coming from the east');           % 涌浪波向
    end
    if SWITCH.mpts
        netcdf.putAtt(ncid, mpts_id, 'units',     's');                           % 涌浪周期
        netcdf.putAtt(ncid, mpts_id, 'long_name', 'mean period of total swell');  % 涌浪周期
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
