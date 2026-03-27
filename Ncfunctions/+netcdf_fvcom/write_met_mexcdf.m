function write_met_mexcdf(fout, grid, time, varargin)
    %       Write the met file for FVCOM, with mexcdf
    % =================================================================================================================
    % Parameter:
    %       fout:            output file name       || required: True  || type: string    || format: 'met.nc'
    %       grid:            fvcom or wrf met grid  || required: True  || type: struct    || format: struct
    %       time:            time                   || required: True  || type: double    || format: posix time
    %       varargin:       (Variables below can be writen in to a random order.)
    %           Variable name  | Description        | size                  | unit
    %           ------------   | ------------------ | -----------------     | ----
    %           U10             10m wind speed     (x, y, nt) / (node, nt)     m/s
    %           V10             10m wind direction (x, y, nt) / (node, nt)     m/s
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2025-11-06:     Created,    by Christmas;
    % =================================================================================================================
    % TODO:
    %       1. Not test yet;
    %       2. Support FVCOM grid;
    %       3. Add more variables;
    % =================================================================================================================
    % Example:
    %       netcdf_fvcom.write_met_mexcdf('met.nc', grid, time, ...
    %                                     'U10', U10, ...
    %                                     'V10', V10);
    % =================================================================================================================

    varargin = read_varargin2(varargin, {'Ideal'});

    varargin = read_varargin(varargin, {'U10'}, {[]});
    varargin = read_varargin(varargin, {'V10'}, {[]});

    if isfield(grid, 'lines_y')
        grid_type = 'FVCOM';
        error('Unsopported so far.')
    else
        grid_type = 'WRF';
    end

    Ttimes = Mdatetime(time);
    Time = Ttimes.datenumC;
    nt = length(Time);
    [time, Itime, Itime2, ~] = convert_fvcom_time(Time, Ideal);
    Times = Ttimes.Times;
    Times.Format = 'yyyy-MM-dd_HH:mm:ss';
    Times = char(Times);

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

    OPT.title                  = 'Meteorological Forcing File';
    OPT.institution            = 'Ocean University of China';
    OPT.source                 = 'wrf2fvcom version 0.13 (2007-07-19) (Bulk method: COARE 2.6Z)';

    nc_attput(fout, nc_global, 'title'         , OPT.title);
    nc_attput(fout, nc_global, 'institution'   , OPT.institution);
    nc_attput(fout, nc_global, 'source'        , OPT.source);

    %=====================================================================================================
    % Dimensions
    %=====================================================================================================


    nc_add_dimension (fout, 'south_north', len(grid.y1D));  % 纬度
    nc_add_dimension (fout, 'west_east', len(grid.x1D) );  % 经度
    nc_add_dimension (fout, 'Time', 0);
    nc_add_dimension (fout, 'DateStrLen', 19)

    % XLAT
    varstruct.Name = 'XLAT';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'south_north' , 'west_east'};
    nc_addvar(fout, varstruct);
    nc_attput(fout , 'XLAT', 'description', 'LATITUDE, SOUTH IS NEGATIVE');
    nc_attput(fout, 'XLAT', 'units', 'degree_north');

    % XLAT
    varstruct.Name = 'XLONG';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'south_north' , 'west_east'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'XLONG', 'description', 'LONGITUDE, WEST IS NEGATIVE');
    nc_attput(fout, 'XLONG', 'units', 'degree_east');

    % time
    varstruct.Name = 'time';
    varstruct.Datatype = 'single';
    varstruct.Dimension = {'Time'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'time' , 'long_name' , 'time');
    nc_attput(fout, 'time' , 'units' , 'days since 1858-11-17 00:00:00');
    nc_attput(fout, 'time' , 'format' , 'modified julian day (MJD)');
    nc_attput(fout, 'time' , 'time_zone' , 'UTC');

    % Times
    varstruct.Name = 'Times';
    varstruct.Datatype = 'char';
    varstruct.Dimension = {'Time', 'DateStrLen'};
    nc_addvar(fout, varstruct);
    nc_attput(fout, 'Times' , 'description' , 'GMT time');

    % Variable U10
    if ~isempty(U10)
        varstruct.Name = 'U10';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'Time' ,'south_north','west_east'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'U10', 'description', 'U at 10 M');
        nc_attput(fout, 'U10', 'units', 'm s-1');
        nc_attput(fout, 'U10', 'coordinates', 'XLONG XLAT');
    end

    % Variable V10
    if ~isempty(V10)
        varstruct.Name = 'V10';
        varstruct.Datatype = 'single';
        varstruct.Dimension = {'Time' ,'south_north','west_east'};
        nc_addvar(fout, varstruct);
        nc_attput(fout, 'V10', 'description', 'V at 10 M');
        nc_attput(fout, 'V10', 'units', 'm s-1');
        nc_attput(fout, 'V10', 'coordinates', 'XLONG XLAT');
    end

    nc_put_var(fout, 'XLAT', grid.y);
    nc_put_var(fout, 'XLONG', grid.x);

    nc_put_var(fout, 'time', time);
    nc_put_var(fout, 'Times', Times');

    if ~isempty(U10)
        nc_put_var(fout, 'U10', U10);
    end
    if ~isempty(V10)
        nc_put_var(fout, 'V10', V10);
    end

end
