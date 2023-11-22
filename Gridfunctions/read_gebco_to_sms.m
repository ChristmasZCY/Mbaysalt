function read_gebco_to_sms(res)
    %       read gebco file and write to xyz file, res=1 means 1/240 degree, res=2 means 1/120 degree and so on
    % =================================================================================================================
    % Parameter:
    %       res: resolution of gebco file  || required: True || type: int || format: 3
    % =================================================================================================================
    % Example:
    %       read_gebco_to_sms(2)
    % =================================================================================================================

    para_conf = read_conf("Grid_functions.conf");
    file = para_conf.gebcoNCfile;
    lon1 = para_conf.lon_west;
    lon2 = para_conf.lon_east;
    lat1 = para_conf.lat_south;
    lat2 = para_conf.lat_north;
    xyz_name = para_conf.xyz_name;
    Outpath_dir = para_conf.save_path;    
    
    xyz_file = fullfile(Outpath_dir,xyz_name);
    Lon = [lon1 lon2];
    Lat = [lat1 lat2];
    clear lon1 lon2 lat1 lat2 xyz_name Outpath_dir

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

    lon(ele>10) = [];
    lat(ele>10) = [];
    ele(ele>10) = [];
    % ele(ele>0) = -0.5;

    fid = fopen(xyz_file,"w+");
    fprintf(fid,'%12.8f %12.8f %12.8f \n',[lon';lat';ele']);
    fclose(fid);

end
