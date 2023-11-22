function [x, y, nv, h, ns]=read_msh(fin,varargin)
    %       Read the msh file
    % =================================================================================================================
    % Parameter:
    %       fin: file name of the msh file                       || required: True  || type: string ||  format: string
    %       Nodisp: if display the information of the msh file   || required: False || type: string ||  format: string
    %       x: x coordinate of the grid point                    || required: True  || type: double ||  format: matrix
    %       y: y coordinate of the grid point                    || required: True  || type: double ||  format: matrix
    %       nv: triangle connectivity of the grid point          || required: True  || type: double ||  format: matrix
    %       h: depth of the grid point                           || required: True  || type: double ||  format: matrix
    %       ns: open boundary of the grid point                  || required: True  || type: double ||  format: matrix
    % =================================================================================================================
    % Example:
    %       [x, y, nv, h, ns]=read_msh('test.msh')
    %       [x, y, nv, h, ns]=read_msh('test.msh','Nodisp')
    % =================================================================================================================

    varargin = read_varargin2(varargin,{'Nodisp'});

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
    clear k_StartEles k_EndEles
    k_ns = isnan(data{7});
    ns = data{6}(k_ns);
    nv = [data{7}(length(ns)+1:end), ...
        data{8}(length(ns)+1:end), ...
        data{9}(length(ns)+1:end)];
    clear k_ns

    % check if error
    if node ~= length(x)
        error('read %s error', fin)
    end
    
    if e_n ~= size(nv, 1) + length(ns)
        error('read %s error', fin)
    end
    clear node ele
    fclose(fid);
    clear fid data
    

    if isempty(Nodisp)
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
