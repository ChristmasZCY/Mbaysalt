function write_sms_grd(fout, x, y, nv, h, options)
    %       Write SMS .grd file  -- ascii
    % =================================================================================================================
    % Parameter:
    %       fout: output file name                || required: True  || type: text      ||  example: './output_mesh.vtk'
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                              || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       options: (optional)
    %           Coordinate: 'geo' or 'xy'         || required: False || type: text      ||  example: 'geo'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-03-05:     Created, by Christmas (just for importing to SMS);
    % =================================================================================================================
    % Example:
    %       write_vtk('./output_mesh.vtk',x,y,nv)
    %       write_vtk('./output_mesh.vtk',x,y,nv,h)
    %       write_vtk('./output_mesh.vtk',x,y,nv,"Coordinate",'geo')
    %       write_vtk('./output_mesh.vtk',x,y,nv,h,"Coordinate",'geo')
    % =================================================================================================================
    % =================================================================================================================

    arguments(Input)
        fout {mustBeTextScalar}
        x (:,1) {mustBeNumeric}
        y (:,1) {mustBeNumeric}
        nv (:,3) {mustBeNumeric}
        h (:,1)  = zeros(length(x),1);
        options.Coordinate = 'geo'
    end
    Coordinate = options.Coordinate;

    switch(min(nv(:)))
    case 1
    otherwise
        error('Wrong nv!')
    end
       
    fid = fopen(fout,'w');
    fprintf(fid,'ADCIRC Model\n');
    fprintf(fid,'%d %d\n', length(nv), length(x));
    
    % points
    switch lower(Coordinate)
    case 'geo'
        for i = 1: length(x)
            fprintf(fid,'%d %f %f %f\n', i, x(i), y(i), h(i));
        end
    case 'xy'
        for i = 1: length(x)
            fprintf(fid,'%d %f %f %f\n', i, x(i), y(i), h(i));
        end
    end
    
    % cells
    for i = 1: length(nv)
        fprintf(fid,'%d %d %d %d %d\n', i, 3, nv(i,1), nv(i,2), nv(i,3));
    end

    fclose(fid);
end

