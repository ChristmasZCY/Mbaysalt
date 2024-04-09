function read_gebco_to_sms(fin, fout, lon_range, lat_range, res)
    %       read gebco file and write to xyz file, res=1 means 1/240 degree, res=2 means 1/120 degree and so on
    % =================================================================================================================
    % Parameter:
    %       fin: gebco file path                 || required: True || type: string || example: 'gebco.nc'
    %       fout: xyz file path                  || required: True || type: string || example: 'gebco.xyz'
    %       lon_range: longitude range to select || required: True || type: int || example: [100 120]
    %       lat_range: latitude range to select  || required: True || type: int || example: [20 30]
    %       res: resolution of gebco file        || required: True || type: int || example:  3
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created, by Christmas;
    %       2024-04-08:     Change input parameter to lon_range, lat_range, res, by Christmas;
    % =================================================================================================================
    % Example:
    %       read_gebco_to_sms('gebco.nc','gebco.xyz',[100 120],[20 30],3)
    % =================================================================================================================

    file = fin;

    Lon = lon_range;
    Lat = lat_range;

    lon = ncread(file,'lon');
    lat = ncread(file,'lat');

    i_inx = find( lon <= Lon(end) & lon>= Lon(1) );
    j_inx = find( lat <= Lat(end) & lat>= Lat(1) );
    n_lon = length(i_inx);
    n_lat = length(j_inx);
    lon  = lon(i_inx);
    lat  = lat(j_inx);
    ele = double(ncread(file,'elevation',[i_inx(1) j_inx(1)],[n_lon n_lat]))';

    clearvars i_* n_*

    [lon,lat] = meshgrid(lon,lat);

    lon = lon(1:res:end,1:res:end);
    lat = lat(1:res:end,1:res:end);
    ele = ele(1:res:end,1:res:end);

    lon = reshape(lon,[],1);
    lat = reshape(lat,[],1);
    ele = reshape(ele,[],1);

    % lon(ele>10) = [];
    % lat(ele>10) = [];
    % ele(ele>10) = [];
    % ele(ele>0) = -0.5;

    fid = fopen(fout,"w+");
    fprintf(fid,'%12.8f %12.8f %12.8f \n',[lon';lat';ele']);
    fclose(fid);

end
