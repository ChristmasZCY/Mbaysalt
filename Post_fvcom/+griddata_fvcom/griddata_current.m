function varargout=griddata_current(varargin)
    % =================================================================================================================
    % discription:
    %       griddata_current is used to griddata the current data from the triangle grid to the rectangle grid
    % =================================================================================================================
    % select function:
    %       [U,V,W]=griddata_current_uvw(lon,lat,siglay,time,u,v,w,slon,slat)
    %       [U,V]=griddata_current_uv(lon,lat,siglay,time,u,v,slon,slat)
    % =================================================================================================================
    % example:
    %       [U,V,W]=griddata_current(lon,lat,siglay,time,u,v,w,slon,slat)
    %       [U,V]=griddata_current(lon,lat,siglay,time,u,v,slon,slat)
    % =================================================================================================================
    
    if nargin==9
        [varargout{1:nargout}]=griddata_current_uvw(varargin{:});
    elseif nargin==8
        [varargout{1:nargout}]=griddata_current_uv(varargin{:});
    else
        error('griddata_current: wrong number of input arguments')
    end

end