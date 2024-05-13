function [spd, dir] = calc_uv2sd(u ,v, opt)
    %       Calculate velocity to speed and direction
    % =================================================================================================================
    % Parameters:
    %       u:   U velocity       || required: True  || type: matrix
    %       v:   V velocity       || required: True  || type: matrix
    %       opt: opt case         || required: False || type: char   || format: 'current','wind','ww3','wave'
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       spd:    speed
    %       dir:    direction  --> wind/wave from direction, current to direction
    % =================================================================================================================
    % Updates:
    %       2024-05-13:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [spd, dir] = calc_uv2sd(u ,v, 'current');
    %       [spd, dir] = calc_uv2sd(u ,v, 'wind');
    %       [spd, dir] = calc_uv2sd(u ,v, 'wave');
    %       [spd, dir] = calc_uv2sd(u ,v, 'ww3');
    % =================================================================================================================
    % Reference:
    %       UV 表示都是矢量方向，即去向 正向与坐标轴正向相同
    %       dir 才分来向和去向
    %       --------------------------------------------------------
    %       比如 dir=90; 在表示wave_dir时, 为wave的来向, 从东来, 东往西传播 -- 风和浪同理
    %       U = sin(deg2rad(dir+180)); --> -1 表示去向
    %       V = cos(deg2rad(dir+180)); -->  0 表示去向
    %       dir = rad2deg(atan2(U,V))+180 % dir 表示风浪的来向，与x相同
    %       --------------------------------------------------------
    %       比如 dir=90; 在表示current_dir时, 为current的去向, 往北走, 从南向北流
    %       U = 1 表示去向
    %       V = 0 表示去向
    % =================================================================================================================

    arguments
        u {mustBeFloat}
        v {mustBeFloat}
        opt  {mustBeMember(opt,{'current','wind','wave','ww3'})}
    end

    switch opt
    case 'current'
        [spd, dir] = uv2sd_to(u, v);
    case 'wind'
        [spd, dir] = uv2sd_from(u, v);
    case {'wave','ww3'}
        [spd, dir] = uv2sd_from(u, v);
    otherwise
        error('opt must be one of ''current'',''wind'',''wave'',''ww3'', but you set ''%s''.', opt);
    end

end


function [spd, dir] = uv2sd_from(u, v)
    % uv to direction(from), such as wind, wave --> 来向 0 为正北，顺时针，90为正东

    [spd, dir] = calc_uv2wind(u, v);
    
end

function [spd, dir] = uv2sd_to(u, v)
    % uv to direction(to), such as current, --> 与矢量方向定义相同， 0为正东，逆时针，90为正北

    [spd, dir] = calc_uv2current(u, v);
end
