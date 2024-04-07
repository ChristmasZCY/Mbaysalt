function wrnc_current(ncid,Lon,Lat,Delement,time,Velement,varargin)
    %       This function is used to write the current data u/v/w(optional) to the netcdf file at std or sigma levels.
    % =================================================================================================================
    % Parameter:
    %       ncid:            netcdf file id          || required: True  || type: int       || format: 1
    %       Lon:             longitude               || required: True  || type: double    || format: [120.5, 121.5]
    %       Lat:             latitude                || required: True  || type: double    || format: [30.5, 31.5]
    %       Delement:        depth struct            || required: True  || type: struct    || format: struct
    %           .Depth_std:  depth of standard level || required: False || type: double    || format: vector
    %           .Bathy:      bathy of ocean          || required: False || type: double    || format: vector
    %           .Siglay:     levels of siglay        || required: False || type: double    || format: matrix
    %           .Depth_avg:  depth of average level  || required: False || type: double    || example: [0,100;20,300]
    %       time:            time                    || required: True  || type: double    || format: posixtime
    %       Velement:        value struct            || required: True  || type: struct    || format: struct
    %           .U_std:      u at standard levels    || required: False || type: double    || format: matrix
    %           .V_std:      v at standard levels    || required: True  || type: double    || format: matrix
    %           .W_std:      w at standard levels    || required: False || type: double    || format: matrix
    %           .U_sgm:      u at sigma levels       || required: False || type: double    || format: matrix
    %           .V_sgm:      v at sigma levels       || required: False || type: double    || format: matrix
    %           .W_sgm:      w at sigma levels       || required: False || type: double    || format: matrix
    %           .U_avg:      u at average levels     || required: False || type: double    || format: matrix
    %           .V_avg:      v at average levels     || required: False || type: double    || format: matrix
    %           .W_avg:      w at average levels     || required: False || type: double    || format: matrix
    %           .Ua   :      u at all average levels || required: False || type: double    || format: matrix
    %           .Va   :      v at all average levels || required: False || type: double    || format: matrix
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
    %       2023-12-29:     Added, for average levels, by Christmas;
    %       2024-04-07:     Added ua va, change judge input levels, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement)
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf)
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO')
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement,'conf',conf,'INFO','Text_len',45)
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{false});
    varargin = read_varargin2(varargin,{'INFO'});
    varargin = read_varargin(varargin,{'Text_len'},{false});

    SWITCH.std = false;
    SWITCH.sgm = false;
    SWITCH.avg = false;
    SWITCH.u = false;
    SWITCH.v = false;
    SWITCH.w = false;
    SWITCH.ua = false;
    SWITCH.va = false;
    if isfield(Delement,'Depth_std')
        SWITCH.std = true;  % Depth_std
        Depth_std = Delement.Depth_std;
    end
    if isfield(Delement,'Bathy') && isfield(Delement,'Siglay')
        SWITCH.sgm = true;  % Bathy Siglay
        Bathy = Delement.Bathy; Siglay = Delement.Siglay;
    end
    if isfield(Delement,'Depth_avg')
        SWITCH.avg = true;  % Depth_avg
        Depth_avg = Delement.Depth_avg;
    end

    fields = fieldnames(Velement);
    if ismember(fields,{'U_sgm','U_std','U_avg'})
        SWITCH.V = true;
    end
    if ismember(fields,{'V_sgm','V_std','V_avg'})
        SWITCH.V = true;
    end
    if ismember(fields,{'W_sgm','W_std','W_avg'})
        SWITCH.V = true;
    end
    clear fields
    
    if isfield(Velement,'Ua')
        SWITCH.ua = true;
    end
    if isfield(Velement,'Va')
        SWITCH.va = true;
    end

    % time && TIME
    [TIME,TIME_reference,TIME_start_date,TIME_end_date,time_filename] = time_to_TIME(time);

    % standard_name
    ResName = num2str(1/mean(diff(Lon),"omitnan"), '%2.f');
    S_name = standard_filename('current',Lon,Lat,time_filename,ResName); % 标准文件名
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
    if SWITCH.std
        depStddimID = netcdf.defDim(ncid, 'depth_std', length(Depth_std));  % 定义depth维度
    end
    if SWITCH.sgm
        sigdimID = netcdf.defDim(ncid, 'sigma', size(Siglay, 3));  % 定义sigma维度
    end
    if SWITCH.avg
        depAvgdimID = netcdf.defDim(ncid, 'depth_avg', size(Depth_avg,1));  % 定义depth维度
        twodimID = netcdf.defDim(ncid, 'two', 2);  % 定义depth维度
    end

    % 定义变量
    lon_id  =  netcdf.defVar(ncid, 'longitude', 'NC_FLOAT', londimID);               % 经度
    lat_id  =  netcdf.defVar(ncid, 'latitude',  'NC_FLOAT', latdimID);               % 纬度
    time_id =  netcdf.defVar(ncid, 'time',      'double',    timedimID);             % 时间
    TIME_id =  netcdf.defVar(ncid, 'TIME',      'NC_CHAR',  [TIMEdimID,timedimID]);  % 时间char
    netcdf.defVarDeflate(ncid, lon_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, lat_id,  true, true, 5)
    netcdf.defVarDeflate(ncid, time_id, true, true, 5)
    netcdf.defVarDeflate(ncid, TIME_id, true, true, 5)

    if SWITCH.std
        dep_std_id = netcdf.defVar(ncid, 'depth_std', 'NC_FLOAT', [depStddimID]);  % 深度
        netcdf.defVarDeflate(ncid, dep_std_id, true, true, 5)                
        if SWITCH.u
            u_std_id = netcdf.defVar(ncid, 'u_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % u_std
            netcdf.defVarFill(ncid, u_std_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, u_std_id, true, true, 5)
            U_std = Velement.U_std;
        end
        if SWITCH.v
            v_std_id = netcdf.defVar(ncid, 'v_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % v_std
            netcdf.defVarFill(ncid, v_std_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, v_std_id, true, true, 5)
            V_std = Velement.V_std;
        end
        if SWITCH.w
            w_std_id = netcdf.defVar(ncid, 'w_std', 'NC_FLOAT', [londimID, latdimID, depStddimID, timedimID]); % w_std
            netcdf.defVarFill(ncid, w_std_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, w_std_id, true, true, 5)
            W_std = Velement.W_std;
        end
    end

    if SWITCH.sgm
        bathy_id  = netcdf.defVar(ncid,  'bathy',    'NC_FLOAT', [londimID, latdimID]);             % 深度
        siglay_id = netcdf.defVar(ncid, 'siglay',    'NC_FLOAT', [londimID, latdimID, sigdimID]);   % 深度   
        netcdf.defVarFill(ncid, bathy_id,  false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarFill(ncid, siglay_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, bathy_id,  true, true, 5)
        netcdf.defVarDeflate(ncid, siglay_id, true, true, 5)
        if SWITCH.u
            u_sgm_id = netcdf.defVar(ncid, 'u_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]);  % 深度
            netcdf.defVarFill(ncid, u_sgm_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, u_sgm_id, true, true, 5)
            U_sgm = Velement.U_sgm;
        end
        if SWITCH.v
            v_sgm_id = netcdf.defVar(ncid, 'v_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]);  % 深度
            netcdf.defVarFill(ncid, v_sgm_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, v_sgm_id, true, true, 5)
            V_sgm = Velement.V_sgm;
        end
        if SWITCH.w
            w_sgm_id = netcdf.defVar(ncid, 'w_sgm', 'NC_FLOAT', [londimID, latdimID, sigdimID, timedimID]);  % 深度
            netcdf.defVarFill(ncid, w_sgm_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, w_sgm_id, true, true, 5)
            W_sgm = Velement.W_sgm;
        end
    end

    if SWITCH.avg
        dep_avg_id = netcdf.defVar(ncid, 'depth_avg', 'NC_FLOAT', [depAvgdimID, twodimID]);  % 深度  
        netcdf.defVarDeflate(ncid, dep_avg_id, true, true, 5)
        if SWITCH.u
            u_avg_id = netcdf.defVar(ncid, 'u_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % u_avg
            netcdf.defVarFill(ncid, u_avg_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, u_avg_id, true, true, 5)
            U_avg = Velement.U_avg;
        end
        if SWITCH.v
            v_avg_id = netcdf.defVar(ncid, 'v_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % v_avg
            netcdf.defVarFill(ncid, v_avg_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, v_avg_id, true, true, 5)
            V_avg = Velement.V_avg;
        end
        if SWITCH.w
            w_avg_id = netcdf.defVar(ncid, 'w_avg', 'NC_FLOAT', [londimID, latdimID, depAvgdimID, timedimID]); % w_avg
            netcdf.defVarFill(ncid, w_avg_id, false, 9.9692100e+36); % 设置缺省值
            netcdf.defVarDeflate(ncid, w_avg_id, true, true, 5)
            W_avg = Velement.W_avg;
        end
    end

    if SWITCH.ua
        ua_id = netcdf.defVar(ncid, 'ua', 'NC_FLOAT', [londimID, latdimID, timedimID]); % ua
        netcdf.defVarFill(ncid, ua_id, false, 9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, ua_id, true, true, 5)
        Ua = Velement.Ua;
    end
    if SWITCH.va
        va_id = netcdf.defVar(ncid, 'va', 'NC_FLOAT', [londimID, latdimID, timedimID]); % va
        netcdf.defVarFill(ncid, va_id, false,  9.9692100e+36); % 设置缺省值
        netcdf.defVarDeflate(ncid, va_id, true, true, 5)
        Va = Velement.Va;
    end

    % -----
    netcdf.endDef(ncid);    % 结束nc文件定义
    % 将数据放入相应的变量
    netcdf.putVar(ncid, lon_id,                                                   Lon);         % 经度
    netcdf.putVar(ncid, lat_id,                                                   Lat);         % 纬度
    netcdf.putVar(ncid, time_id, 0,      length(time),                            time);        % 时间
    netcdf.putVar(ncid, TIME_id, [0,0],  [size(char(TIME),2),size(char(TIME),1)], char(TIME)'); % 时间char
    if SWITCH.std
        netcdf.putVar(ncid, dep_std_id, Depth_std);       % 深度
        if SWITCH.u
            netcdf.putVar(ncid, u_std_id, [0,0,0,0], [size(U_std,1), size(U_std,2), size(U_std,3), size(U_std,4)], U_std);  % u
        end
        if SWITCH.v
            netcdf.putVar(ncid, v_std_id, [0,0,0,0], [size(V_std,1), size(V_std,2), size(V_std,3), size(V_std,4)], V_std);  % v
        end
        if SWITCH.w
            netcdf.putVar(ncid, w_std_id, [0,0,0,0], [size(W_std,1), size(W_std,2), size(W_std,3), size(W_std,4)], W_std);  % w
        end
    end

    if SWITCH.sgm
        netcdf.putVar(ncid,bathy_id,Bathy);    % bathy
        netcdf.putVar(ncid,siglay_id,Siglay);  % Siglay
        if SWITCH.u
            netcdf.putVar(ncid, u_sgm_id, [0,0,0,0], [size(U_sgm,1), size(U_sgm,2), size(U_sgm,3), size(U_sgm,4)], U_sgm);  % u_sgm
        end
        if SWITCH.v
            netcdf.putVar(ncid, v_sgm_id, [0,0,0,0], [size(V_sgm,1), size(V_sgm,2), size(V_sgm,3), size(V_sgm,4)], V_sgm);  % v_sgm
        end
        if SWITCH.w
            netcdf.putVar(ncid, w_sgm_id, [0,0,0,0], [size(W_sgm,1), size(W_sgm,2), size(W_sgm,3), size(W_sgm,4)], W_sgm);  % w_sgm
        end
    end

    if SWITCH.avg
        netcdf.putVar(ncid, dep_avg_id, Depth_avg);       % 深度
        if SWITCH.u
            netcdf.putVar(ncid, u_avg_id, [0,0,0,0], [size(U_avg,1), size(U_avg,2), size(U_avg,3), size(U_avg,4)], U_avg);  % u
        end
        if SWITCH.v
            netcdf.putVar(ncid, v_avg_id, [0,0,0,0], [size(V_avg,1), size(V_avg,2), size(V_avg,3), size(V_avg,4)], V_avg);  % v
        end
        if SWITCH.w
            netcdf.putVar(ncid, w_avg_id, [0,0,0,0], [size(W_avg,1), size(W_avg,2), size(W_avg,3), size(W_avg,4)], W_avg);  % w
        end
    end

    if SWITCH.ua
        netcdf.putVar(ncid, ua_id, [0,0,0], [size(Ua,1), size(Ua,2), size(Ua,3)], Ua);  % ua
    end
    if SWITCH.va
        netcdf.putVar(ncid, va_id, [0,0,0], [size(Va,1), size(Va,2), size(Va,3)], Va);  % va
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

    netcdf.putAtt(ncid, time_id, 'units',     'seconds since 1970-01-01 00:00:00'); % 时间
    netcdf.putAtt(ncid, time_id, 'long_name', 'UTC time');                          % 时间
    netcdf.putAtt(ncid, time_id, 'calendar',  'gregorian');                         % 时间

    netcdf.putAtt(ncid, TIME_id, 'reference',  TIME_reference);  % 时间char
    netcdf.putAtt(ncid, TIME_id, 'long_name',  'UTC time');      % 时间char
    netcdf.putAtt(ncid, TIME_id, 'start_date', TIME_start_date); % 时间char
    netcdf.putAtt(ncid, TIME_id, 'end_date',   TIME_end_date);   % 时间char

    if SWITCH.std
        netcdf.putAtt(ncid, dep_std_id, 'units',     'm');              % 深度
        netcdf.putAtt(ncid, dep_std_id, 'long_name', 'standard depth'); % 深度
        netcdf.putAtt(ncid, dep_std_id, 'positive',  'down');           % 深度
        if SWITCH.u
            netcdf.putAtt(ncid, u_std_id, 'units',       'm/s');                                        % u
            netcdf.putAtt(ncid, u_std_id, 'long_name',   'eastward water velocity at standard levels'); % u
            netcdf.putAtt(ncid, u_std_id, 'coordinates', 'standard levels');                            % u
        end
        if SWITCH.v
            netcdf.putAtt(ncid, v_std_id, 'units',       'm/s');                                         % v
            netcdf.putAtt(ncid, v_std_id, 'long_name',   'northward water velocity at standard levels'); % v
            netcdf.putAtt(ncid, v_std_id, 'coordinates', 'standard levels');                             % v
        end
        if SWITCH.w
            netcdf.putAtt(ncid, w_std_id, 'units',       'm/s');                                        % w
            netcdf.putAtt(ncid, w_std_id, 'long_name',   'vertical water velocity at standard levels'); % w
            netcdf.putAtt(ncid, w_std_id, 'coordinates', 'standard levels');                            % w
        end
    end

    if SWITCH.sgm
        netcdf.putAtt(ncid, bathy_id, 'units',     'm');               % bathy
        netcdf.putAtt(ncid, bathy_id, 'long_name', 'bathy of ocean');  % bathy
  
        netcdf.putAtt(ncid, siglay_id, 'units',         '1');                       % Siglay
        netcdf.putAtt(ncid, siglay_id, 'long_name',     'sigma layers');            % Siglay
        netcdf.putAtt(ncid, siglay_id, 'positive',      'down');                    % Siglay
        netcdf.putAtt(ncid, siglay_id, 'standard_name', 'ocean sigma coordinate');  % Siglay
        if SWITCH.u
            netcdf.putAtt(ncid, u_sgm_id, 'units',       'm/s');                                     % u_sgm
            netcdf.putAtt(ncid, u_sgm_id, 'long_name',   'eastward water velocity at sigma levels'); % u_sgm
            netcdf.putAtt(ncid, u_sgm_id, 'coordinates', 'sigma levels');                            % u_sgm
        end
        if SWITCH.v
            netcdf.putAtt(ncid, v_sgm_id, 'units',       'm/s');                                      % v_sgm
            netcdf.putAtt(ncid, v_sgm_id, 'long_name',   'northward water velocity at sigma levels'); % v_sgm
            netcdf.putAtt(ncid, v_sgm_id, 'coordinates', 'sigma levels');                             % v_sgm
        end
        if SWITCH.w
            netcdf.putAtt(ncid, w_sgm_id, 'units',       'm/s');                                     % w_sgm
            netcdf.putAtt(ncid, w_sgm_id, 'long_name',   'vertical water velocity at sigma levels'); % w_sgm
            netcdf.putAtt(ncid, w_sgm_id, 'coordinates', 'sigma levels');                            % w_sgm
        end
    end

    if SWITCH.avg
        netcdf.putAtt(ncid, dep_avg_id, 'units',     'm');                                 % 深度
        netcdf.putAtt(ncid, dep_avg_id, 'long_name', sprintf('average depth between %.1f and %.1f, such on', Depth_avg(1,1),Depth_avg(1,2)));% 深度
        netcdf.putAtt(ncid, dep_avg_id, 'positive',  'down');                              % 深度
        if SWITCH.u
            netcdf.putAtt(ncid, u_avg_id, 'units',       'm/s');                                       % u
            netcdf.putAtt(ncid, u_avg_id, 'long_name',   'eastward water velocity at average levels'); % u
            netcdf.putAtt(ncid, u_avg_id, 'coordinates', 'average levels');                            % u
        end
        if SWITCH.v
            netcdf.putAtt(ncid, v_avg_id, 'units',       'm/s');                                        % v
            netcdf.putAtt(ncid, v_avg_id, 'long_name',   'northward water velocity at average levels'); % v
            netcdf.putAtt(ncid, v_avg_id, 'coordinates', 'average levels');                             % v
        end
        if SWITCH.w
            netcdf.putAtt(ncid, w_avg_id, 'units',       'm/s');                                       % w
            netcdf.putAtt(ncid, w_avg_id, 'long_name',   'vertical water velocity at average levels'); % w
            netcdf.putAtt(ncid, w_avg_id, 'coordinates', 'average levels');                            % w
        end
    end

    if SWITCH.ua
        netcdf.putAtt(ncid, ua_id, 'units',       'm/s');                             % ua
        netcdf.putAtt(ncid, ua_id, 'long_name',   'average eastward water velocity'); % ua
        netcdf.putAtt(ncid, ua_id, 'coordinates', 'average levels');                  % ua
    end
    if SWITCH.va
        netcdf.putAtt(ncid, va_id, 'units',       'm/s');                              % va
        netcdf.putAtt(ncid, va_id, 'long_name',   'average northward water velocity'); % va
        netcdf.putAtt(ncid, va_id, 'coordinates', 'average levels');                   % va
    end

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
            NC.(key{i}(8:end)) = structIn.(key{i});
        end
    end
end
