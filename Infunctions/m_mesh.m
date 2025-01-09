function h = m_mesh(Grid,varargin)
    %       Added more function for m_map toolbox,  (f_2d_mesh w_2d_mesh)
    % =================================================================================================================
    % Parameters:
    %       Grid:           Grid struct                     || required: True || type: struct    || format: wgrid
    %       varargin:   (options)   as follow:
    %           Color:      line color                      || required: False|| type: namevalue || example: 'Color','k'
    %           Global:     Global switch(only for wgrid)   || required: False|| type: flag      || example: 'Global'
    % =================================================================================================================
    % Returns:
    %       h:  patch handle    || type: handle
    % =================================================================================================================
    % Updates:
    %       2025-01-03:     Created,                        by Christmas;
    % =================================================================================================================
    % Examples:
    %       m_mesh(w);
    %       m_mesh(w,'Color','r');
    %       h = m_mesh(w,'Color','r');
    %
    %   **CASE1**:
    %       fin = '/Users/christmas/Desktop/exampleNC/BBW_2d.nc';
    %       f = f_load_grid(fin,'Coordinate','geo');
    %       m_proj('Mercator','lon',minmax(f.x),'lat',minmax(f.y));
    %       m_mesh(f); m_grid;
    %       m_grid;
    %       
    %   **CASE2**:
    %       fin = '/Users/christmas/Desktop/exampleNC/d02.nc';
    %       w = w_load_grid(fin);
    %       m_proj('Mercator','lon',minmax(w.x),'lat',minmax(w.y));
    %       m_mesh(w); m_grid;
    % =================================================================================================================
    % References:
    %       See also M_MAP F_2D_MESH W_2D_MESH
    % =================================================================================================================
    
    varargin = read_varargin(varargin, {'Color'}, {'k'});

    if isfield(Grid,'node')
        SWITCH.type = 'FVCOM';
        varargin = read_varargin2(varargin, {'Global'});
    else
        SWITCH.type = 'WRF';
    end

    [x,y] = m_ll2xy(Grid.x,Grid.y);
    nv = Grid.nv;

    switch SWITCH.type
    case 'FVCOM'
        if ~isempty(Global) || strcmp(Grid.type, 'Global')
            edge_cell = max(x(nv), [], 2) - min(x(nv), [], 2)>181;
            nv(edge_cell, :) = [];
        end
    case 'WRF'
    end
    h = patch('Vertices',[x(:),y(:)], 'Faces',nv, 'FaceColor','k','FaceAlpha',0, 'EdgeColor', Color);

    if (~isempty(varargin))
        set(h, varargin{:});
    end

    if nargout == 0 
        clear h
    end
end


