load coastlines.mat
[lon, lat] = reducem(coastlon, coastlat, 5);  % decrease
[lon1, lat1] = interpm(coastlon, coastlat, 0.01);  % augment