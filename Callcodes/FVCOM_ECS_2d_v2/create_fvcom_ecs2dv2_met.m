function create_fvcom_ecs2dv2_met(f2dm, din_forcing, fout, ymd_start, ymd_end)
    %       Create met forcing file for FVCOM_ECS_2d_v2, data from WRF2FVCOM
    % =================================================================================================================
    % Parameters:
    %       f2dm: model 2dm grid file       || required: True || type: text    || example: 'ecs2dv2.2dm'
    %       din_forcing: forcing dir        || required: True || type: text    || example: './forcing/global'
    %       fout: file output               || required: True || type: text    || example: './fvcom_ecs2dv2_met_forecast/fvcom_ecs2dv2_met_20230722.nc'
    %       ymd_start: date start           || required: True || type: double  || example: 20241105
    %       ymd_end: date start             || required: True || type: double  || example: 20241106
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-12-08:     Created,    by Christmas;
    % =================================================================================================================
    % Example:
    %       create_fvcom_ecs2dv2_met('ecs2dv2.2dm','./forcing/global','./fvcom_ecs2dv2_met_forecast/fvcom_ecs2dv2_met_20230722.nc',20241105,20241106)
    % =================================================================================================================
    
    ymd_start = num2str(ymd_start, '%8d');
    ymd_end = num2str(ymd_end, '%8d');
    t1 = datenum(ymd_start, 'yyyymmdd');
    t2 = datenum(ymd_end, 'yyyymmdd');
    f = f_load_grid(f2dm);

    varlist = ["U10", "V10", "Shortwave", "Net_Heat", ...
               "Evaporation", "Precipitation", "SLP", ...
               "SAT", "SPQ", "cloud_cover", ...
               "Stress_U", "Stress_V"];
    
    nvar = length(varlist);
    
    % Read data
    m2 = 0;
    for it = t1 : t2-1
        fin = [din_forcing '/' datestr(it, 'yyyymmdd') '/globalforcing.nc'];
    
        % Read the longitude and latitude, initialize
        if it == t1
            lon = ncread(fin, 'XLONG');
            lat = ncread(fin, 'XLAT');
            w_node = interp_2d_calc_weight('GLOBAL_BI', lon(:,1), lat(1,:), f.x, f.y);
            w_cell = interp_2d_calc_weight('GLOBAL_BI', lon(:,1), lat(1,:), f.xc, f.yc);
            for i = 1 : nvar
                var = varlist{i};
                eval([var ' = [];']);
            end
        end
    
        % Set the time of every iteration
        if it == t2-1
            n = 25;
        else
            n = 24;
        end
        m1 = m2 + 1;
        m2 = m1 + n - 1;
    
        % Read the data and do the interpolation
        for i = 1 : nvar
            var = varlist{i};
            eval(['data = ncread(fin, ''' var ''', [1 1 1], [Inf Inf n]);']);
            eval([var '(:,:,m1:m2) = data;']);
        end
    
    end
    
    % Interpolation
    for i = 1 : nvar
        var = varlist{i};
        if contains(var, 'U10') || contains(var, 'V10') || contains(var, 'Stress_U') || contains(var, 'Stress_V')
            eval([var ' = interp_2d_via_weight(' var ', w_cell);']);
        else
            eval([var ' = interp_2d_via_weight(' var ', w_node);']);
        end
    end

    % time
    time = t1 : 1/24 : t2;
    
    % Output
    makedirs(fileparts(fout));
    write_met_forcing_fvcom(fout, f.x, f.y, f.nv, time, ...
                                  'Coordinate', 'Geo', ...
                                  'uwind_speed',   U10, ...
                                  'vwind_speed',   V10, ...    
                                  'uwind_stress',  Stress_U, ...
                                  'vwind_stress',  Stress_V, ...
                                  'short_wave',    Shortwave, ...
                                  'net_heat_flux', Net_Heat, ...
                                  'air_pressure',  SLP, ...
                                  'evaporation',   Evaporation, ...
                                  'precipitation', Precipitation, ...
                                  'SAT',           SAT, ...
                                  'SPQ',           SPQ, ...
                                  'cloud_cover',   cloud_cover);

end
