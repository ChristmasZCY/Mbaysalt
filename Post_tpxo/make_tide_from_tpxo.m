function make_tide_from_tpxo(yyyy, mm, varargin)
    % =================================================================================================================
    % discription:
    %       Make tide current u/v/h from TPXO9-atlas, and write to nc file.
    % =================================================================================================================
    % parameter:
    %       yyyy: year                             || required: True || type: double         ||  format: 2019 or '2019'
    %       mm: month                              || required: True || type: double         ||  format: 1 or '1'
    %       varargin{1}: day_length                || required: False|| type: double         ||  format: 1:31
    % =================================================================================================================
    % example:
    %       make_tide_from_tpxo(2019,1)
    %       make_tide_from_tpxo(2019,1,[1,3,5])
    % =================================================================================================================

    %% 位置
    conf = read_conf('tpxo.conf');
    OutputPath = conf.OutputPath;  % 不要创建！ 含${yyyymmdd}$
    TNF_mat = conf.TNF_mat;
    lon = conf.Lon;
    lat = conf.Lat;
    res = conf.Res;
    res_filename = conf.Res_filename;

    %% 构建时间序列
    if ~isa(yyyy,'double');yyyy = str2double(yyyy);end
    if ~isa(mm,'double');mm = str2double(mm);end
    
    if isempty(varargin)
        day_length = 1: eomday(yyyy,mm);  % 一个月的天数
    else
        day_length = varargin{1};
    end

    time = zeros(24,length(day_length),'double');
    for dd = day_length
        for i = 1 : 24
            time(i,dd) = datenum(yyyy,mm,dd)+(i-1)/24.0; %#ok<DATNM> % datenum是天，小时要除以24，UTC
        end
    end
    clear i dd
    time = reshape(time, [], 1);
 %% t_tide 正文
    [ua,up,va,vp,ha,hp,lat,lon]=uvhap(lon,lat,res); %1=1/30
    [preu,prev,preh] = preuvh(ua, up, va, vp, ha, hp, lat, time, 'Cdisp', 'tidecon', TNF_mat);
    Preu = permute(real(squeeze(preu)),[2,1,3]);  % 各小时的u方向流速
    Prev = permute(real(squeeze(prev)),[2,1,3]);  % 各小时的v方向流速
    Preh = permute(real(squeeze(preh)),[2,1,3]);  % 各小时的水位
    clear preu prev preh
    clear ua up va vp ha hp
    %% 0-360 --> -180-0-180
    [lon,Preu,Prev, Preh] = ll_to_ll(lon,Preu,Prev,Preh);
     %% 时间
    Time = datetime(time','ConvertFrom','datenum');
    
    for dd = 1 : length(day_length)
        preu = Preu(:,:,(dd-1)*24+1:dd*24);
        prev = Prev(:,:,(dd-1)*24+1:dd*24);
        preh = Preh(:,:,(dd-1)*24+1:dd*24);
        Time_dd = Time((dd-1)*24+1:dd*24);
        time = posixtime(Time_dd);
        time_filename = char(datetime(Time_dd(1),'Format','yyyyMMdd')); % 文件名的时间部分
        clear Time_dd
        %% filename
        ncfile = standard_filename('tideCurrent', lon, lat, time_filename, num2str(res_filename));
        %% 写入nc文件
        OutputDir = replace_para(OutputPath, 'yyyymmdd', time_filename);
        ncid = netcdf_fvcom.create_nc(fullfile(OutputDir,ncfile), 'NETCDF4');
        netcdf_tpxo.wrnc_tpxo(ncid, lon, lat, time, preu, prev, preh);
        clear ncid OutputDir time_filename
    end
    
    clear yyyy mm OutputPath
end