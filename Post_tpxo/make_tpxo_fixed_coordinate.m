function make_tpxo_fixed_coordinate(file_json)
    % =================================================================================================================
    % discription:
    %       Fixed the coordinate of TPX09_atlas to lon_u, lat_u
    % =================================================================================================================
    % parameter:
    %       file_json: json file                     || required: True || type: char or string  ||  format: 'tpxo_file.json'
    % =================================================================================================================
    % example:
    %       make_tpxo_fixed_coordinate('tpxo_file.json')
    % =================================================================================================================

    [grid_file_old, grid_file_new, ...
     tide_uv_file_old, tide_uv_file_new, ...
     tide_h_file_old, tide_h_file_new] = get_tpxo_filepath(file_json);

    lonu = ncread(grid_file_old, 'lon_u');
    latu = ncread(grid_file_old, 'lat_u');
    lonv = ncread(grid_file_old, 'lon_v');
    latv = ncread(grid_file_old, 'lat_v');
    
    %  v v v v v      -->  v v v v v
    % u u u u u       -->  u u u u u  v插值到u的坐标
    %  v v v v v      -->  v v v v v 
    
    lonv = [lonv(end)-360;lonv];  % 经度v要拼接
    % isequaln(lon_v,lon_z) == 1
    % isequaln(lat_u,lat_z) == 1
    [coord.latv, coord.lonv] = ndgrid(latv, lonv);
    [coord.lath, coord.lonh] = ndgrid(latu, lonv);
    [coord.latu, coord.lonu] = ndgrid(latu, lonu);
    coord.lon = lonu; coord.lat = latu;
    
    fixed_grid(grid_file_old, grid_file_new, lonu, latu)
    fixed_tide_uv(tide_uv_file_old, tide_uv_file_new, coord)
    fixed_tide_h(tide_h_file_old, tide_h_file_new, coord)

end
function fixed_tide_uv(tide_file_old, tide_file_new, coord)
    for g = 1 : length(tide_file_old)
    
        con = ncread(tide_file_old{g},'con');
        URE = double(ncread(tide_file_old{g}, 'uRe'));
        UIM = double(ncread(tide_file_old{g}, 'uIm'));
        vRe_1 = double(ncread(tide_file_old{g}, 'vRe'));
        vIm_1 = double(ncread(tide_file_old{g}, 'vIm'));
    
        vRe = [vRe_1(:,end),vRe_1];
        vIm = [vIm_1(:,end),vIm_1];
  
        VRE = interpn(coord.latv, coord.lonv, vRe, coord.latu, coord.lonu);
        VIM = interpn(coord.latv, coord.lonv, vIm, coord.latu, coord.lonu);
    
        myVarSchema = ncinfo(tide_file_old{g});
        myVarSchema.Variables(4) =[];
        myVarSchema.Variables(4) =[];
        myVarSchema.Variables(2).Name = 'lon';
        myVarSchema.Variables(3).Name = 'lat';
        myVarSchema.Variables(2).Attributes(1).Value = 'longitude of nodes';
        myVarSchema.Variables(3).Attributes(1).Value = 'latitude of nodes';
        myVarSchema.Format = 'NETCDF4';
        rmfiles(tide_file_new{g});
        ncwriteschema(tide_file_new{g},myVarSchema);
        ncwrite(tide_file_new{g},'lon',coord.lon);
        ncwrite(tide_file_new{g},'lat',coord.lat);
        ncwrite(tide_file_new{g},'uRe',URE);
        ncwrite(tide_file_new{g},'uIm',UIM);
        ncwrite(tide_file_new{g},'vRe',VRE);
        ncwrite(tide_file_new{g},'vIm',VIM);
        ncwrite(tide_file_new{g},'con',con);
    
    end
end

function fixed_tide_h(tide_file_old, tide_file_new, coord)
    for g = 1 : length(tide_file_old)
    
        con = ncread(tide_file_old{g},'con');
        hRe_1 = double(ncread(tide_file_old{g}, 'hRe'));
        hIm_1 = double(ncread(tide_file_old{g}, 'hIm'));
    
        hRe = [hRe_1(:,end),hRe_1];
        hIm = [hIm_1(:,end),hIm_1];
    
    
        HRE = interpn(coord.lath, coord.lonh, hRe, coord.latu, coord.lonu);
        HIM = interpn(coord.lath, coord.lonh, hIm, coord.latu, coord.lonu);

        myVarSchema = ncinfo(tide_file_old{g});
        myVarSchema.Variables(2).Name = 'lon';
        myVarSchema.Variables(3).Name = 'lat';
        myVarSchema.Variables(2).Attributes(1).Value = 'longitude of nodes';
        myVarSchema.Variables(3).Attributes(1).Value = 'latitude of nodes';
        myVarSchema.Format = 'NETCDF4';
        rmfiles(tide_file_new{g});
        ncwriteschema(tide_file_new{g},myVarSchema);
        ncwrite(tide_file_new{g},'lon',coord.lon);
        ncwrite(tide_file_new{g},'lat',coord.lat);
        ncwrite(tide_file_new{g},'hRe',HRE);
        ncwrite(tide_file_new{g},'hIm',HIM);
        ncwrite(tide_file_new{g},'con',con);
    
    end
end

function fixed_grid(grid_file_old, grid_file_new, lon ,lat)

    hu = ncread(grid_file_old, 'hu');
    hv = ncread(grid_file_old, 'hv');
    hz = ncread(grid_file_old, 'hz');
    
    
    myVarSchema = ncinfo(grid_file_old);
    myVarSchema.Variables(1) =[];
    myVarSchema.Variables(1) =[];
    myVarSchema.Variables(3) =[];
    myVarSchema.Variables(3) =[];
    myVarSchema.Variables(1).Name = 'lon';
    myVarSchema.Variables(2).Name = 'lat';
    myVarSchema.Variables(1).Attributes(1).Value = 'longitude of nodes';
    myVarSchema.Variables(2).Attributes(1).Value = 'latitude of nodes';
    myVarSchema.Format = 'NETCDF4';
    rmfiles(grid_file_new)
    ncwriteschema(grid_file_new,myVarSchema);
    ncwrite(grid_file_new,'lon',lon);
    ncwrite(grid_file_new,'lat',lat);
    ncwrite(grid_file_new,'hu',hu);
    ncwrite(grid_file_new,'hv',hv);
    ncwrite(grid_file_new,'hz',hz);
end