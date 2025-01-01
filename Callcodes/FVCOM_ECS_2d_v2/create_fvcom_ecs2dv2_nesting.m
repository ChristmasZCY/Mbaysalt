function create_fvcom_ecs2dv2_nesting(fnest_nc, din_glory, din_tide, fout, yyyymmdd, day_len)
    %       Create nesting file for FVCOM_ECS_2d_v2, data from glory and tpxo
    % =================================================================================================================
    % Parameters:
    %       fnest_nc: nesting example file      || required: True || type: text    || example: 'fnesting_ecs2dv2_grid_example.nc'
    %       din_glory: glory data dir           || required: True || type: text    || example: './Data/GLORYS'
    %       din_tide: tide data dir             || required: True || type: text    || example: './ECS_2d_v2_tide'
    %       fout: file output                   || required: True || type: text    || example: './fvcom_ecs2dv2_nesting_forecast/fvcom_ecs2dv2_nesting_20241101.nc'
    %       yyyymmdd: date                      || required: True || type: double  || example: 20241105
    %       day_len: days length                || required: False|| type: double  || example: 1
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-12-08:     Created,    by Christmas;
    % =================================================================================================================
    % Example:
    %       create_fvcom_ecs2dv2_nesting('./data/fnesting_ecs2dv2_grid_example.nc', '../Data/GLORYS', './data/ECS_2d_v2_tide', './fvcom_ecs2dv2_nesting_forecast/fvcom_ecs2dv2_nesting_20241101.nc', 20241105, 1)
    % =================================================================================================================
    
    yyyymmdd = num2str(yyyymmdd, '%8d');
    day_len = num2str(day_len, '%3d');
    %% settings
    tide_name = [];

    TPXO_filepath = [];

    %% fgrid nesting
    fn = f_load_grid(fnest_nc,"Coordinate","geo"); clear fnest_nc
    
    %% read glorys
    fin.curr = sprintf('%s/%s/GLORYS_curr_0p083_%s_%sd.nc', din_glory, yyyymmdd, yyyymmdd, day_len);
    fin.temp = sprintf('%s/%s/GLORYS_temp_0p083_%s_%sd.nc', din_glory, yyyymmdd, yyyymmdd, day_len);
    fin.salt = sprintf('%s/%s/GLORYS_salt_0p083_%s_%sd.nc', din_glory, yyyymmdd, yyyymmdd, day_len);
    fin.zeta = sprintf('%s/%s/GLORYS_zeta_0p083_%s_%sd.nc', din_glory, yyyymmdd, yyyymmdd, day_len);
    
    glorys.lon = ncread(fin.curr, 'longitude');
    glorys.lat = ncread(fin.curr, 'latitude');
    glorys.Ttimes = Mdatetime(ncdateread(fin.curr, 'time'));
    glorys.u = ncread(fin.curr, 'uo');
    glorys.v = ncread(fin.curr, 'vo');
    glorys.t = ncread(fin.temp, 'thetao');
    glorys.s = ncread(fin.salt, 'so');
    glorys.z = ncread(fin.zeta, 'zos');
    glorys.d = ncread(fin.curr, 'depth');
    
    clear fin
    %% generate Ttimes
    Times_range = create_timeRange(glorys.Ttimes.Times(1), glorys.Ttimes.Times(end), '1h');
    Ttimes = Mdatetime(Times_range); clear Times_range
    
    %% interp_2d glorys
    [lat,lon] = meshgrid(glorys.lat, glorys.lon);
    weight_2d.nele = interp_2d_calc_weight("NEAREST",lon,lat,fn.xc,fn.yc);
    weight_2d.node = interp_2d_calc_weight("NEAREST",lon,lat,fn.x,fn.y);
    
    t_fgrid_std = interp_2d_via_weight(glorys.t,weight_2d.node);
    s_fgrid_std = interp_2d_via_weight(glorys.s,weight_2d.node);
    u_fgrid_std = interp_2d_via_weight(glorys.u,weight_2d.nele);
    v_fgrid_std = interp_2d_via_weight(glorys.v,weight_2d.nele);
    z_fgrid     = interp_2d_via_weight(glorys.z,weight_2d.node);
    
    clear weight_2d lon lat
    
    %% interp_vertical glorys
    weight_v.node = interp_vertical_calc_weight(repmat(glorys.d',[size(t_fgrid_std,1),1]), fn.deplay);
    weight_v.nele = interp_vertical_calc_weight(repmat(glorys.d',[size(u_fgrid_std,1),1]), fn.deplayc);
    
    t_cir = zeros([fn.node, fn.kbm1, len(glorys.Ttimes.Times)]); % node*dep*time
    s_cir = zeros([fn.node, fn.kbm1, len(glorys.Ttimes.Times)]); % node*dep*time
    u_cir = zeros([fn.nele, fn.kbm1, len(glorys.Ttimes.Times)]); % nele*dep*time
    v_cir = zeros([fn.nele, fn.kbm1, len(glorys.Ttimes.Times)]); % nele*dep*time
    
    for iz = 1: len(glorys.Ttimes.Times)
        t_cir(:,:,iz) = f_fill_missing(fn, interp_vertical_via_weight(t_fgrid_std(:,:,iz),weight_v.node));
        s_cir(:,:,iz) = f_fill_missing(fn, interp_vertical_via_weight(s_fgrid_std(:,:,iz),weight_v.node));
        u_cir(:,:,iz) = f_fill_missing(fn, interp_vertical_via_weight(u_fgrid_std(:,:,iz),weight_v.nele));
        v_cir(:,:,iz) = f_fill_missing(fn, interp_vertical_via_weight(v_fgrid_std(:,:,iz),weight_v.nele));
    end
    z_cir = f_fill_missing(fn, z_fgrid);
    clearvars t_fgrid_std s_fgrid_std u_fgrid_std v_fgrid_std z_fgrid weight_v iz
    
    %% interp_time glorys
    % weight_time = interp_time_calc_weight(glorys.Ttimes.time, Ttimes.time);
    % weight_time = interp_time_via_weight(t_cir, weight_time);
    t_cir = interp_time(t_cir, glorys.Ttimes.time, Ttimes.time);
    s_cir = interp_time(s_cir, glorys.Ttimes.time, Ttimes.time);
    u_cir = interp_time(u_cir, glorys.Ttimes.time, Ttimes.time);
    v_cir = interp_time(v_cir, glorys.Ttimes.time, Ttimes.time);
    z_cir = interp_time(z_cir, glorys.Ttimes.time, Ttimes.time);
    
    clear glorys
    
    %% generate tide
    
    TIDE = preuvh2(fn.xc, fn.yc, Ttimes.Times, tide_name, TPXO_filepath, din_tide, 'INFO','none','Vname','uv');
    TIDE.h = preuvh2(fn.x, fn.y, Ttimes.Times, tide_name, TPXO_filepath, din_tide, 'INFO','none','Vname','z').h;
    clearvars TPXO_filepath tide_name
    
    TIDE.h = f_fill_missing(fn,TIDE.h);
    TIDE.u = f_fill_missing(fn,TIDE.u);
    TIDE.v = f_fill_missing(fn,TIDE.v);
    
    u_tide = repmat(TIDE.u,[1,fn.kbm1,1]);
    v_tide = repmat(TIDE.v,[1,fn.kbm1,1]);
    z_tide = squeeze(TIDE.h);
    
    clearvars TIDE
    
    %% plus data
    u_all = u_cir + u_tide;
    v_all = v_cir + v_tide;
    z_all = z_cir + z_tide;
    t_all = t_cir;
    s_all = s_cir;
    clear *_cir *_tide
    
    ua = squeeze(mean(u_all,2));
    va = squeeze(mean(v_all,2));
    hyw = zeros(fn.node, fn.kb, len(Ttimes.Times));
    
    %% write nc
    makedirs(fileparts(fout));
    write_nesting(fout, fn, ...
        'Time',Ttimes.datenumC, ...
        'Zeta', z_all, ...
        'Temperature', t_all, ...
        'Salinity', s_all, ...
        'U', u_all, ...
        'V', v_all, ...
        'Ua', ua, ...
        'Va', va, ...
        'Hyw', hyw)

end


function generate_nesting_mat()

    lon = [113:1/30:152];
    lat = [5:1/30:42];
    [Times, Ttimes] = create_timeRange(datetime(2024,12,04,00,00,00),49,'1h');
    TIDE = preuvh2(lon, lat, Times, [], ...
        '/Users/christmas/Documents/Code/MATLAB/数据/TPXO/TPXO10/TPXO10_atlas_v2_bin', ...
        './ECS_2d_v2_tide', ...
        'Vname','all', ...
        'INFO', 'disp','createOnly');

end
