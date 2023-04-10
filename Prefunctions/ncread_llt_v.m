function varargout  = ncread_llt_v(ncfile,lon_vname,lat_vname,time_vname,range,varargin)
    % read lon,lat,time from netcdf file

    varargout{1} = ncread(ncfile,lon_vname);
    varargout{2} = ncread(ncfile,lat_vname);
    time = ncdateread(ncfile,time_vname); 
    varargout{3} = time(range(1):range(2));

    for num = 1:length(varargin)
        varargout{num+3} = ncread(ncfile,varargin{num},[1 1 range(1)],[Inf Inf range(2)]);
    end
end