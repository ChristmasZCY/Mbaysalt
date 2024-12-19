function convert_shp2cst(shpfile, cstfile)
    %       Convert shapefile to cst file, contains merging polygons.
    % =================================================================================================================
    % Parameters:
    %       shpfile:  shapefile filepath                || required: True  || type: filename  || format: 'lines.shp'
    %       cstfile:  cst filepath                      || required: True  || type: filename  || format: 'lines.cst'
    %       varargin: (optional)
    %           None
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-10-30:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       convert_shp2cst('lines.shp', 'lines.cst');
    % =================================================================================================================

    GT = readgeotable(shpfile);
    T = geotable2table(GT, ["Lat","Lon"]);

    [lat,lon] = polyjoin(T.Lat, T.Lon);  % convert cell arrays to vector form.
    [LAT, LON] = polymerge(lat,lon);  % merge the polygons. such that the first and last points are the same.
    % plot(LON,LAT)

    write_cst(cstfile, LON, LAT);

end
