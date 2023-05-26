function [ua,up,va,vp,ha,hp,lat,lon] = uvhap(lon_range,lat_range, res, varargin)
    % =================================================================================================================
    % discription:
    %       read tpxo9_atlas data and get ua,up,va,vp,ha,hp,lat,lon
    % =================================================================================================================
    % parameter:
    %       lon_range: longitude range        || required: True || type: double || format: [100:114]
    %       lat_range: latitude range         || required: True || type: double || format: [20:30]
    %       res: res/30 resolution            || required: True || type: double || format: 1
    %       varargin:                         || required: False|| None
    %       ua: u amplitude                    || required: True || type: double || format: matrix
    %       up: u phase                        || required: True || type: double || format: matrix
    %       va: v amplitude                    || required: True || type: double || format: matrix
    %       vp: v phase                        || required: True || type: double || format: matrix
    %       ha: h amplitude                    || required: True || type: double || format: matrix
    %       hp: h phase                        || required: True || type: double || format: matrix
    %       lat: latitude                      || required: True || type: double || format: matrix
    %       lon: longitude                     || required: True || type: double || format: matrix
    % =================================================================================================================
    % example:
    %       [ua,up,va,vp,ha,hp,lat,lon] = uvhap([100:114],[20:30],1);
    % =================================================================================================================

    Conf = read_conf('tpxo.conf');
    if Conf.Switch_make_file_fixed_coordinate
        make_tpxo_fixed_coordinate('tpxo_file.json')
    end

    [~, grid_file, ~, uv_file, ~, h_file] = get_tpxo_filepath('tpxo_file.json');


    lon = ncread(grid_file, 'lon');
    lat = ncread(grid_file, 'lat');

    %% 指定范围lonrange latrange
    index_lon = find(lon >= lon_range(1) & lon<= lon_range(end)); %获得目标区域内，所有点的经度和纬度，然后再网格化
    index_lat = find(lat >= lat_range(1) & lat<= lat_range(end));

    if isempty(index_lon); index_lon = empty_to_nearest(lon_range, lon);end
    if isempty(index_lat); index_lat = empty_to_nearest(lat_range, lat);end

    %% 指定分辨率res(步数--5401*10800 -- 1res=1/30°)
    start_lat = index_lat(1);
    count_lat = round(length(index_lat)/res);
    start_lon = index_lon(1);
    count_lon = round(length(index_lon)/res);

    lat = ncread(grid_file, 'lat', start_lat, count_lat, res);
    lon = ncread(grid_file, 'lon', start_lon, count_lon, res);
    
    Uhu = double(ncread(grid_file, 'hu', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
    Vhv = double(ncread(grid_file, 'hv', [start_lat,start_lon], [count_lat,count_lon], [res, res]));

    clearvars -except uv_file h_file start_* count_* res Uhu Vhv lon lat

    ua = zeros(length(uv_file), count_lat, count_lon);
    up = ua; va = ua; vp = ua;
    ha = ua; hp = ua;

    for g = 1 : length(uv_file)
        % 5401*10800-int32
        uRe = double(ncread(uv_file{g}, 'uRe', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        uIm = double(ncread(uv_file{g}, 'uIm', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        vRe = double(ncread(uv_file{g}, 'vRe', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        vIm = double(ncread(uv_file{g}, 'vIm', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        hRe = double(ncread(h_file{g}, 'hRe', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        hIm = double(ncread(h_file{g}, 'hIm', [start_lat,start_lon], [count_lat,count_lon], [res, res]));
        
        % 输运./深度=流速 m/s
        ua(g,:,:) = abs((uRe/10000) + 1i*(uIm/10000))./Uhu;
        up(g,:,:) = atan2(-(uIm/10000),(uRe/10000))/pi*180;
        va(g,:,:) = abs((vRe/10000) + 1i*(vIm/10000))./Vhv;
        vp(g,:,:) = atan2(-(vIm/10000),(vRe/10000))/pi*180;   
        ha(g,:,:) = abs((hRe/1000)+1i*(hIm/1000));
        hp(g,:,:) = atan2(-(hIm/1000),(hRe/1000))/pi*180;

    end

end

function index = empty_to_nearest(lon_range,Lon)
    lon_avg = mean(lon_range,'omitnan');
    [~,index] = min(abs(Lon-lon_avg));
end


