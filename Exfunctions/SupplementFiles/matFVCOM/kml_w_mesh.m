%==========================================================================
% Draw WRF mesh in KML
%
% input  : wgrid --- WRF grid cell
%          fout  --- output path and name
%          'Model'     --- name displayed in Google Earth
%          'LineWidth' --- line width
%          'LineColor' --- line color ('r', 'red' or [255 0 0])
% 
% output : \
%
% Siqi Li, SMAST
% 2021-06-09
%
% Updates:
%   2021-09-13  Christmas changed 'kml_f_mesh' to this.
%
%==========================================================================
function k = kml_w_mesh(wgrid, fout, varargin)

% wgrid = f;
% Model = 'WRF Mesh';
% LineWidth = 1.5;
% LineColor = 'FFF1F258';

% Default settings:
varargin = read_varargin(varargin, {'Model'}, {'WRF Mesh'});
varargin = read_varargin(varargin, {'Altitude'}, {0});
% if numel(Altitude) == 1
%     Altitude = ones(size(wgrid.lines_x,1)*3, 1) * Altitude;
%     Altitude(3:3:end) = nan;
% end
varargin = read_varargin(varargin, {'LineWidth'}, {1.5});
% varargin = read_varargin(varargin, {'LineColor'}, {'FFF1F258'});
varargin = read_varargin(varargin, {'LineColor'}, {[88 242 241]});
switch class(LineColor)
case 'char'
    RGB = COLOR2RGB(LineColor);
    LineColor = RGB2ABGR(255, RGB);
case 'double'
    LineColor = RGB2ABGR(255, LineColor);
otherwise
    error('Unknown LineColor')
end

% % lineWidth = 1.5;
% % lineColor = 'FFF1F258';
% % 
% % if ~isempty(varargin)
% %     i = 1;
% %     while i < nargin-3
% %         switch lower(varargin{1})
% %             case 'linewidth'
% %                 lineWidth = varargin{i+1};
% %                 i = i + 2;
% %             case 'linecolor'
% %                 input = varargin{i+1};
% %                 i = i + 2;
% %                 
% %                 switch class(input)
% %                     case 'char'
% %                         RGB = COLOR2RGB(input);
% %                         lineColor = RGB2ABGR(255, RGB);
% %                     case 'double'
% %                         lineColor = RGB2ABGR(255, input*255);
% %                 end
% %   
% %             otherwise
% %                 error(['Unknown input: ' varargin{i}])
% %         end
% %     end
% % end


if ~isfield(wgrid, 'lines_x')
    [bdy_x, bdy_y, lines_x, lines_y, bdy] = w_calc_boundary(wgrid);
    wgrid.bdy_x = bdy_x;
    wgrid.bdy_y = bdy_y;
    wgrid.lines_x = lines_x;
    wgrid.lines_y = lines_y;
    wgrid.bdy = bdy;
    assignin('base', inputname(1), wgrid);
end

n = size(wgrid.lines_x, 1);

k = kml(Model);

% if n < 600000000
method = 4;
switch method
    case 1
        for i = 1 : n
            if mod(i, 1000) == 0; disp([num2str(i) ' / ' num2str(n)]);end
            k.plot(wgrid.lines_x(i,:), wgrid.lines_y(i,:), ...
                'altitude', Altitude,              ...
                'altitudeMode', 'absolute', ...
                'lineWidth', LineWidth,     ...
                'lineColor', LineColor,     ...
                'name', 'WRF Mesh');
        end
        
    case 2
        x = wgrid.lines_x;
        y = wgrid.lines_y;
        x(:,3) = nan;
        y(:,3) = nan;
        x = reshape(x', 1, []);
        y = reshape(y', 1, []);

        slice = 60000;

        for i = 1 : ceil(length(x)/slice)
            i1 = (i-1)*slice + 1;
            i2 = min([i*slice, length(x)]);
            k.plot(x(i1:i2), y(i1:i2), ...
                'altitude', Altitude,              ...
                'altitudeMode', 'absolute', ...
                'lineWidth', LineWidth,     ...
                'lineColor', LineColor,     ...
                'name', 'WRF Mesh');
        end

    case 3  % ABANDON
        % This method takes too much time on calculating strings. 
        % It will draw lines between two points each time.
        lines_a = [wgrid.nv(:,1:2);wgrid.nv(:,2:3);wgrid.nv(:,3:4);[wgrid.nv(:,4),wgrid.nv(:,1)]];
        lines_a = sort(lines_a, 2);
        lines = unique(lines_a, 'rows');
        string = num2cell(lines, 2);
        n = length(string);
        for i = 1 : n
            if mod(i, 1000) == 0; disp([num2str(i) ' / ' num2str(n)]);end
            k.plot(wgrid.x(string{i}), wgrid.y(string{i}), ...
                'altitude', Altitude,              ...
                'altitudeMode', 'absolute', ...
                'lineWidth', LineWidth,     ...
                'lineColor', LineColor,     ...
                'name', 'WRF Mesh');
        end
    case 4
        % It will draw one line between top and bottom each time.
        for i = 1: size(wgrid.x, 1)
            k.plot(wgrid.x(i, :), wgrid.y(i, :), ...
                'altitude', Altitude,              ...
                'altitudeMode', 'absolute', ...
                'lineWidth', LineWidth,     ...
                'lineColor', LineColor,     ...
                'name', 'WRF Mesh |');
        end
        % It will draw one line between left and right each time.
        for i = 1: size(wgrid.x, 2)
            k.plot(wgrid.x(:, i), wgrid.y(:, i), ...
                'altitude', Altitude,              ...
                'altitudeMode', 'absolute', ...
                'lineWidth', LineWidth,     ...
                'lineColor', LineColor,     ...
                'name', 'WRF Mesh -');
        end

end

k.save(fout);

end


function ARGB = RGB2ABGR(alpha, RGB)

    if max(alpha) <= 1
        alpha = alpha * 255;
    end
    if max(RGB(:)) <= 1
        RGB = RGB * 255;
    end
    
    ARGB = [dec2hex(alpha,2) dec2hex(RGB(3),2) dec2hex(RGB(2),2) dec2hex(RGB(1),2)];
    
end

function RGB = COLOR2RGB(COLOR)
    
    switch COLOR
        case {'red', 'r'}
            RGB = [255 0 0];
        case {'green', 'g'}
            RGB = [0 255 0];
        case {'blue', 'b'}
            RGB = [0 0 255];
        case {'cyan', 'c'}
            RGB = [0 255 255];
        case {'magenta', 'm'}
            RGB = [255 0 255];
        case {'yellow', 'y'}
            RGB = [255 255 0];
        case {'black', 'k'}
            RGB = [0 0 0];
        case {'white', 'w'}
            RGB = [255 255 255];
        otherwise
            error(['Unknown color code: ' COLOR])
    end
    
end
