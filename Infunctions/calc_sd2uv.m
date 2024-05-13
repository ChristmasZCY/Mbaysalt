function [u, v] = calc_sd2uv(spd ,dir, opt)
    %       Calculate speed and direction to vector velocity
    % =================================================================================================================
    % Parameters:    
    %       spd:    speed                                           || required: True  || type: matrix
    %       dir:    wind/wave from direction, current to direction  || required: True  || type: matrix
    %       opt: opt case                                           || required: False || type: char   || format: 'current','wind','ww3','wave'
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       u:   U velocity
    %       v:   V velocity
    % =================================================================================================================
    % Updates:
    %       2024-05-13:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [u, v] = calc_sd2uv(spd ,dir, 'current');
    %       [u, v] = calc_sd2uv(spd ,dir, 'wind');
    %       [u, v] = calc_sd2uv(spd ,dir, 'wave');
    %       [u, v] = calc_sd2uv(spd ,dir, 'ww3');
    % =================================================================================================================
    % Reference:
    %
    %   See also CALC_UV2SD
    %   <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_uv2sd.m'), 23); ">see Description</a>
    % =================================================================================================================

    arguments
        spd {mustBeFloat}
        dir {mustBeFloat}
        opt  {mustBeMember(opt,{'current','wind','wave','ww3'})}
    end

    switch opt
    case 'current'
        [u, v] = sd2uv_to(spd, dir);
    case 'wind'
        [u, v] = sd2uv_from(spd, dir);
    case {'wave','ww3'}
        [u, v] = sd2uv_from(spd, dir);
    otherwise
        error('opt must be one of ''current'',''wind'',''wave'',''ww3'', but you set ''%s''.', opt);
    end

end


function [u, v] = sd2uv_from(spd, dir)
    % direction(from) to uv , such as wind, wave --> 来向 0 为正北，顺时针，90为正东

    [u, v] = calc_wind2uv(spd, dir);
    
end

function [u, v] = sd2uv_to(spd, dir)
    % direction(to) to uv, such as current, --> 与矢量方向定义相同， 0为正东，逆时针，90为正北

    [u, v] = calc_current2uv(spd, dir);
end
