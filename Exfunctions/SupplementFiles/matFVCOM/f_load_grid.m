%==========================================================================
% Generate all the information of FVCOM grid
% Based on four variables:
%     --- x,      x coordinate on node, (node)
%     --- y,      y coordinate on node, (node)
%     --- nv,     id of nodes around cells, (nele, 3)
%     --- h,      h coordinate on node, (node), positive for water
%     --- siglay, sigma layer on node 0~-1, (node, kbm1)
%      OR
%     --- fvcom NetCDF file path and name. (At least there should be x, y, nv)
%
%     (optional)
%     --- 'rotate', theta  (angle of rotate the (x,y), positive for anti-clockwise)
% Usage:
%     f = f_load_grid(fnc, 'xy');
%      OR
%     f = f_load_grid(x, y, nv);
%      OR
%     f = f_load_grid(x, y, nv, h);
%      OR
%     f = f_load_grid(x, y, nv, h, siglay);
%
% In fgrid
%   nv   --- node around cell
%   nbve --- cell around node
%   nbe  --- cell around cell
%   nbsn --- node around node
%
% Siqi Li, SMAST
% 2021-03-22
%
% Updates:
% 2021-06-19  Siqi Li  Added the function of rotating the (x,y)
% 2022-10-16  Siqi Li  Support grd.dat, 2dm, and nc
% 2024-02-27  Siqi Li  Added nv direction adjustment for grd and 2dm
%==========================================================================
function fgrid = f_load_grid(varargin)

varargin = read_varargin(varargin, {'Rotate', 'Scale'}, {0, 1});
varargin = read_varargin(varargin, {'Coordinate'}, {'auto'});
varargin = read_varargin(varargin, {'MaxLon'}, {180});
varargin = read_varargin2(varargin, {'Global'});
varargin = read_varargin2(varargin, {'Nodisp'});
varargin = read_varargin2(varargin, {'PLOT'});


fgrid.Scale = Scale;

% fgrid.type = 'FVCOM';

switch class(varargin{1})
    case {'char', 'string'}
        if endsWith(varargin{1}, '.nc')
        fnc = varargin{1};

        if strcmp(Coordinate, 'auto') %#ok<*NODEF>
            if nc_Var_exist(fnc, 'x') && any(minmax(minmax(double(ncread(fnc, 'x')))))
                Coordinate = 'xy';
            else
                Coordinate = 'geo';
            end
        end
        
        switch lower(Coordinate)
            case 'xy'
                x = double(ncread(fnc, 'x'));
                y = double(ncread(fnc, 'y'));
                LON = double(ncread(fnc, 'lon'));
                LAT = double(ncread(fnc, 'lat'));

                fgrid.LON = LON;
                fgrid.LAT = LAT;
                nv = ncread(fnc, 'nv');
            case 'geo'
                if nc_Var_exist(fnc, 'nv')
                    x = double(ncread(fnc, 'lon'));
                    y = double(ncread(fnc, 'lat'));
                    nv = ncread(fnc, 'nv');
                elseif nc_Var_exist(fnc, 'tri')
                    x = double(ncread(fnc, 'longitude'));
                    y = double(ncread(fnc, 'latitude'));
                    nv = ncread(fnc, 'tri')';
                end

                LON = x;
                LAT = y;
                fgrid.LON = LON;
                fgrid.LAT = LAT;
            otherwise
                error('Unknown coordinate. Choose: xy or geo or ww3')
        end

        if nc_Var_exist(fnc, 'h')
            h = double(ncread(fnc, 'h'));
        else
            h = nan*x;
        end
        if nc_Var_exist(fnc, 'siglay')
            siglay = double(ncread(fnc, 'siglay'));
        else
            siglay = nan;
        end
        
%         n = 2;
        elseif endsWith(varargin{1}, 'grd.dat')
            % varargin{1}
            [x, y, nv, h] = read_grd(varargin{1});
            nv = nv(:,[1 3 2]);
            LON = x;
            LAT = y;
            fgrid.LON = LON;
            fgrid.LAT = LAT;
            siglay = nan;
        elseif endsWith(varargin{1}, '.2dm')
            [x, y, nv, h, ns] = read_2dm(varargin{1});
            nv = nv(:,[1 3 2]);
            LON = x;
            LAT = y;
            fgrid.LON = LON;
            fgrid.LAT = LAT;
            fgrid.ns = ns;
            siglay = nan;
        elseif endsWith(varargin{1}, '.msh')
            [x, y, nv, h, ns] = read_msh(varargin{1});
            nv = nv(:,[1 3 2]);
            LON = x;
            LAT = y;
            fgrid.LON = LON;
            fgrid.LAT = LAT;
            fgrid.ns = ns;
            siglay = nan;
        elseif endsWith(varargin{1}, '.14')
            [x, y, nv, h, ob, lb] = read_sms_grd(varargin{1});
            nv = nv(:,[1 3 2]);
            LON = x;
            LAT = y;
            fgrid.LON = LON;
            fgrid.LAT = LAT;
            fgrid.ns = [ob; lb];
            siglay = nan;
        elseif endsWith(varargin{1}, '.mesh')
            [x, y, nv, h, bounds] = read_mike_mesh(varargin{1});
            nv = nv(:,[1 3 2]);
            LON = x;
            LAT = y;
            fgrid.LON = LON;
            fgrid.LAT = LAT;
            fgrid.ns = bounds';
            siglay = nan;
        else
            error(['Unknown file format:' varargin{1}])
        end

    case {'single', 'double'}
%         n = 1;
%         while isa(varargin{n}, 'single') || isa(varargin{n}, 'double')
%             n = n + 1;
%         end
        % n = nargin;
        n = length(varargin);
        x = double(varargin{1}(:));
        y = double(varargin{2}(:));
        nv = varargin{3};
        LON = x;
        LAT = y;
        fgrid.LON = LON;
        fgrid.LAT = LAT;
        if n>3
            h = double(varargin{4}(:));
        else
            h = nan*x;
        end
        if n>4
            siglay = double(varargin{5});
        else
            siglay = nan;
        end 
        
    otherwise
        error('Input should be either nc file or x, y, nv(, h, siglay)')
end
   
% Read the rest parameters, if any
% theta = 0;
% i = n + 1;
% while i<nargin
%     switch lower(varargin{i})
%         case 'rotate'
%             theta = varargin{i+1};
%     end
%     i = i + 2;
% end

% theta = -theta;

% Rotate the (x,y), if needed
[x, y] = rotate_theta(x, y, Rotate);
fgrid.rotate = Rotate;

% Scaling the x, y
x = x * Scale;
y = y * Scale;

% Calculate the projection parameters
if isfield(fgrid, 'LON')
    fgrid.proj.xy2lon = scatteredInterpolant(x, y, LON);
    fgrid.proj.xy2lat = scatteredInterpolant(x, y, LAT);
    fgrid.proj.geo2x = scatteredInterpolant(LON, LAT, x);
    fgrid.proj.geo2y = scatteredInterpolant(LON, LAT, y);
end

% Dimensions
fgrid.node = length(x);
fgrid.nele = size(nv, 1);


% Check if the grid is 'Global' or 'Regional'
if isempty(Global)
    fgrid.type = check_grid_type(x, y);
else
    fgrid.type = 'Global';
end

if strcmp(fgrid.type, 'Global') || strcmpi(Coordinate, 'Geo')
    x = calc_lon_same([MaxLon-360 MaxLon], x);
end
fgrid.MaxLon = MaxLon;

% Node variables
fgrid.x = x;
fgrid.y = y;

% Cell variables
fgrid.nv = nv;
% [~, fgrid.nv] = f_calc_grid_direction(fgrid);
% fgrid.xc = mean(x(nv), 2);
% fgrid.yc = mean(y(nv), 2);
[fgrid.xc, fgrid.yc] = calc_xcyc(x, y, nv, fgrid.type);
if strcmp(fgrid.type, 'Global')
    fgrid.xc = calc_lon_same(fgrid.x, fgrid.xc);
end



% nv (node id around each cell)
% We already have it.
% nbve (cell id around each node), for cell2node interpolation
fgrid.nbve = f_calc_nbve(fgrid);
% nbe (cell id around each cell), for cell-variable smooth
fgrid.nbe = f_calc_nbe(fgrid);
% nbsn (node id around each node), for node-variable smooth
fgrid.nbsn = f_calc_nbsn(fgrid);  


% Boundary and all lines
[fgrid.bdy_x, fgrid.bdy_y, fgrid.lines_x, fgrid.lines_y, fgrid.bdy, fgrid.lines] = f_calc_boundary(fgrid, 'MaxLon', MaxLon);


%------------Bathymetry---------------------------------------
% if ~isnan(h)
    fgrid.h = h;
    fgrid.hc = mean(h(nv), 2);
% end



%------------Sigma---------------------------------------
if ~isnan(siglay)
    fgrid.kbm1 = size(siglay, 2);
    fgrid.kb = fgrid.kbm1 + 1;
    
    
    % Node
    fgrid.siglay = siglay;
    fgrid.siglev = zeros(fgrid.node, fgrid.kb);
    for i = 2 : fgrid.kb
        fgrid.siglev(:, i) = fgrid.siglay(:, i-1)*2 - fgrid.siglev(:, i-1);
    end
%     if abs((min(fgrid.siglev(:,end))+1)*(max(fgrid.siglev(:,end))+1))>1e-5
%         error('Make sure your input is SIGLAY, rather than SIGLEV')
%     end
    
    % Cell
    fgrid.siglayc=squeeze(mean(reshape(siglay(nv,:), fgrid.nele, 3, fgrid.kbm1), 2));
    fgrid.siglevc = zeros(fgrid.nele, fgrid.kb);
    for i = 2 : fgrid.kb
        fgrid.siglevc(:, i) = fgrid.siglayc(:, i-1)*2 - fgrid.siglevc(:, i-1);
    end
    
end

%------------Depth of each layer and level---------------------------------
% if ~isnan(h) & ~isnan(siglay)
if ~isnan(siglay)    
    
    % Node
    fgrid.deplay = -fgrid.siglay .* repmat(fgrid.h, 1, fgrid.kbm1);
    fgrid.deplev = -fgrid.siglev .* repmat(fgrid.h, 1, fgrid.kb);
    
    % Cell
    fgrid.deplayc = -fgrid.siglayc .* repmat(fgrid.hc, 1, fgrid.kbm1);
    fgrid.deplevc = -fgrid.siglevc .* repmat(fgrid.hc, 1, fgrid.kb);
    
end


if isempty(Nodisp)
    disp(' ')
    disp('------------------------------------------------')
    disp('FVCOM grid:')
    disp(['   Dimension :  '])
    disp(['              node    : ' num2str(fgrid.node)])
    disp(['              nele    : ' num2str(fgrid.nele)])
    if isfield(fgrid, 'kbm1')
        disp(['              nsiglay : ' num2str(fgrid.kbm1)])
    end
    disp(['   X / Longitude : ' num2str(min(fgrid.x(:))) ' ~ ' num2str(max(fgrid.x(:)))])
    disp(['   Y / Latitude  : ' num2str(min(fgrid.y(:))) ' ~ ' num2str(max(fgrid.y(:)))])
    if isfield(fgrid, 'h')
        disp(['   Depth         : ' num2str(min(fgrid.h(:))) ' ~ ' num2str(max(fgrid.h(:)))])
    end
    disp('------------------------------------------------')
    disp(' ')
end

if ~isempty(PLOT)
    fgrid.PLOT.range           = @(varargin) f_2d_range(fgrid, varargin{:});
    fgrid.PLOT.mesh            = @(varargin) f_2d_mesh(fgrid, varargin{:});
    fgrid.PLOT.coast           = @(varargin) f_2d_coast(fgrid, varargin{:});
    fgrid.PLOT.image           = @(varargin) f_2d_image(fgrid, varargin{:});
    fgrid.PLOT.contour         = @(varargin) f_2d_contour(fgrid, varargin{:});
    fgrid.PLOT.boundary        = @(varargin) f_2d_boundary(fgrid, varargin{:});
    fgrid.PLOT.mask_boundary   = @(varargin) f_2d_mask_boundary(fgrid, varargin{:});
    fgrid.PLOT.lonlat          = @(varargin) f_2d_lonlat(fgrid, varargin{:});
    fgrid.PLOT.cell            = @(varargin) f_2d_cell(fgrid, varargin{:});
end

end

function status = nc_Var_exist(fnc, varname)

status = 0;

ncid = netcdf.open(fnc, 'NOWRITE');

[~,nvars] = netcdf.inq(ncid);
for i = 1 : nvars
    if strcmp(varname, netcdf.inqVar(ncid,i-1))
        status = 1;
        break
    end
end

netcdf.close(ncid);

end

