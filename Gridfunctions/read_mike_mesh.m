function [x, y, nv, h, bounds, prj, tail, id] = read_mike_mesh(fin, varargin)
    %       Read MIKE21 .mesh file  -- ascii
    % =================================================================================================================
    % Parameter:
    %       fin: input file name                  || required: True  || type: text      ||  example: './x.mesh'
    %       varargin: (optional)
    %           INFO: whether to disp info        || required: False || type: struct    ||  example: 'INFO'
    % =================================================================================================================
    % Returns:
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                 (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       bounds: boundary nodes   (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5]}
    %       tail: tail of file       (optional)   || required: False || type: cell      ||  example: {{},{}}
    %       prj:  projection         (optional)   || required: False || type: string    ||  example: ''
    %       id: node id              (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    % =================================================================================================================
    % Update:
    %       2024-04-03:     Created , by Christmas;
    % =================================================================================================================
    % Example:
    %       [x, y, nv, h, bounds, prj, tail, id] = read_mike_mesh('./input_mesh.mesh');
    %       [x, y, nv, h, bounds, prj, tail, id] = read_mike_mesh('./input_mesh.mesh', 'INFO');
    %       [x, y, nv, h, bounds, prj, tail, id] = read_mike_mesh('./input_mesh.mesh', 'INFO');
    %       read_mike_mesh('./input_mesh.mesh', 'INFO');
    % =================================================================================================================
    
    arguments(Input)
        fin (1,:) % {mustBeFile}
    end
    
    arguments(Input, Repeating)
        varargin
    end
    
    varargin = read_varargin2(varargin, {'INFO'});
    varargin = read_varargin(varargin, {'method'}, {'rewind'});

    fid = fopen(fin);

    % data = textscan(fid, '%s', 'Delimiter','\n');

    frewind(fid);
    num_node = textscan(fid, '%d %s', 1, 'headerlines', 0);
    length_node = num_node{1};
    prj = num_node{2}{1};
    clear num_node

    % Read the data to get the x, y, h, type
    frewind(fid);
    ixyht = textscan(fid, '%d %f %f %f %d',length_node, 'headerlines', 1);

    % Read the data to get the nv
    frewind(fid);
    num_cell = textscan(fid, '%d %d %d', 1, 'headerlines', 1+length_node);
    length_cell = num_cell{1};
    frewind(fid);
    nvc = textscan(fid, '%d %d %d %d',length_cell, 'headerlines', 2+length_node);
    clear num_cell

    id = ixyht{1};
    x = ixyht{2};
    y = ixyht{3};
    h = ixyht{4};
    type = ixyht{5};
    bounds = find(type~=0);
    bounds = {bounds};
    clear ixyht

    nv = [nvc{2} nvc{3} nvc{4}];

    iline = 2+length_node+length_cell;

    % tail
    tail = {};
    frewind(fid);
    for i = 1:iline
        fgetl(fid);
    end
    while ~feof(fid)
        tail{end+1} = fgetl(fid);  %#ok<AGROW>
    end
    tail = tail';

    clear nvc length_node length_cell
    fclose(fid);

    if nargout == 0
        assignin('caller','x',x);
        assignin('caller','y',y);
        assignin('caller','nv',nv);
    end
    
    if ~isempty(INFO)
        disp(' ')
        disp('------------------------------------------------')
        disp(['SMS_grd file: ' fin])
        disp(['Node #: ' num2str(length(x))])
        disp(['Cell #: ' num2str(size(nv,1))])
        disp(['x range: ' num2str(min(x)) ' ~ ' num2str(max(x))])
        disp(['y range: ' num2str(min(y)) ' ~ ' num2str(max(y))])
        disp(['h range: ' num2str(min(h)) ' ~ ' num2str(max(h))])
        disp('------------------------------------------------')
        disp(' ')
    end

end

