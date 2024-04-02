function write_sms_grd(fout, x, y, nv, h, ob, lb, options)
    %       Write SMS .grd file  -- ascii
    % =================================================================================================================
    % Parameter:
    %       fout: output file name                || required: True  || type: text      ||  example: './output_mesh.grd'
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                 (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       ob: open boundary nodes  (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5],[1,2,3]}
    %       lb: land boundary nodes  (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5],[1,2,3]}
    %       options: (optional)
    %           Coordinate: 'geo' or 'xy'         || required: False || type: text      ||  example: 'geo'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-03-05:     Created (just for importing to SMS), by Christmas;
    %       2024-03-15:     Add open boundary and land boundary (just number of boundries == 0)， by Christmas;
    %       2024-04-02:     Added check input, Fixed writing open boundary and land boundary,  by Christmas; 
    % =================================================================================================================
    % Example:
    %       write_sms_grd('./output_mesh.grd',x,y,nv)
    %       write_sms_grd('./output_mesh.grd',x,y,nv,h)
    %       write_sms_grd('./output_mesh.grd',x,y,nv,h,ob,lb)
    %       write_sms_grd('./output_mesh.grd',x,y,nv,"Coordinate",'geo')
    %       write_sms_grd('./output_mesh.grd',x,y,nv,h,"Coordinate",'geo')
    % =================================================================================================================

    arguments(Input)
        fout {mustBeTextScalar}
        x (:,1) {mustBeNumeric}
        y (:,1) {mustBeNumeric}
        nv (:,3) {mustBeNumeric}
        h (:,1)  = zeros(length(x),1);
        ob (:,1) {cell} = cell(0);
        lb (:,1) {cell} = cell(0);
        options.Coordinate = 'geo'
    end
    Coordinate = options.Coordinate;

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

    % 0 = Number of open boundaries
    fprintf(fid,'%d = Number of open boundaries \n', length(ob));

    % 0 = Total number of open boundary nodes
    fprintf(fid,'%d = Total number of open boundary nodes \n', sum(cellfun(@numel, ob)));

    if ~isempty(ob)
        icount = 1;
        for in1 = 1 : length(ob)
            ob_m = ob{in1};
            fprintf(fid,'%d = Number of nodes for open boundary %d \n', length(ob_m{1}), icount);
            for in2 = 1 :length(ob_m)
                fprintf(fid,'%d\n', ob_m{1});
            end
            icount = icount + 1;
        end
        clear icount ob_m in1 in2
    end

    % 0 = Number of land boundaries
    fprintf(fid,'%d = Number of land boundaries \n', length(lb));

    % 0 = Total number of land boundary nodes
    fprintf(fid,'%d = Total number of land boundary nodes \n', sum(cellfun(@numel, lb)));
    
    if ~isempty(lb)
        icount = 1;
        for in1 = 1 : length(lb)
            lb_m = lb{in1};
            fprintf(fid,'%d 0 = Number of nodes for land boundary %d \n', length(lb_m{1}), icount);
            for in2 = 1 :length(lb_m)
                fprintf(fid,'%d\n', lb_m{1});
            end
            icount = icount + 1;
        end
        clear icount ob_m in1 in2
    end

    fclose(fid);
end

