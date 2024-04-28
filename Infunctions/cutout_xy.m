function [Xdst, Ydst, Vdst, SIZE, varargout] = cutout_xy(xlims, ylims, Xsrc, Ysrc, Vsrc, varargin)
    %       Cut out a region from a map
    % =================================================================================================================
    % Parameters:
    %       xlims:      longitude range                  || required: True || type: double    || format: [min, max]
    %       ylims:      latitude range                   || required: True || type: double    || format: [min, max]
    %       Xsrc:       source longitude                 || required: True || type: double    || format: 1D or 2D
    %       Ysrc:       source latitude                  || required: True || type: double    || format: 1D or 2D
    %       Vsrc:       source variable                  || required: True || type: double    || format: nD array
    %       varargin:       optional parameters      
    % =================================================================================================================
    % Returns:
    %       Xdst:       destination longitude             || type: double || format: 1D or 2D
    %       Ydst:       destination latitude              || type: double || format: 1D or 2D
    %       Vdst:       destination variable              || type: double || format: nD array
    %       SIZE:       size of source and destination    || type: struct || format: struct
    %       varargout:  (optional)
    %           NO:     index of left                     || type: struct || format: struct
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created, by Christmas;
    %       2024-04-26:     Changed more,  by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Xdst, Ydst, Vdst, SIZE, F] = region_cutout(xlims, ylims, Xsrc, Ysrc, Vsrc);
    %       [Xdst, Ydst, Vdst, SIZE, F] = region_cutout(xlims, ylims, Xsrc, Ysrc, Vsrc);
    % =================================================================================================================
    % Explains:
    %       Lon         Lat        Var
    %      1800*1      900*1     1800*900*n       % LL        1D*1D均匀网格
    %      1800*1     1800*1     1800*n           % SCATTER   散点
    % =================================================================================================================

    
    if nargout >= 5
        mode = 'FIND';  % 'FIND' or 'ASSIGN'
    else
        mode = 'ASSIGN';
    end
    xlims = minmax(xlims);
    ylims = minmax(ylims);

    size_x = size(Xsrc);
    size_y = size(Ysrc);
    size_v = size(Vsrc);

    if all(size_x~=size_y) && numel(Xsrc)*numel(Ysrc)== prod(size_v(1:2))
        Gtype = 'LL';
    elseif numel(Xsrc)==numel(Ysrc) && numel(Ysrc)==numel(Vsrc(:,1,1,1))
        Gtype = 'SCATTER';
    end

    switch Gtype
    case 'LL'
        if size_x(1) == 1 && size_x(2) ~= 1
            Xsrc = Xsrc';
        end
        if size_y(1) == 1 && size_y(2) ~= 1
            Ysrc = Ysrc';
        end
        SIZE.xr = length(Xsrc);
        SIZE.yr = length(Ysrc);
        SIZE.vr = size(Vsrc);
        SIZE.xyr = SIZE.vr(1:2);
        Vsrc = reshape(Vsrc,SIZE.xyr(1),SIZE.xyr(2),[]);  % x*y*zt

    case 'SCATTER'
        SIZE.xr = length(Xsrc);
        SIZE.yr = length(Ysrc);
        SIZE.vr = size(Vsrc);
        SIZE.xyr = SIZE.vr(1);
        Vsrc = reshape(Vsrc,SIZE.xyr(1),[]);  % --> n*zt 

    otherwise
    end
    clear size_x size_y size_v

    switch Gtype
    case 'LL'
        switch mode
        case 'FIND'
            NO.F1 = find(Xsrc>xlims(1) & Xsrc<xlims(end));
            Xdst = Xsrc(NO.F1); Vdst = Vsrc(NO.F1,:,:);

            NO.F2 = find(Ysrc>ylims(1) & Ysrc<ylims(end));
            Ydst = Ysrc(NO.F2); Vdst = Vdst(:,NO.F2,:);

        case 'ASSIGN'
            Xdst = Xsrc; Ydst = Ysrc; Vdst = Vsrc;
            Vdst = Vdst(Xdst>=xlims(1) & Xdst<=xlims(2), Ydst>=ylims(1) & Ydst<=ylims(2),:);
            Xdst = Xdst(Xdst>=xlims(1) & Xdst<=xlims(2));
            Ydst = Ydst(Ydst>=ylims(1) & Ydst<=ylims(2));
        end
        SIZE.xo = length(Xdst);
        SIZE.yo = length(Ydst);
        SIZE.vo = [SIZE.xo, SIZE.yo, SIZE.vr(3:end)];
        SIZE.xyo = SIZE.vo(1:2);
        Vdst = reshape(Vdst,SIZE.vo);

    case 'SCATTER'
        NO.F1 = (Xsrc>=xlims(1) & Xsrc<=xlims(2) & Ysrc>=ylims(1) & Ysrc<=ylims(2));
        Xdst = Xsrc(NO.F1);
        Ydst = Ysrc(NO.F1);
        Vdst = Vsrc(NO.F1,:);

        SIZE.xo = length(Xdst);
        SIZE.yo = length(Vdst);
        SIZE.xyo = SIZE.xo(1);
        SIZE.vo = [SIZE.xyo, SIZE.vr(2:end)];
        
        Vdst = reshape(Vdst,SIZE.vo);

    otherwise
    end
    clearvars mode
    varargout{1} = NO;
    return
end
