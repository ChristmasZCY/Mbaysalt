clm

SHP = 'D: \Maps\China2\china.shp';
ma = shaperead (SHP) ; 
lon = [120:150];
lat = [0:30];
x_gz=[ma(:).X];
y_gz=[ma(:).Y];
[LON, LAT]=meshgrid (lon, lat) ;
isin=inpolygons (LON, LAT, x_gz,y_gz);
pre_real(~isin)=NaN;
