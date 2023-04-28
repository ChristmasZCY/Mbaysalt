function  new_filename = standard_filename(pre, lon, lat, yyyymmdd, res)
    % =================================================================================================================
    % discription:
    %       This function is used to make standard filename
    % =================================================================================================================
    % parameter:
    %       pre:  prefix                      || required: True || type: string || format: 'adt'
    %       lon:  longitude                   || required: True || type: double || format: [120.5, 121.5]
    %       lat:  latitude                    || required: True || type: double || format: [30.5, 31.5]
    %       yyyymmdd:  time                   || required: True || type: string || format: '20221110'
    %       res:  resolution                  || required: True || type: string || format: '5'
    %       new_filename: standard filename   || required: True || type: string || format: 'adt_120.50W_121.50E_30.50S_31.50N_20221110_5.nc'
    % =================================================================================================================
    % example:
    %       standard_filename('adt', [120.5, 121.5], [30.5, 31.5], '20221110', '5')
    % =================================================================================================================

    yyyymmdd = num2str(yyyymmdd);
    res = num2str(res);

    if min(lon) < 0; Lon_1 = [num2str(abs(min(lon)), '%3.2f'), 'W']; else; Lon_1 = [num2str(min(lon), '%3.2f'), 'E']; end
    if max(lon) < 0; Lon_2 = [num2str(abs(max(lon)), '%3.2f'), 'W']; else; Lon_2 = [num2str(max(lon), '%3.2f'), 'E']; end
    if min(lat) < 0; Lat_1 = [num2str(abs(min(lat)), '%2.2f'), 'S']; else; Lat_1 = [num2str(min(lat), '%2.2f'), 'N']; end
    if max(lat) < 0; Lat_2 = [num2str(abs(max(lat)), '%2.2f'), 'S']; else; Lat_2 = [num2str(max(lat), '%2.2f'), 'N']; end
    new_filename = [pre,'_', Lon_1, '_', Lon_2, '_', Lat_1, '_', Lat_2, '_', yyyymmdd, '_', res ,'.nc'];
    clear  Lon_* Lat_*

end
