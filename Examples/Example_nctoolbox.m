
%% NetCDF, OPeNDAP, HDF5, GRIB, GRIB2, HDF4等15种文件都可以参考如下
grbin = '/Users/christmas/Desktop/exampleNC/gfswave.t00z.arctic.9km.f000.grib2';
ds = ncdataset(grbin);

ds.variables  % 显示ds数据源中有那些变量
ds.size('u-component_of_wind_surface')  % 显示ds数据源中的温度变量形状，相当于显示某一特定变量的形状属性
u = ds.data('u-component_of_wind_surface');  % 读取
lon = double(ds.data('lon')); %x.data(x.variables{1})
lat = double(ds.data('lat'));

firstIdx = [1 1 1 1]; lastIdx = [1 10 10]; 
u1 = ds.data('u-component_of_wind_surface', firstIdx, lastIdx);

ds.attributes
ds.attributes('u-component_of_wind_surface')
ds.axes('u-component_of_wind_surface')
