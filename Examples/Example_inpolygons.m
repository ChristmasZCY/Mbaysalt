clm

SHP = '/Users/christmas/Downloads/11、中国七大地理分区shp/shp/华南.shp';
S = shaperead (SHP) ; 
x_shp=[S(:).X];
y_shp=[S(:).Y];

[Xdst, Ydst, bdy] = zoom_ploygon(x_shp, y_shp,"figOn",3);  % 外扩范围

[GridStruct, VarStruct, Ttimes] = c_load_model('/Users/christmas/Desktop/exampleNC/wave_5.nc','Coordinate','geo');

LON = GridStruct.x;
LAT = GridStruct.y;
isin=inpolygons (LON, LAT, Xdst, Ydst);

pre_real = VarStruct.swh(:,:,1);
pre_real(~isin)=NaN;

figure
contourf(pre_real')