function make_tide_from_tpxo(yyyy, mm, varargin)
    %       Make tide current u/v/h from TPXO9-atlas, and write to nc file.
    % =================================================================================================================
    % Parameter:
    %       yyyy: year                             || required: True || type: double         ||  example: 2019 or '2019'
    %       mm: month                              || required: True || type: double         ||  example: 1 or '1'
    %       varargin: (optional)
    %           day_len: days after to predict     || required: False || type: double         ||  example: [1:3] or [1:6]
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2024-01-10:     Completed, by Christmas;
    % =================================================================================================================
    % Example:
    %       make_tide_from_tpxo(2023,5)
    %       make_tide_from_tpxo(2023,5,[1,3,5])
    %       make_tide_from_tpxo(2023,5,[1:10])
    %       make_tide_from_tpxo(2023,5,[1,3,5,11,21,51])
    % =================================================================================================================

    arguments(Input)
        yyyy {mustBeNumeric}
        mm {mustBeNumeric}
    end
    arguments(Repeating)
        varargin
    end

    %% 位置
    conf = read_conf('tpxo.conf');
    OutputPath = conf.OutputPath;  % 不要创建！ 含${yyyymmdd}$
    SWITCH = read_switch(conf);
    TNF_mat = conf.TNF_mat;
    Lon = conf.Lon;  %   0:.2:360
    Lat = conf.Lat;  % -90:.2:90
    res = conf.Res;
    res_filename = conf.Res_filename;
    lon = Lon;  %   0:.2:360
    lat = Lat;  % -90:.2:90

    %% 构建时间序列
    if ~isa(yyyy,'double');yyyy = str2double(yyyy);end
    if ~isa(mm,'double');mm = str2double(mm);end
    
    if isempty(varargin)
        day_length = 1: eomday(yyyy,mm);  % 一个月的天数
    else
        day_length = varargin{1};
        varargin(1) = [];
    end

    if ~ isMATLABReleaseOlderThan("R2024a")
        time = createArray([24,length(day_length)]);
    else
        time = zeros(24,length(day_length),'double');
    end
    for dd = day_length
        for i = 1 : 24
            time(i,dd) = datenum(yyyy,mm,dd)+(i-1)/24.0; %#ok<DATNM> % datenum是天，小时要除以24，UTC
        end
    end
    clear i dd
    time = reshape(time, [], 1);
 %% t_tide 正文
    [ua,up,va,vp,ha,hp,lat,lon]=uvhap(lon,lat,res); % 1=1/30
    [Preu,Prev,Preh] = preuvh(ua, up, va, vp, ha, hp, lat, time, 'Cdisp', 'tidecon', TNF_mat);

    clear ua up va vp ha hp
    % 0-360 --> -180-0-180
    if SWITCH.change_lon_to_180
        [lon,Preu,Prev, Preh] = ll_to_ll(lon,Preu,Prev,Preh);
        Lon = ll_to_ll(Lon);
    end
    % interpn
    osprint2('INFO',['Fixed grid to destination grid --> ',logical_to_char(SWITCH.fixed_to_dst_grid)]);
    if SWITCH.fixed_to_dst_grid
        method_interpn = conf.Method_interpn;
        try
            PreuS = interpn(lon,lat,time,Preu,Lon,Lat,time,method_interpn);
            PrevS = interpn(lon,lat,time,Prev,Lon,Lat,time,method_interpn);
            PrehS = interpn(lon,lat,time,Preh,Lon,Lat,time,method_interpn);
            clear Preu Prev Preh lon lat
            Preu = PreuS; Prev = PrevS; Preh = PrehS; lon = Lon; lat = Lat;
        catch ME1
            osprint2('ERROR','Fixed grid to destination grid Failed!');
        end          
    end
    
    % ---> Fixed
    % 插值后的tpxo数据，计算prev会产生Inf或者-Inf
    % 2023,5,[1:3]    2023,5,[1:6]    2023,5,[1:18]会出现
    if max(Prev(:)) == Inf || min(Prev(:)) == -Inf
        Prev(Prev==Inf)  = NaN;
        Prev(Prev==-Inf) = NaN;
        osprint2('WARNING','Appear Inf or -Inf, fix to NaN.')
    end
    % <--- Fixed
    % 时间
    Time = datetime(time','ConvertFrom','datenum');
    
    for dd = 1 : length(day_length)
        try
            preu = Preu(:,:,(dd-1)*24+1:dd*24);
            prev = Prev(:,:,(dd-1)*24+1:dd*24);
            preh = Preh(:,:,(dd-1)*24+1:dd*24);
        catch ME1
            preu = Preu(:,(dd-1)*24+1:dd*24);
            prev = Prev(:,(dd-1)*24+1:dd*24);
            preh = Preh(:,(dd-1)*24+1:dd*24);
        end
        Time_dd = Time((dd-1)*24+1:dd*24);
        time = posixtime(Time_dd);
        time_filename = char(datetime(Time_dd(1),'Format','yyyyMMdd')); % 文件名的时间部分
        clear Time_dd
        % filename
        % ncfile = standard_filename('tideCurrent', lon, lat, time_filename, num2str(res_filename));
        ncfile = ['tideCurrentLevel_',num2str(res_filename),'.nc'];
        % 写入nc文件
        OutputDir = replace_para(OutputPath, 'yyyymmdd', time_filename);
        ncid = netcdf_fvcom.create_nc(fullfile(OutputDir,ncfile), 'NETCDF4');
        netcdf_tpxo.wrnc_tpxo(ncid, lon, lat, time, preu, prev, preh);
        clear ncid OutputDir time_filename
    end
    
    clear yyyy mm OutputPath
end

function SWITCH = read_switch(struct)
    % 从struct中读取以SWITCH.开头的变量，将变量写入到switch结构体中
    % eg: 将struct中的Switch_erosion写入到switch.erosion中
    key = fieldnames(struct);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^Switch_','once'))
            SWITCH.(key{i}(8:end)) = struct.(key{i});
        end
    end
end

function switch_char = logical_to_char(switch_logical)
    switch switch_logical
    case true
        switch_char = 'TRUE';
    case false
        switch_char = 'FALSE';
    otherwise
        error('Unexpected input.')
    end
end
