function [lon,lat,varargout] = region_cutout(lon_range,lat_range,lon,lat,varargin)
    %       Cut out a region from a map
    % =================================================================================================================
    % Parameter:
    %       lon: longitude               || required: True || type: double || format: -180-180
    %       varargin{n}: value to change || required: True || type: char   || format: martix
    %       Lon: changed longitude       || required: True || type: double || format: martix
    %       varargout{n}: changed value  || required: True || type: double || format: martix
    % =================================================================================================================
    % Example:
    %       [lon,lat,U10] = region_cutout(lon_range,lat_range,lon,lat,U10);
    %       [lon,lat,U10,V10] = region_cutout(lon_range,lat_range,lon,lat,U10,V10);
    % =================================================================================================================

% REGION_CUTOUT  Cut out a region from a map

    size_lon = size(lon);
    size_lat = size(lat);
    if min(size_lon) ~= 1 || min(size_lat) ~= 1
        error('lon and lat must be 1D array')
    end

    Fx = find(lon<lon_range(1) | lon>lon_range(end));
    lon(Fx) = [];

    for num = 1:length(varargin)
        tm{num} = varargin{num};
        tm{num}(Fx,:,:) = [];
    end

    Fy = find(lat<lat_range(1) | lat>lat_range(end));
    lat(Fy) = [];

    for num = 1:length(varargin)
        tm{num}(:,Fy,:) = [];
        varargout{num} = tm{num};
    end

    clear Fx Fy

end
