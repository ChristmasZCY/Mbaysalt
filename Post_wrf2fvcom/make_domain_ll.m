function Dgrid = make_domain_ll(fin,varargin)
    % =================================================================================================================
    % discription:
    %       Get domain longitude and latitude from wrf2fvcom file, and make a new grid file for structured grid
    % =================================================================================================================
    % parameter:
    %       fin:             wrf2fvcom file          || required: True || type: char   || format: 'wrf2fvcom.nc'
    %       varargin:        optional parameters      
    % =================================================================================================================
    % example:
    %       Dgrid = make_domain_ll('wrf2fvcom.nc');
    % =================================================================================================================
    
    Wgrid = w_load_grid(fin);
    d.lon(1) = max(Wgrid.x(1,:));
    d.lon(2) = min(Wgrid.x(end,:));
    d.lon(3) = mean(diff(Wgrid.x,1),'all');
    d.lat(1) = max(Wgrid.y(:,1));
    d.lat(2) = min(Wgrid.y(:,end));
    d.lat(3) = mean(diff(Wgrid.y',1),'all');

    Dgrid.lon_ori = Wgrid.x;
    Dgrid.lat_ori = Wgrid.y;
    Dgrid.lon_dst = (d.lon(1):mean([d.lon(3),d.lat(3)]):d.lon(2))';
    Dgrid.lat_dst = (d.lat(1):d.lat(3):d.lat(2))';
end
