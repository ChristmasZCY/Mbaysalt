function writeNC_nesting_mexcef(fout, fn, time, varargin)
    %       Write the nesting file for FVCOM, with mexcdf
    % =================================================================================================================
    % Parameter:
    %       fout:            output file name        || required: True  || type: string    || format: 'nesting.nc'
    %       fn:              fvcom nesting grid      || required: True  || type: struct    || format: struct
    %       time:            time                    || required: True  || type: double    || format: posix time
    %       varargin:       (Variables below can be writen in to a random order.)
    %           Variable name  | Description        | size               | unit
    %           Time            time               (nt)                 datenum format
    %           Zeta            surface elevation  (node, nt)           m
    %           Temperature     water temperature  (node, siglay, nt)   degree C
    %           Salinity        water salinity     (node, siglay, nt)   psu
    %           U               x-velocity         (nele, siglay, nt)   m/s
    %           V               y-velocity         (nele, siglay, nt)   m/s
    %           Ua              x-velocity-avg     (node, nt)           m/s
    %           Va              y-velocity-avg     (node, nt)           m/s
    %           Hyw             z-velocity         (node, siglev, nt)   m/s
    %           weight_node     weight on node     (node, nt)           1
    %           weight_cell     weight on cell     (nele, nt)           1
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-11-07:     Edited code from Yang Ding, by Christmas;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.writeNC_nesting_mexcef('nesting.nc', fn, time, ...
    %                                           'Zeta', Zeta, 'Temperature', Temperature, ...
    %                                           'Salinity', Salinity, 'U', U, 'V', V, 'Hyw', Hyw, ...
    %                                           'weight_node', weight_node, 'weight_cell', weight_cell);
    % =================================================================================================================

    varargin = read_varargin2(varargin, {'Ideal'});

    varargin = read_varargin(varargin, {'Zeta'}, {[]});
    varargin = read_varargin(varargin, {'Temperature'}, {[]});
    varargin = read_varargin(varargin, {'Salinity'}, {[]});
    varargin = read_varargin(varargin, {'U'}, {[]});
    varargin = read_varargin(varargin, {'V'}, {[]});
    varargin = read_varargin(varargin, {'Ua'}, {[]});
    varargin = read_varargin(varargin, {'Va'}, {[]});
    varargin = read_varargin(varargin, {'Hyw'}, {[]});
    varargin = read_varargin(varargin, {'Weight_node'}, {[]});
    varargin = read_varargin(varargin, {'Weight_cell'}, {[]});

    Ttimes = Mdatetime(time);
    Time = Ttimes.datenumC;
    nt = length(Time);
    [time, Itime, Itime2, Times] = convert_fvcom_time(Time, Ideal);

    if length(Weight_node(:)) == fn.node
        Weight_node = repmat(Weight_node(:), 1, nt);
    end
    if length(Weight_cell(:)) == fn.nele
        Weight_cell = repmat(Weight_cell(:), 1, nt);
    end

    dzc = -diff(fn.siglevc, 1, 2);
    if isempty(Ua) && ~isempty(U)
        for it = 1 : nt
            Ua(:,it) = sum(U(:,:,it).*dzc, 2);
        end
    end
    if isempty(Va) && ~isempty(V)
        for it = 1 : nt
            Va(:,it) = sum(V(:,:,it).*dzc, 2);
        end
    end
    %=====================================================================================================
    % Write nc file
    %=====================================================================================================

    %=====================================================================================================
    % write the nc documnet
    %=====================================================================================================
    nc_create_empty(fout);
    %=====================================================================================================
    % Global Attributes
    %=====================================================================================================

    OPT.title                  = 'nscs';
    OPT.institution            = 'Ocean University of China';
    OPT.source                 = 'FVCOM_5.0';
    OPT.history                = 'model started at: 10/28/2020   09:26';
    OPT.references             = 'http://fvcom.smast.umassd.edu, http://codfish.smast.umassd.edu';
    OPT.Conventions            = 'CF-1.0';
    OPT.CoordinateSystem       = 'GeoReferenced';
    OPT.CoordinateProjection   = 'none';

    nc_attput(fout, nc_global, 'title'                 , OPT.title);
    nc_attput(fout, nc_global, 'institution'           , OPT.institution);
    nc_attput(fout, nc_global, 'source'                , OPT.source);
    nc_attput(fout, nc_global, 'history'               , OPT.history);
    nc_attput(fout, nc_global, 'references'            , OPT.references);
    nc_attput(fout, nc_global, 'Conventions'           , OPT.Conventions);
    nc_attput(fout, nc_global, 'CoordinateSystem'      , OPT.CoordinateSystem);
    nc_attput(fout, nc_global, 'CoordinateProjection'  , OPT.CoordinateProjection);

    %=====================================================================================================
    % Dimensions
    %=====================================================================================================

    nc_add_dimension(fout, 'nele',   fn.nele);
    nc_add_dimension(fout, 'node',   fn.node);
    nc_add_dimension(fout, 'siglay', fn.kbm1);
    nc_add_dimension(fout, 'siglev', fn.kb);
    nc_add_dimension(fout, 'three',  3);
    nc_add_dimension(fout, 'time',   0);
    nc_add_dimension(fout, 'DateStrLen', 26)

    % x
    varstruct.Name = 'x';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'x', 'long_name', 'nodal x-coordinate');
    nc_attput(fout, 'x', 'units', 'meters');

    % y
    varstruct.Name = 'y';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'y', 'long_name', 'nodal y-coordinate');
    nc_attput(fout, 'y', 'units', 'meters');

    % xc
    varstruct.Name = 'xc';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'xc', 'long_name', 'zonal x-coordinate');
    nc_attput(fout, 'xc', 'units', 'meters');

    % yc
    varstruct.Name = 'yc';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'yc', 'long_name', 'zonal y-coordinate');
    nc_attput(fout, 'yc', 'units', 'meters');

    % nv
    varstruct.Name = 'nv';
    varstruct.Datatype = 'int';
    varstruct.Dimension = {'three','nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'nv', 'long_name', 'nodes surrounding element');

    % lon
    varstruct.Name = 'lon';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'lon', 'long_name', 'nodal longitude');
    nc_attput(fout, 'lon', 'standard_name', 'longitude');
    nc_attput(fout, 'lon', 'units', 'degrees_east');

    % lat
    varstruct.Name = 'lat';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'lat', 'long_name', 'nodal latitude');
    nc_attput(fout, 'lat', 'standard_name', 'latitude');
    nc_attput(fout, 'lat', 'units', 'degrees_north');

    % lonc
    varstruct.Name = 'lonc';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'lonc', 'long_name', 'zonal longitude');
    nc_attput(fout, 'lonc', 'standard_name', 'longitude');
    nc_attput(fout, 'lonc', 'units', 'degrees_east');

    % latc
    varstruct.Name = 'latc';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'latc', 'long_name', 'zonal latitude');
    nc_attput(fout, 'latc', 'standard_name', 'latitude');
    nc_attput(fout, 'latc', 'units', 'degrees_north');

    % siglay
    varstruct.Name = 'siglay';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'siglay','node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'siglay', 'long_name', 'Sigma Layers');
    nc_attput(fout, 'siglay', 'standard_name', 'ocean_sigma/general_coordinate');
    nc_attput(fout, 'siglay', 'positive', 'up');
    nc_attput(fout, 'siglay', 'valid_min', '-1.f');
    nc_attput(fout, 'siglay', 'valid_max', '0.f ');
    nc_attput(fout, 'siglay', 'formula_terms', 'sigma: siglay eta: zeta depth: h');

    % siglev
    varstruct.Name = 'siglev';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'siglev','node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'siglev', 'long_name', 'Sigma levels');
    nc_attput(fout, 'siglev', 'standard_name', 'ocean_sigma/general_coordinate');
    nc_attput(fout, 'siglev', 'positive', 'up');
    nc_attput(fout, 'siglev', 'valid_min', '-1.f');
    nc_attput(fout, 'siglev', 'valid_max', '0.f' );
    nc_attput(fout, 'siglev', 'formula_terms', 'sigma: siglay eta: zeta depth: h');

    % siglay_center
    varstruct.Name = 'siglay_center';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'siglay','nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'siglay_center', 'long_name', 'Sigma Layers');
    nc_attput(fout, 'siglay_center', 'standard_name', 'ocean_sigma/general_coordinate');
    nc_attput(fout, 'siglay_center', 'positive', 'up');
    nc_attput(fout, 'siglay_center', 'valid_min', '-1.f');
    nc_attput(fout, 'siglay_center', 'valid_max', '0.f ');
    nc_attput(fout, 'siglay_center', 'formula_terms', 'sigma: siglay eta: zeta depth: h');

    % siglev_center
    varstruct.Name = 'siglev_center';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'siglev','nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'siglev_center', 'long_name', 'Sigma levels');
    nc_attput(fout, 'siglev_center', 'standard_name', 'ocean_sigma/general_coordinate');
    nc_attput(fout, 'siglev_center', 'positive', 'up');
    nc_attput(fout, 'siglev_center', 'valid_min', '-1.f');
    nc_attput(fout, 'siglev_center', 'valid_max', '0.f' );
    nc_attput(fout, 'siglev_center', 'formula_terms', 'sigma: siglay eta: zeta depth: h');

    % h
    varstruct.Name = 'h';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'node'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'h', 'long_name', 'Bathymetry');
    nc_attput(fout, 'h', 'standard_name', 'sea_floor_depth_below_geoid');
    nc_attput(fout, 'h', 'units', 'm');
    nc_attput(fout, 'h', 'positive', 'down');
    nc_attput(fout, 'h', 'grid', 'Bathymetry_Mesh');
    nc_attput(fout, 'h', 'coordinates', 'lat lon');
    nc_attput(fout, 'h', 'type', 'data');

    % h_center
    varstruct.Name = 'h_center';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'nele'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'h_center', 'long_name', 'Bathymetry');
    nc_attput(fout, 'h_center', 'standard_name', 'sea_floor_depth_below_geoid');
    nc_attput(fout, 'h_center', 'units', 'm');
    nc_attput(fout, 'h_center', 'positive', 'down');
    nc_attput(fout, 'h_center', 'grid', 'Bathymetry_Mesh');
    nc_attput(fout, 'h_center', 'coordinates', 'latc lonc');
    nc_attput(fout, 'h_center', 'type', 'data');

    % time
    varstruct.Name = 'time';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'time'};
    nc_addvar(fout,varstruct);
    nc_attput(fout, 'time' , 'long_name' , 'time');
    nc_attput(fout, 'time' , 'units' , 'days since 1858-11-17 00:00:00');
    nc_attput(fout, 'time' , 'format' , 'modified julian day(MJD)');
    nc_attput(fout, 'time' , 'time_zone' , 'UTC');

    % Itime
    varstruct.Name = 'Itime';
    varstruct.Datatype = 'int';
    varstruct.Dimension = {'time'};
    nc_addvar(fout,varstruct);
    nc_attput(fout, 'Itime' , 'units' , 'days since 1858-11-17 00:00:00');
    nc_attput(fout, 'Itime' , 'format' , 'modified julian day(MJD)');
    nc_attput(fout, 'Itime' , 'time_zone' , 'UTC');

    % Itime2
    varstruct.Name = 'Itime2';
    varstruct.Datatype = 'int';
    varstruct.Dimension = {'time'};
    nc_addvar(fout,varstruct);
    nc_attput(fout, 'Itime2' , 'units' , 'msec since 00:00:00');
    nc_attput(fout, 'Itime2' , 'time_zone' , 'UTC');

    % Times
    varstruct.Name = 'Times';
    varstruct.Datatype = 'char';
    varstruct.Dimension = {'time', 'DateStrLen'};
    nc_addvar(fout,varstruct);
    nc_attput(fout, 'Times' , 'time_zone' , 'UTC');

    if ~isempty(Zeta)
        % zeta
        varstruct.Name = 'zeta';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','node'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'zeta', 'long_name', 'Water Surface Elevation');
        nc_attput(fout, 'zeta', 'units', 'meters');
        nc_attput(fout, 'zeta', 'positive', 'up');
        nc_attput(fout, 'zeta', 'standard_name', 'sea_surface_elevation');
        nc_attput(fout, 'zeta', 'grid', 'SSH_Mesh');
        nc_attput(fout, 'zeta', 'coordinates', 'time lat lon');
        nc_attput(fout, 'zeta', 'type', 'data');
    end

    if isempty(U)
        % u
        varstruct.Name = 'u';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','siglay','nele'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'u', 'long_name', 'Eastward Water Velocity');
        nc_attput(fout, 'u', 'units', 'meters s-1');
        nc_attput(fout, 'u', 'grid', 'fvcom_grid');
        nc_attput(fout, 'u', 'type', 'data');
    end

    if isempty(V)
        % v
        varstruct.Name = 'v';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','siglay','nele'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'v', 'long_name', 'Northward Water Velocity');
        nc_attput(fout, 'v', 'units', 'meters s-1');
        nc_attput(fout, 'v', 'grid', 'fvcom_grid');
        nc_attput(fout, 'v', 'type', 'data');
    end

    if isempty(Ua)
        % ua
        varstruct.Name = 'ua';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','nele'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'ua', 'long_name', 'Vertically Averaged x-velocity');
        nc_attput(fout, 'ua', 'units', 'meters s-1');
        nc_attput(fout, 'ua', 'grid', 'fvcom_grid');
        nc_attput(fout, 'ua', 'type', 'data');
    end

    if isempty(Va)
        % va
        varstruct.Name = 'va';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','nele'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'va', 'long_name', 'Vertically Averaged y-velocity');
        nc_attput(fout, 'va', 'units', 'meters s-1');
        nc_attput(fout, 'va', 'grid', 'fvcom_grid');
        nc_attput(fout, 'va', 'type', 'data');
    end

    if ~isempty(Temperature)
        % temperature
        varstruct.Name = 'temp';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','siglay','node'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'temp', 'long_name', 'temperature');
        nc_attput(fout, 'temp', 'standard_name','sea_water_temperature');
        nc_attput(fout, 'temp', 'units', 'degrees_C');
        nc_attput(fout, 'temp', 'grid', 'fvcom_grid');
        nc_attput(fout, 'temp', 'coordinates','time siglay lat lon');
        nc_attput(fout, 'temp', 'type', 'data');
    end

    if ~isempty(Salinity)
        % salinity
        varstruct.Name = 'salinity';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','siglay','node'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'salinity', 'long_name', 'salinity');
        nc_attput(fout, 'salinity', 'standard_name','sea_water_salinity');
        nc_attput(fout, 'salinity', 'units', '1e-3');
        nc_attput(fout, 'salinity', 'grid', 'fvcom_grid');
        nc_attput(fout, 'salinity', 'coordinates','time siglay lat lon');
        nc_attput(fout, 'salinity', 'type', 'data');
    end

    if ~isempty(Hyw)
        % hyw
        varstruct.Name = 'hyw';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'time','siglev','node'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'hyw', 'long_name', 'hydro static vertical velocity');
        nc_attput(fout, 'hyw', 'units', 'm/s');
        nc_attput(fout, 'hyw', 'grid', 'fvcom_grid');
        nc_attput(fout, 'hyw', 'type', 'data');
    end

    nc_varput(fout,'x', fn.x);
    nc_varput(fout,'y', fn.y);
    nc_varput(fout,'xc', fn.xc);
    nc_varput(fout,'yc', fn.yc);
    nc_varput(fout,'nv', fn.nv');
    nc_varput(fout,'h', fn.h);
    nc_varput(fout,'lon', fn.LON);
    nc_varput(fout,'lat', fn.LAT);
    nc_varput(fout,'lonc', mean(fn.LON(fn.nv), 2));
    nc_varput(fout,'latc', mean(fn.LAT(fn.nv), 2));
    nc_varput(fout,'siglay', fn.siglay');
    nc_varput(fout,'siglev',fn.siglev');
    nc_varput(fout,'h_center', fn.hc);
    nc_varput(fout,'siglay_center', fn.siglayc');
    nc_varput(fout,'siglev_center',fn.siglevc');
    nc_varput(fout,'time', time);
    nc_varput(fout,'Itime', Itime);
    nc_varput(fout,'Itime2', Itime2);
    nc_varput(fout,'Times', Times);
    if ~isempty(Zeta)
        nc_varput(fout,'zeta', Zeta);
    end
    if ~isempty(Temperature)
        nc_varput(fout,'temp', Temperature);
    end
    if ~isempty(Salinity)
        nc_varput(fout,'salinity', Salinity);
    end
    if ~isempty(U)
        nc_varput(fout,'u', U);
    end
    if ~isempty(V)
        nc_varput(fout,'v', V);
    end
    if ~isempty(Ua)
        nc_varput(fout,'ua', Ua);
    end
    if ~isempty(Va)
        nc_varput(fout,'va', Va);
    end
    if ~isempty(Hyw)
        nc_varput(fout,'hyw', Hyw);
    end

end
