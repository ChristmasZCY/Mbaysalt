clm
load topo topomap1
x = 0:359;
y = -89:90;
[X1,Y1] = meshgrid(x,y);
x1 = 0:0.1:360;
y1 = -89:0.1:90;
[X,Y]=meshgrid(x1,y1);
topo_new = interp2(X1,Y1,topo,X,Y);
[x,y,z] = sphere(100);         % create a sphere
s = surface(x,y,z);            % plot spherical surface
s.FaceColor = 'texturemap';    % use texture mapping
s.CData = topo_new;            % set color data to topographic data
s.EdgeColor = 'none';          % remove edges
s.FaceLighting = 'gouraud';    % preferred lighting for curved surfaces
s.SpecularStrength = 0.4;      % change the strength of the reflected light
colormap(topomap1)
% light('Position',[1 0 1])     % add a light
axis square off                 % set axis to square and remove axis
view([30,20])                   % set the viewing angle
