function varargout  = ncread_lltd_v(ncfile,lon_vname,lat_vname,dep_vname,time_vname,depth_range,time_range,varargin)
    % read lon,lat,time from netcdf file

    varargout{1} = ncread(ncfile,lon_vname);
    varargout{2} = ncread(ncfile,lat_vname);
    varargout{3} = ncread(ncfile,dep_vname);
    time = ncdateread(ncfile,time_vname); 
    varargout{4} = time(time_range(1):time_range(2));

    for num = 1:length(varargin)
        varargout{num+4} = squeeze(ncread(ncfile,varargin{num},[1 1 depth_range(1) time_range(1)],[Inf Inf depth_range(2) time_range(2)]));
    end
end