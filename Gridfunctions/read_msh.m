function [x, y, nv, h, ns, tail, id] = read_msh(fin, varargin)
    %       Read the msh file
    % =================================================================================================================
    % Parameter:
    %       fin: input file name                  || required: True  || type: text      ||  example: './x.msh'
    %       varargin: (optional)
    %           INFO: whether to disp info        || required: False || type: struct    ||  example: 'INFO'
    % =================================================================================================================
    % Returns:
    %       x: x coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       y: y coordinate                       || required: True  || type: 1D array  ||  example: [1,2,3,4,5]
    %       nv: cell around node                  || required: True  || type: 2D array  ||  format:  [:,3]
    %       h: depth                 (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    %       ns: nesting              (optional)   || required: False || type: cell      ||  example: {[1,2,3,4]}
    %       tail: tail of file       (optional)   || required: False || type: cell      ||  example: {{},{}}
    %       id: node id              (optional)   || required: False || type: 1D array  ||  example: [1,2,3,4,5]
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2024-04-02:     Converted ns type to cell,  by Christmas;
    %       2024-04-02:     Added tail id output,   by Christmas;
    % =================================================================================================================
    % Example:
    %       [x, y, nv, h, ns, tail, id] = read_msh('test.msh')
    %       [x, y, nv, h, ns, tail, id] = read_msh('test.msh', 'INFO')
    % =================================================================================================================

    varargin = read_varargin2(varargin,{'INFO'});

    fid=fopen(fin);
    
    % Read the data to find the line #
    data = textscan(fid, '%s', 'Delimiter','\n');
    
    k_StartNotes = find(contains(data{1},'$Nodes'));
    k_EndNotes = find(contains(data{1},'$EndNodes'));
    k_StartEles = find(contains(data{1},'$Elements'));
    k_EndEles = find(contains(data{1},'$EndElements'));
    
    % Read the data to get the number of nodes
    frewind(fid);  % 光标跳转到开头
    data = textscan(fid, '%d', 1, 'headerlines', k_StartNotes);
    node = data{1};
    
    % Read the data to get the x, y, depth
    frewind(fid);  % 光标跳转到开头
    data = textscan(fid, '%d %f %f %f %f', k_EndNotes-k_StartNotes, ...
        'headerlines', k_StartNotes+1);
    clear k_StartNotes k_EndNotes
    id = data{1};
    x = data{2};
    y = data{3};
    h = data{4};
    
    % Read the data to get the number of elements
    frewind(fid);  % 光标跳转到开头
    data = textscan(fid, '%d', 1, 'headerlines', k_StartEles);
    e_n = data{1};
    
    % Read the data to get the open boundary
    frewind(fid);  % 光标跳转到开头
    data = textscan(fid, '%d %d %d %d %d %d %f %f %f %f', k_EndEles-k_StartEles, ...
        'headerlines', k_StartEles+1);

    k_ns = isnan(data{7});
    ns = data{6}(k_ns);
    ns = {ns};
    nv = [data{7}(length(ns{1})+1:end), ...
        data{8}(length(ns{1})+1:end), ...
        data{9}(length(ns{1})+1:end)];
    clear k_ns

    % tail
    iline = k_EndEles;
    tail = {};
    frewind(fid);
    for i = 1:iline
        fgetl(fid);
    end
    while ~feof(fid)
        tail{end+1} = fgetl(fid);  %#ok<AGROW>
    end
    tail = tail';

    clear k_StartEles k_EndEles

    % check if error
    if node ~= length(x)
        error('read %s error', fin)
    end
    
    if e_n ~= size(nv, 1) + length(ns{1})
        error('read %s error', fin)
    end
    clear node ele
    fclose(fid);
    clear fid data
    

    if ~isempty(INFO)
        disp(' ')
        disp('------------------------------------------------')
        disp(['msh file: ' fin])
        disp(['Node #: ' num2str(length(x))])
        disp(['Cell #: ' num2str(size(nv,1))])
        disp(['x range: ' num2str(min(x)) ' ~ ' num2str(max(x))])
        disp(['y range: ' num2str(min(y)) ' ~ ' num2str(max(y))])
        disp(['h range: ' num2str(min(h)) ' ~ ' num2str(max(h))])
        disp('------------------------------------------------')
        disp(' ')
    end


end
