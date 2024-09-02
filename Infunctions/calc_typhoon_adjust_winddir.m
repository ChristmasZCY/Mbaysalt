function [u, v] = calc_typhoon_adjust_winddir(lon_grid, lat_grid, lon_tyCenter, lat_tyCenter, spd, varargin)
    %       Adjust wind direction at typhoon  --> 计算U、V风速（考虑角度校正）
    % =================================================================================================================
    % Parameters:
    %       lon_grid:       longitude grid                || required: True  || type: 2D        || format: 2D matrix
    %       lat_grid:       latitude  grid                || required: True  || type: 2D        || format: 2D matrix
    %       lon_tyCenter:   typhoon center longitude      || required: True  || type: 1         || format: 122
    %       lat_tyCenter:   typhoon center latitude       || required: True  || type: 1         || format: 34
    %       spd:            Gradient wind velocity        || required: True  || type: 2D        || format: 2D matrix
    %       varargin: (optional)  
    %            betaa:     Inflow Angle                  || required: False || type: namevalue || format: 'betaa',20 
    % =================================================================================================================
    % Returns:
    %        u:    Adjusted windSpeed U
    %        v:    Adjusted windSpeed V
    % =================================================================================================================
    % Updates:
    %       2024-05-11:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [u,v] = calc_typhoon_adjust_winddir(122, 23, 121, 24, 1);
    % =================================================================================================================
    % References:
    %
    %    <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_typhoon_adjust_winddir_readme.mlx'), 2^31-1); ">see Picture</a>
    % =================================================================================================================

    varargin = read_varargin(varargin,{'betaa'}, {20});  % beta:流入角，取为20
    varargin = read_varargin(varargin,{'C2'}, {0.71});   % C2:修正系数 取为0.071

    % theta:台风中心与计算点连线与正X轴即正东方向的夹角（逆时针），thtea的范围是[0-360)
    dx = lon_grid - lon_tyCenter;
    dy = lat_grid - lat_tyCenter;
    if dy >= 0
        theta=atan2d(dy,dx);
    else
        theta=360+atan2d(dy,dx);
    end
    u = C2*spd.*cosd(90+theta+betaa);
    v = C2*spd.*sind(90+theta+betaa);
end
