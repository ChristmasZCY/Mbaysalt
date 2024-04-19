function out = scatplot(x,y,method,radius,N,n,po,ms)
% Scatter plot with color indicating data density
%
% USAGE:
%   out = scatplot(x,y,method,radius,N,n,po,ms)
%   out = scatplot(x,y,dd)
%
% DESCRIPTION:
%   Draws a scatter plot with a colorscale 
%   representing the data density computed 
%   using three methods
%
% INPUT VARIABLES:
%   x,y - are the data points
%   method - is the method used to calculate data densities:
%       'circles' - uses circles with a determined area 
%               centered at each data point --> 使用圆圈确定的面积以每个数据点为中心
%       'squares' - uses squares with a determined area 
%               centered at each data point --> 使用具有确定面积的正方形，以每个数据点为中心
%       'voronoi' - uses voronoi cells to determin data densities --> 使用 voronoi 单元来确定数据密度
%       default method is 'voronoi'
%   radius - is the radius used for the circles or squares --> 此参数为计算数据密度的半径
%       used to calculate the data densities if
%       (Note: only used in methods 'circles' and 'squares' --> 仅用于方法为 'circles'和 'squares'时
%           default radius is sqrt((range(x)/30)^2 + (range(y)/30)^2) --> 默认半径是 sqrt((range(x)/30)^2 + (range(y)/30)^2)
%   N - is the size of the square mesh (N x N) used to  
%       filter and calculate contours --> 是用于方形网格 (N x N) 的大小，过滤并计算轮廓
%       default is 100
%   n - is the number of coeficients used in the 2-D --> 2-D运行平均过滤器中 使用的系数数量
%       running mean filter
%       default is 5
%       (Note: if n is length(2), n(2) is tjhe number of
%       of times the filter is applied) --> （注意：如果 n 是长度（2），n（2）是应用过滤器的次数百分比）
%   po - plot options:
%       0 - No plot --> 不绘图
%       1 - plots only colored data points (filtered) --> 仅绘制彩色数据点（过滤）
%       2 - plots colored data points and contours (filtered) --> 绘制彩色数据点和等高线（过滤）
%       3 - plots only colored data points (unfiltered) --> 仅绘制彩色数据点（未过滤）
%       4 - plots colored data points and contours (unfiltered) --> 绘制彩色图数据点和轮廓（未过滤）
%           default is 1
%   ms - uses this marker size for filled circles --> 数据点大小
%       default is 4
%
% OUTPUT VARIABLE:
%   out - structure array that contains the following fields:
%       dd - unfiltered data densities at (x,y)
%       ddf - filtered data densities at (x,y)
%       radius - area used in 'circles' and 'squares'
%               methods to calculate densities
%       xi - x coordenates for zi matrix 
%       yi - y coordenates for zi matrix
%       zi - unfiltered data densities at (xi,yi)
%       zif - filtered data densities at (xi,yi)
%       [c,h] = contour matrix C as described in
%           CONTOURC and a handle H to a contourgroup object
%       hs = scatter points handles
%
%Copy-Left, Alejandro Sanchez-Barba, 2005
% ===================================================================================================
% Update:
%       2024-04-16:     Added Chinese comments, by Christmas;
%       2024-04-16:     Added function range at the end of the code, because of too many range functions, by Christmas;
% ======================================================================================================

if nargin==0
    scatplotdemo
    return
end
if nargin<3 | isempty(method)
    method = 'vo';
end
if isnumeric(method)
   gsp(x,y,method,2)
   return
else
    method = method(1:2);
end
if nargin<4 | isempty(n)
    n = 5; %number of filter coefficients
end
if nargin<5 | isempty(radius)
    radius = sqrt((range(x)/30)^2 + (range(y)/30)^2);
end
if nargin<6 | isempty(po)
    po = 1; %plot option
end
if nargin<7 | isempty(ms)
    ms = 4; %markersize
end
if nargin<8 | isempty(N)
    N = 100; %length of grid
end
%Correct data if necessary
x = x(:);
y = y(:);
%Asuming x and y match
idat = isfinite(x);
x = x(idat);
y = y(idat);
holdstate = ishold;
if holdstate==0
    cla
end
hold on
%--------- Caclulate data density ---------
dd = datadensity(x,y,method,radius);
%------------- Gridding -------------------
xi = repmat(linspace(min(x),max(x),N),N,1);
yi = repmat(linspace(min(y),max(y),N)',1,N);
zi = griddata(x,y,dd,xi,yi);
%----- Bidimensional running mean filter -----
zi(isnan(zi)) = 0;
coef = ones(n(1),1)/n(1);
zif = conv2(coef,coef,zi,'same');
if length(n)>1
    for k=1:n(2)
        zif = conv2(coef,coef,zif,'same');
    end
end
%-------- New Filtered data densities --------
ddf = griddata(xi,yi,zif,x,y);
%----------- Plotting --------------------
switch po
    case {1,2}
        if po==2
            [c,h] = contour(xi,yi,zif);
            out.c = c;
            out.h = h;
        end %if
        hs = gsp(x,y,ddf,ms);
        out.hs = hs;
        colorbar
    case {3,4}
        if po>3
            [c,h] = contour(xi,yi,zi);
            out.c = c;
        end %if
        hs = gsp(x,y,dd,ms);
        out.hs = hs;
        colorbar    
end %switch
%------Relocate variables and place NaN's ----------
dd(idat) = dd;
dd(~idat) = NaN;
ddf(idat) = ddf;
ddf(~idat) = NaN;
%--------- Collect variables ----------------
out.dd = dd;
out.ddf = ddf;
out.radius = radius;
out.xi = xi;
out.yi = yi;
out.zi = zi;
out.zif = zif;
if ~holdstate
    hold off
end
return
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function scatplotdemo
po = 2;
method = 'squares';
radius = [];
N = [];
n = [];
ms = 5;
x = randn(1000,1);
y = randn(1000,1);

out = scatplot(x,y,method,radius,N,n,po,ms)

return
%~~~~~~~~~~ Data Density ~~~~~~~~~~~~~~
function dd = datadensity(x,y,method,r)
%Computes the data density (points/area) of scattered points
%Striped Down version
%
% USAGE:
%   dd = datadensity(x,y,method,radius)
%
% INPUT:
%   (x,y) -  coordinates of points
%   method - either 'squares','circles', or 'voronoi'
%       default = 'voronoi'
%   radius - Equal to the circle radius or half the square width
Ld = length(x);
dd = zeros(Ld,1);
switch method %Calculate Data Density
    case 'sq'  %---- Using squares ----
        for k=1:Ld
            dd(k) = sum( x>(x(k)-r) & x<(x(k)+r) & y>(y(k)-r) & y<(y(k)+r) );
        end %for
        area = (2*r)^2;
        dd = dd/area;
    case 'ci'
        for k=1:Ld
            dd(k) = sum( sqrt((x-x(k)).^2 + (y-y(k)).^2) < r );
        end
        area = pi*r^2;
        dd = dd/area;
    case 'vo'  %----- Using voronoi cells ------
        [v,c] = voronoin([x,y]);     
        for k=1:length(c) 
            %If at least one of the indices is 1, 
            %then it is an open region, its area
            %is infinity and the data density is 0
            if all(c{k}>1)   
                a = polyarea(v(c{k},1),v(c{k},2));
                dd(k) = 1/a;
            end %if
        end %for
end %switch
return
%~~~~~~~~~~ Graf Scatter Plot ~~~~~~~~~~~
function varargout = gsp(x,y,c,ms)
%Graphs scattered poits
map = colormap;
ind = fix((c-min(c))/(max(c)-min(c))*(size(map,1)-1))+1;
h = [];
%much more efficient than matlab's scatter plot
for k=1:size(map,1) 
    if any(ind==k)
        h(end+1) = line('Xdata',x(ind==k),'Ydata',y(ind==k), ...
            'LineStyle','none','Color',map(k,:), ...
            'Marker','.','MarkerSize',ms);
    end
end
if nargout==1
    varargout{1} = h; 
end
return

function y = range(x,dim) %% MATLAB 默认
%RANGE  Sample range.
%   Y = RANGE(X) returns the range of the values in X.  For a vector input,
%   Y is the difference between the maximum and minimum values.  For a
%   matrix input, Y is a vector containing the range for each column.  For
%   N-D arrays, RANGE operates along the first non-singleton dimension.
%
%   RANGE treats NaNs as missing values, and ignores them.
%
%   Y = RANGE(X,'all') operates on all the dimensions of X.
%
%   Y = RANGE(X,DIM) operates along the dimension DIM.
%
%   Y = RANGE(X,VECDIM) operates along all the dimensions specified in VECDIM.
%
%   See also BOUNDS, MIN, MAX, IQR, MAD, STD.

%   Copyright 1993-2018 The MathWorks, Inc.

if nargin < 2
    y = max(x) - min(x);
else
    y = max(x,[],dim) - min(x,[],dim);
end
