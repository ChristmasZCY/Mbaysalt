function wrnc_current(varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to write the current data to the netcdf file
    % =================================================================================================================
    % select function:
    %       netcdf_fvcom.wrnc_current_uvw(ncid,Lon,Lat,Depth,time,U,V,W,start_date_gb)
    %       netcdf_fvcom.wrnc_current_uv(ncid,Lon,Lat,Depth,time,U,V,start_date_gb)
    % =================================================================================================================
    % example:
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Depth,time,U,V,W,start_date_gb)
    %       netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Depth,time,U,V,start_date_gb)
    % =================================================================================================================

   if nargin == 9
        netcdf_fvcom.wrnc_current_uvw(varargin{:})
    elseif nargin == 8
        netcdf_fvcom.wrnc_current_uv(varargin{:})
    else
        error('the number of input arguments is not correct')
    end

end