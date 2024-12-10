function poly_coast = gshhs2(gshhsfile, varargin)
    %       Fixed gshhs only for [-180 195], gshhs2 for [-540 540]
    % =================================================================================================================
    % Parameters:
    %       gshhsfile:  gshhs filepath                   || required: True  || type: filename  || format: 'gshhs_c.b'
    %       varargin: (optional)
    %           ylims:  latitude range                   || required: False || type: double   || format: [min, max]
    %           xlims:  latitude range                   || required: False || type: double   || format: [min, max]    
    % =================================================================================================================
    % Returns:
    %       poly_coast: polyshape of coast               || type: polyshape
    % =================================================================================================================
    % Updates:
    %       2024-05-15:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       poly_coast = gshhs2('gshhs_c.b');
    %       poly_coast = gshhs2('gshhs_c.b',[-90 90],[0 360]);
    % =================================================================================================================
    % Reference:
    %       
    %       See also GSHHS
    %       <a href="https://www.soest.hawaii.edu/wessel/gshhg/">GSHHG Web</a>
    %       <a href="https://mp.weixin.qq.com/s/SQ2qU_1ScvAzxiJNZJ9ktg">ETOPO地形高程数据绘图及gshhs精细岸线数据绘图</a>
    % =================================================================================================================

    narginchk(1,3);
    METHOD.read = 'fixed';  % 'fixed' or 'direct'

    
    switch numel(varargin)
    case 0
        ylims = [-90 90];
        xlims = [-180 195];
    case 2
        ylims = varargin{1};
        xlims = varargin{2};
    otherwise
        error('Input number must be one or three!')
    end

    map.internal.assert((max(xlims)<=540 && min(xlims)>=-540), ...
                        'map:validate:expectedRange','LONLIM','-540','lonlim','540')
    map.internal.assert((max(ylims)<=90 && min(ylims)>=-90), ...
                        'map:validate:expectedRange','LATLIM','-90','latlim','90')
    
    bbox = [xlims(1) ylims(1);
           xlims(2) ylims(1);
           xlims(2) ylims(2);
           xlims(1) ylims(2);
           xlims(1) ylims(1)];
    
    if min(xlims) > -180 && max(xlims) < 195
        S = gshhs(gshhsfile, ylims, xlims);
    else
        S = gshhs(gshhsfile, [-90 90], [-180 180]);
    end
    switch METHOD.read
    case 'fixed'  % c.b 在5 6循环的时候首尾不相连
        for is = 1:length(S)
            S1 = S(is);
            if ~isnan(S1.Lon(end))
                S1.Lon(end+1) = NaN;
                S1.Lat(end+1) = NaN;
            end
            if abs(S1.Lon(end-1)-S1.Lon(1)) > 1e-3
                S1.Lon(end) = S1.Lon(1);
                S1.Lat(end) = S1.Lat(1);
                S1.Lon(end+1) = NaN;
                S1.Lat(end+1) = NaN;
            end
            S(is) = S1;
        end
    case 'direct'
    otherwise
        error('METHOD.read must be one of ''fixed'' or ''direct''.')
    end
    cstLon = [S(:).Lon]';
    cstLat = [S(:).Lat]';

    warning('off','MATLAB:polyshape:repairedBySimplify');
    POLYGON.cstM = polyshape([cstLon,cstLat], 'KeepCollinearPoints', true);
    POLYGON.ccst = POLYGON.cstM;
    if min(xlims) < -180
        cstLon_L = [cstLon-360; cstLon];
        cstLat_L = [cstLat;     cstLat];
        POLYGON.cstL = polyshape([cstLon_L,cstLat_L], 'KeepCollinearPoints', true);
        POLYGON.ccst = union(POLYGON.ccst,POLYGON.cstL);
    end
    if max(xlims) > 180
        cstLon_R = [cstLon; cstLon+360];
        cstLat_R = [cstLat; cstLat];
        POLYGON.cstR = polyshape([cstLon_R,cstLat_R], 'KeepCollinearPoints', true);
        POLYGON.ccst = union(POLYGON.ccst,POLYGON.cstR);
    end

    POLYGON.bbox = polyshape(bbox, 'KeepCollinearPoints', true);
    POLYGON.iset = intersect(POLYGON.bbox, POLYGON.ccst);
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
    poly_coast = POLYGON.iset;

    return
    
end

