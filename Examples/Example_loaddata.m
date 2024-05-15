

clm
loaddata('/Users/christmas/Desktop/exampleNC/20231225_gfvcom_uv.nc')
c = Mgrid(G);
clf
hold on
c.draw.range
c.draw.image(V.uv_spd(:,1))
c.draw.mesh
axis tight
c.draw.coast('xlims',[-180 180],'ylims',[-90 90],'Resolution','c','Coordinate','geo')


