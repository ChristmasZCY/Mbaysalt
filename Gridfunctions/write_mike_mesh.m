function write_mike_mesh(fout, x, y, nv, h, bounds, options)
    %       Write MIKE21 .mesh file  -- ascii
    % =================================================================================================================
    % Parameter:
    %       fout: output file name                || required: True  || type: text      ||  example: './output_mesh.mesh'
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                 (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       bounds: boundary nodes   (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5],[1,2,3]}
    %       options: (optional)
    %           Coordinate: 'geo' or 'xy'         || required: False || type: text      ||  example: 'geo'
    %           prj: projection                   || required: False || type: text      ||  example: ''
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-04-03:     Created , by Christmas;
    % =================================================================================================================
    % Example:
    %       write_mike_mesh('./output_mesh.mesh',x,y,nv)
    %       write_mike_mesh('./output_mesh.mesh',x,y,nv,h)
    %       write_mike_mesh('./output_mesh.mesh',x,y,nv,h,bounds)
    %       write_mike_mesh('./output_mesh.mesh',x,y,nv,"Coordinate",'geo')
    %       write_mike_mesh('./output_mesh.mesh',x,y,nv,h,"Coordinate",'geo',"prj","")
    % =================================================================================================================

    arguments(Input)
        fout {mustBeTextScalar}
        x (:,1) {mustBeNumeric}
        y (:,1) {mustBeNumeric}
        nv (:,3) {mustBeNumeric}
        h (:,1)  = zeros(length(x),1);
        bounds (:,:) {cell} = cell(0);
        options.Coordinate = 'geo'
        options.prj {mustBeTextScalar} = ''
    end
    Coordinate = options.Coordinate;
    prj = options.prj;

    if min(nv(:)) ~=1 || max(nv(:)) ~= length(x)
        error('Wrong nv!')
    end

    if sum(isnan(x)) > 0
        error("NaN in 'x' !")
    end
    if sum(isnan(y)) > 0
        error("NaN in 'y' !")
    end
    if sum(isnan(h)) > 0
        error("NaN in 'h' !")
    end

    % Calculate bounds
    % bounds可能是{},也可能是{{},{}}
    if isa(bounds{1},'cell')  % {{},{}}
        for i = 1: length(bounds)
            bounds{i} = cell2mat(bounds{i})';
        end
    end
    bounds = cell2mat(bounds);
    
    type = zeros(length(x),1);
    type(bounds) = 1;
 
    fid = fopen(fout,'w');
    fprintf(fid, '%d %s\n', length(x), prj);
    
    % points
    switch lower(Coordinate)
    case 'geo'
        for i = 1: length(x)
            fprintf(fid,'%d %f %f %f %d\n', i, x(i), y(i), h(i), type(i));
        end
    case 'xy'
        for i = 1: length(x)
            fprintf(fid,'%d %f %f %f %d\n', i, x(i), y(i), h(i), type(i));
        end
    end
    
    % cells
    fprintf(fid,'%d %d %d\n', length(nv), 3, 21);
    for i = 1: length(nv)
        fprintf(fid,'%d %d %d %d\n', i, nv(i,1), nv(i,2), nv(i,3));
    end

    fclose(fid);
end

