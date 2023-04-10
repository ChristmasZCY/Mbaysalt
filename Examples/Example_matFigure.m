Lon           =  [0:1:360];
Lat           =  [-90:1:90];
[Lat,Lon] = meshgrid(Lat,Lon);

w = w_load_grid(Lon, Lat,'MaxLon',360);
figure
hold on
w_2d_image(w, tempE)
mf_save('123.png')
% saveas(gcf,'123.png')