function [x, y, nv, h, ob, lb, tail, id] = read_sms_grd(fin, varargin)
    %       Read SMS .grd file  -- ascii
    % =================================================================================================================
    % Parameter:
    %       fin: input file name                  || required: True  || type: text      ||  example: './x.grd'
    %       varargin: (optional)
    %           INFO: whether to disp info        || required: False || type: struct    ||  example: 'INFO'
    %           method: read method               || required: False || type: struct    ||  example: 'rewind' or 'ctu'
    % =================================================================================================================
    % Returns:
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                 (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       ob: open boundary nodes  (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5],[1,2,3]}
    %       lb: land boundary nodes  (optional)   || required: False || type: cell      ||  example: {[1,2,3,4,5],[1,2,3]}
    %       tail: tail of file       (optional)   || required: False || type: cell      ||  example: {{},{}}
    %       id: node id              (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    % =================================================================================================================
    % Update:
    %       2024-03-15:     Created (just number of boundries == 0), by Christmas;
    %       2024-04-02:     Added reading open boundary and land boundary,  by Christmas;
    %       2024-04-02:     Added tail,  by Christmas;
    % =================================================================================================================
    % Example:
    %       [x, y, nv, h, ob, lb, tail, id] = read_sms_grd('./input_mesh.grd');
    %       [x, y, nv, h, ob, lb, tail, id] = read_sms_grd('./input_mesh.grd', 'INFO');
    %       [x, y, nv, h, ob, lb, tail, id] = read_sms_grd('./input_mesh.grd', 'INFO', 'method', 'rewind');
    %       read_sms_grd('./input_mesh.grd', 'INFO');
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
    num_cell_node = textscan(fid, '%d %d', 1, 'headerlines', 1);
    length_cell = num_cell_node{1};
    length_node = num_cell_node{2};
    clear num_cell_node

    switch method
        case 'rewind'  % rewind
            % Read the data to get the x, y, h
            frewind(fid);
            ixyh = textscan(fid, '%d %f %f %f',length_node, 'headerlines', 2);
            % Read the data to get the nv
            frewind(fid);
            nvc = textscan(fid, '%d %d %d %d %d',length_cell, 'headerlines', 2+length_node);
        case 'ctu'  % continue
            ixyh = textscan(fid, '%d %f %f %f',length_node);
            nvc = textscan(fid, '%d %d %d %d %d',length_cell);
        otherwise
            error("  Method not supported! \n " + ...
                  " Method must 'rewind' or 'ctu'%s", '.');
    end

    id = ixyh{1};
    x = ixyh{2};
    y = ixyh{3};
    h = ixyh{4};
    clear ixyh

    nv = [nvc{3} nvc{4} nvc{5}];

    iline = 2+length_node+length_cell;

    % open boundaries
    frewind(fid);
    N_ob = textscan(fid, '%d %s %s %s %s %s',1, 'headerlines', iline);
    if N_ob{1} == 0
        ob = {};
    else
        ob = cell(N_ob{1},1);
    end
    ob_all = textscan(fid, '%d %s %s %s %s %s %s %s',1);
    iline = iline+2;
    for i = 1 : length(ob)
        ob1 = textscan(fid, '%d %s %s %s %s %s %s %s %d',1);
        ob1_count = ob1{1};
        ob1_cell = textscan(fid,'%d',ob1_count);
        ob{i} = ob1_cell{1};
        iline = iline + 1 + ob1_count;
    end
    clear i N_ob ob_all ob1 ob1_count ob1_cell

    % land boundary
    N_lb = textscan(fid, '%d %s %s %s %s %s',1);
    if N_lb{1} == 0
        lb = {};
    else
        lb = cell(N_lb{1},1);
    end
    lb_all = textscan(fid, '%d %s %s %s %s %s %s %s',1);
    iline = iline+2;
    for i = 1 : length(lb)
        lb1 = textscan(fid, '%d %d %s %s %s %s %s %s %s %d',1);
        lb1_count = lb1{1};
        lb1_cell = textscan(fid,'%d',lb1_count);
        lb{i} = lb1_cell{1};
        iline = iline + 1 + lb1_count;
    end
    clear i N_lb lb_all lb1 lb1_count lb1_cell

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

