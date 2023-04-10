function varargout = region_cutout(lon_range,lat_range,varargin)
% REGION_CUTOUT  Cut out a region from a map

lon = varargin{1};
lat = varargin{2};

Fx = find(lon<lon_range(1) | lon>lon_range(2));
lon(Fx) = [];
varargout{1} = lon;

for num = 3:length(varargin)
    tm{num-2} = varargin{num};
    tm{num-2}(Fx,:,:) = [];
end

Fy = find(lat<lat_range(1) | lat>lat_range(2));
lat(Fy) = [];
varargout{2} = lat;

for num = 3:length(varargin)
    tm{num-2}(:,Fy,:) = [];
    varargout{num} = tm{num-2};
end

clear Fx Fy

end