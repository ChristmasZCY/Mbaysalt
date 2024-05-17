function [x,y,nv,z,cell_type,cell_data] = read_vtk(fin,varargin)
    %       Read vtk file(*.vtk) and return the data -- ascii
    % =================================================================================================================
    % Parameter:
    %       fin: input file name     || required: True || type: string         ||  example: './output_mesh.vtk'
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       x: x coordinate          || required: True || type: 1D array       ||  example: [1,2,3,4,5]
    %       y: y coordinate          || required: True || type: 1D array       ||  example: [1,2,3,4,5]
    %       nv: cell around node     || required: True || type: 2D array       ||  format:  [:,3]
    %       z: z coordinate          || required: True || type: 1D array       ||  example: [1,2,3,4,5]
    %       cell_type: cell type     || required: True || type: 1D array       ||  example: [1,2,3,4,5]
    %       cell_data: cell data     || required: True || type: 1D array       ||  example: [1,2,3,4,5]
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       [x,y,nv,z,cell_type,cell_data] = read_vtk('./output_mesh.vtk','INFO')
    %       [x,y,nv] = read_vtk('./output_mesh.vtk','INFO')
    %       [x,y,nv] = read_vtk('./output_mesh.vtk')
    %       read_vtk('./output_mesh.vtk');
    % =================================================================================================================
    % Explains: (https://vtk.org/wp-content/uploads/2015/04/file-formats.pdf)
    %        1 --> vertex                2 --> poly vertex               3 --> line
    %        4 --> poly line             5 --> triangle                  6 --> triangle strip
    %        7 --> polygon               8 --> pixel                     9 --> quad
    %       10 --> tetra                11 --> voxel                    12 --> hexahedron
    %       13 --> wedge                14 --> pyramide                 15 --> pentagonal prism
    %       16 --> hexagonal prism
    % =================================================================================================================


    arguments (Input)
        fin (1,:) % {mustBeFile}  
    end
    arguments (Repeating)
        varargin
    end

    varargin = read_varargin2(varargin, {'INFO'});

    fid=fopen(fin);
    
    % == Read the data to find the line #
    data = textscan(fid, '%s', 'Delimiter','\n');
    
    k_POINTS = find(contains(data{1},'POINTS '));
    k_CELLS = find(contains(data{1},'CELLS '));
    k_CELLT = find(contains(data{1}, 'CELL_TYPES '));
    k_CELLD = find(contains(data{1}, 'CELL_DATA '));

    
    % == Read lon lat
    frewind(fid);
    points = textscan(fid, '%f %f %f', k_CELLS-k_POINTS, ...
        'headerlines', k_POINTS(1));
    x = points{1};
    y = points{2};
    z = points{3};
    
    % == Read nv
    frewind(fid);
    cells = textscan(fid, '%d %d %d %d ', k_CELLT-k_CELLS-2, ...
        'headerlines', k_CELLS(1));
    nv = [cells{2},cells{3},cells{4}];
    if min(nv(:)) >1 || max(nv(:)) > length(x)
        error('Wrong nv!')
    elseif min(nv(:)) == 0
        nv = nv + 1;
    end
    
    % == Read cell type
    frewind(fid);
    cellt = textscan(fid, '%d', k_CELLD-k_CELLT-2, ...
        'headerlines', k_CELLT(1));
    cell_type = cellt{1};
    
    % == Read cell data
    frewind(fid);
    celld = textscan(fid, '%s', length(data{1})-k_CELLT, ...
        'headerlines', k_CELLD(1)+2);
    cell_data = celld{1};
    fclose(fid);
    clear k_* fid data cells points cellt celld
    
    if nargout == 0
        assignin('caller','x',x);
        assignin('caller','y',y);
        assignin('caller','nv',nv);
    end

    if ~isempty(INFO)
        disp(' ')
        disp('------------------------------------------------')
        disp(['VTK file: ' fin])
        disp(['Node #: ' num2str(length(x))])
        disp(['Cell #: ' num2str(size(nv,1))])
        disp(['x range: ' num2str(min(x)) ' ~ ' num2str(max(x))])
        disp(['y range: ' num2str(min(y)) ' ~ ' num2str(max(y))])
        disp(['z range: ' num2str(min(z)) ' ~ ' num2str(max(z))])
        disp('------------------------------------------------')
        disp(' ')
    end
end


