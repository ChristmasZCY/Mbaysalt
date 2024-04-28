function [Xdst, Ydst, bdy] = zoom_ploygon(Xsrc, Ysrc, varargin)
    %       Cut out a region from a map
    % =================================================================================================================
    % Parameters:
    %       Xsrc:       source longitude                 || required: True || type: double    || format: 1D
    %       Ysrc:       source latitude                  || required: True || type: double    || format: 1D
    %       varargin:       optional parameters      
    %           d:      distance of buffer               || required: True || type: double    || format: number
    %           figOn:  figure on or off                 || required: False|| type: flag      || format: 'figOn'
    % =================================================================================================================
    % Returns:
    %       Xdst:       destination longitude             || type: double || format: 1D or 2D
    %       Ydst:       destination latitude              || type: double || format: 1D or 2D
    %       bdy:        boundary of the region            || type: struct || format: struct
    %           .old:   old boundary                      || type: double || format: 2D
    %           .new:   new boundary                      || type: double || format: 2D
    % =================================================================================================================
    % Updates:
    %       2024-04-26:     Created,  by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Xdst, Ydst, bdy] = zoom_ploygon(Xsrc, Ysrc, 0.1);
    %       [Xdst, Ydst, bdy] = zoom_ploygon(Xsrc, Ysrc, 0.1, 'figOn');
    % =================================================================================================================

    varargin = read_varargin2(varargin, {'figOn'});
    
    poly_old = polyshape(Xsrc, Ysrc);  % 创建多边形
    poly_new = polybuffer(poly_old,varargin{:});  % 创建缓冲区 ——> d>0为外扩; d<0为内缩
    
    bdy.old = poly_old.Vertices;  % 得到原始边界
    bdy.new = poly_new.Vertices;  % 得到缓冲区边界

    Xdst = bdy.new(:,1);
    Ydst = bdy.new(:,2);
    
    if ~isempty(figOn)
        figure
        plot(poly_old,'facecolor',[101 147 80]/256); % 原多边形区域
        hold on
        axis equal
        plot(poly_new,'facecolor',[124 191 160]/256,'linestyle','none'); % 扩展后多边形区域
        plot(bdy.old(:,1),bdy.old(:,2),'k.');% 黑点为外扩后得到的缓冲区边界点
        plot(bdy.new(:,1),bdy.new(:,2),'r.');% 红点为外扩后得到的缓冲区边界点
    end

    return

end
