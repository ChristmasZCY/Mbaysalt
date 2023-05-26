function make_maskmat(mask_ncfile,LON,LAT,file_matmask)
    % =================================================================================================================
    % discription:
    %       make mask mat file from gebco nc file
    %       gebco website: https://www.gebco.net/data_and_products/gridded_bathymetry_data/
    %       gebco nc file can be downloaded from https://www.bodc.ac.uk/data/open_download/gebco/gebco_2022/zip/
    % =================================================================================================================
    % parameter:
    %       mask_ncfile: gebco nc file                || required: True || type: char    || format: 'gebco_2022.nc'
    %       LON: longitude of the rectangle grid      || required: True || type: double  || format: [120:.1:130]
    %       LAT: latitude of the rectangle grid       || required: True || type: double  || format: [20:.1:30]
    %       file_matmask: mat file name               || required: True || type: char    || format: 'elevation.mat'
    % =================================================================================================================
    % example:
    %       make_maskmat(file_ncmask,LON,LAT,file_matmask)
    % =================================================================================================================

    lon_gebco = ncread(mask_ncfile,'lon');
    lat_gebco = ncread(mask_ncfile,'lat');
    i_inx = find( lon_gebco <= LON(end)+1 & lon_gebco>= LON(1)-1 );
    j_inx = find( lat_gebco <= LAT(end)+1 & lat_gebco>= LAT(1)-1 );
    n_lon = length(i_inx);
    n_lat = length(j_inx);
    lon_gebco  = lon_gebco(i_inx);
    lat_gebco  = lat_gebco(j_inx);
    elevation = double(ncread(mask_ncfile, 'elevation',[i_inx(1) j_inx(1)],[n_lon n_lat]));
    clear i_inx j_inx n_lon n_lat

    Elevation = interpn(lon_gebco,lat_gebco,elevation,LON,LAT','makima');
    Elevation(Elevation>0) = 0;  % 陆地为0,被mask
    Elevation(Elevation<0) = 1;  % 海洋为1,不被mask
    Elevation=logical(Elevation);
    clearvars -except Elevation file_matmask
    
    save(file_matmask, 'Elevation')

end