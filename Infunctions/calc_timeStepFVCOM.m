function Tt = calc_timeStepFVCOM(fgrid, options)
    %   Calculate FVCOM time step
    % =================================================================================================================
    % Parameters:
    %       fgrid:          FVCOM grid struct                   || required: True  || type: struct || from:  f_load_grid
    %       varargin: (optional)
    %           Coordinate: Coordinate system                   || required: False || type: namevalue  || default: 'geo'
    %           uMax:    anticipated maximum current speed      || required: False || type: namevalue  || default: 5
    %           hMax:    anticipated maximum surface elevation  || required: False || type: namevalue  || default: 10
    %           g:       gravitational acceleration             || required: False || type: namevalue  || default: 9.81
    %           Global:     Switch global or local              || required: False || type: flag       || example: 'Global'
    % =================================================================================================================
    % Returns:
    %       Tt
    %           .extern EXTSTEP_SECONDS 外膜步长。   || type: double
    % =================================================================================================================
    % Updates:
    %       2025-01-08:     Created,  by Christmas;
    % =================================================================================================================
    % Examples:
    %       Tt = calc_timeStepFVCOM(fgrid);
    %       Tt = calc_timeStepFVCOM(fgrid,'Global');
    %       Tt = calc_timeStepFVCOM(fgrid,'Coordinate','geo');
    %
    %       fin = '/Users/christmas/Documents/Code/Project/Server_Program/CalculateModel/FVCOM_WZtide3/Control/data/wztide3.2dm';
    %       f = f_load_grid(fin);
    %       Tt = calc_timeStepFVCOM(f);
    %       fprintf('Estimated max EXTSTEP_SECONDS is %.3f s\n',min(Tt.extern));
    % =================================================================================================================
    % References:
    %
    %       <a href="https://github.com/pwcazenave/fvcom-toolbox/blob/master/fvcom_prepro/estimate_ts.m">estimate_ts.m</a>
    %       <a href="http://www.mathworks.com/matlabcentral/fileexchange/27785">haversine.m</a>
    %       See also F_2D_IMAGE
    % =================================================================================================================
    
    arguments(Input)
        fgrid(1,1) {struct}
        options.Coordinate {mustBeMember(options.Coordinate,['geo','xy',"geo","xy"])} = 'geo'
        options.uMax(1,1) {mustBeFloat} = 5
        options.hMax(1,1) {mustBeFloat} = 10
        options.g(1,1) {mustBeFloat} = 9.81
        options.Global {mustBeMember(options.Global,['','Global'])} = ''
    end
    Coordinate = options.Coordinate;
    uMax = options.uMax;
    hMax = options.hMax;
    g = options.g;
    Global = options.Global;

    x = fgrid.x;
    y = fgrid.y;
    nv = fgrid.nv;
    h = fgrid.h;
    node = fgrid.node;
    MidLon = fgrid.MaxLon - 180.;

    if strcmp(fgrid.type, 'Global') || strcmpi(Global, 'Global')
        % from f_2d_image
        Pole_node = find(y==90.);
        max_cell_x = max(x(nv), [], 2);
        min_cell_x = min(x(nv), [], 2);
        edge_cell = (max_cell_x>MidLon & min_cell_x<MidLon & max_cell_x-min_cell_x>180.);
    
        edge_nv = nv(edge_cell,:);
        edge_node = setdiff(unique(edge_nv), Pole_node);
    
        edge_x = x(edge_node);
        k1 = find(edge_x < MidLon);
        k2 = find(edge_x > MidLon);
        edge_x(k1) = edge_x(k1) + 360.;
        edge_x(k2) = edge_x(k2) - 360.;
        edge_y = y(edge_node);
        edge_nv_right = changem(edge_nv, k1+node, edge_node(k1));
        edge_nv_left = changem(edge_nv, k2+node, edge_node(k2));
    
        x = [x; edge_x];
        y = [y; edge_y];
        nv = [nv(~edge_cell, :); edge_nv_right; edge_nv_left];
        h = [h; h(edge_node)];
        fgrid_new = f_load_grid(x,y,nv,h,'Nodisp');
    else
        fgrid_new = fgrid;
    end

    [~, d] = f_calc_resolution(fgrid_new, Coordinate, 'Nodisp');
    d_min = min(d,[],2);
    D = fgrid_new.hc + hMax;

    Tt.extern = d_min./(sqrt(g*D) + uMax);

    % CE = (sqrt(g*D));
    % CI < CE

    if nargout == 0
        disp(' ')
        disp('------------------------------------------------')
        fprintf(' Estimated max EXTSTEP_SECONDS is %.3f s\n',min(Tt.extern));
        disp('------------------------------------------------')
        disp(' ')
    end

end
