function write_vtk(fout, x, y, nv, z, cell_type, cell_data, options)
    %       Write vtk file(.vtk) -- ascii
    % =================================================================================================================
    % Parameter:
    %       fout: output file name                || required: True  || type: text      ||  example: './output_mesh.vtk'
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       z: z coordinate                       || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       cell_type: cell type                  || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       cell_data: cell data                  || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       options: (optional)
    %           Coordinate: 'geo' or 'xy'         || required: False || type: text      ||  example: 'geo'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       write_vtk('./output_mesh.vtk',x,y,nv,z,cell_type,cell_data)
    %       write_vtk('./output_mesh.vtk',x,y,nv)
    %       write_vtk('./output_mesh.vtk',x,y,nv,"Coordinate",'geo')
    % =================================================================================================================
    % Explains: 
    %       https://www.zhihu.com/tardis/zm/art/273522056
    % =================================================================================================================

    arguments(Input)
        fout {mustBeTextScalar}
        x (:,1) {mustBeNumeric}
        y (:,1) {mustBeNumeric}
        nv (:,3) {mustBeNumeric}
        z (:,1)  = zeros(length(x),1);
        cell_type = ones([length(nv),1]) * 5
        cell_data = ones([length(nv),1])
        options.Coordinate = 'geo'
    end
    Coordinate = options.Coordinate;

    switch(min(nv(:)))
    case 0
    case 1
        nv = nv - 1;
    otherwise
        error('Wrong nv!')
    end
       
    fid=fopen(fout,'w');
    fprintf(fid,'%s\n','# vtk DataFile Version 2.0');
    fprintf(fid,'%s\n','Triangle mesh, created by write_vtk.m');
    fprintf(fid,'%s\n','ASCII');
    fprintf(fid,'%s\n','DATASET UNSTRUCTURED_GRID');
    fprintf(fid,'%s%10d%10s\n','POINTS',length(x),'double');
    
    % points
    switch lower(Coordinate)
    case 'geo'
        for j=1:length(x)
            if isequal(z,zeros(length(x),1))
                if isequal(z,zeros(length(x),1))
                    fprintf(fid,'%14.9f %13.9f %1d\n',x(j),y(j),z(j));
                else
                    fprintf(fid,'%14.9f %13.9f %13.9f\n',x(j),y(j),z(j));
                end
            else
            end
        end
    case 'xy'
        for j=1:length(x)
            if isequal(z,zeros(length(x),1))
                fprintf(fid,'%16.9f %16.9f %1d\n',x(j),y(j),z(j));
            else
                fprintf(fid,'%16.9f %16.9f %16.9f\n',x(j),y(j),z(j));
            end
        end
    end
    fprintf(fid,'\n');
    
    % cells
    fprintf(fid,'%s%8d%9d\n','CELLS',length(nv),(size(nv,2)+1)*length(nv));
    for j=1:length(nv)
        fprintf(fid,'%1d %8d %8d %8d \n',size(nv,2),nv(j,1),nv(j,2),nv(j,3));
    end
    
    % cell types
    fprintf(fid,'\n');
    fprintf(fid,'%s %8d\n','CELL_TYPES',length(cell_type));
    for j=1:length(nv)
        fprintf(fid,'%1d\n',cell_type(j));
    end
    
    % cell data
    fprintf(fid,'\n');
    fprintf(fid,'%s %8d\n','CELL_DATA',length(cell_data));
    fprintf(fid,'%s\n','SCALARS CellEntityIds int 1');
    fprintf(fid,'%s\n','LOOKUP_TABLE default');
    for j=1:length(nv)
        fprintf(fid,'%1d\n',cell_data(j));
    end
    fclose(fid);
end

