function read_2dm_to_website(fin, fout, varargin)
    %       Read 2dm file and write to website format
    % =================================================================================================================
    % Parameter:
    %       Global: whether is global grid  || required: False || type: logical || format: 'Global'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created,    by Christmas;
    %       2024-01-31:     Change read arguments from parameter,   by Christmas;
    % =================================================================================================================
    % Example:
    %       read_2dm_to_website('/Users/christmas/Desktop/项目/网格/ECS/ECS_9/ECS_9(msl).2dm','./ECS_9(msl).web')
    %       read_2dm_to_website('/Users/christmas/Desktop/项目/网格/ECS/ECS_9/ECS_9(msl).2dm','./ECS_9(msl).web','Global')
    % =================================================================================================================

    varargin = read_varargin2(varargin,{'Global'});

    osprint2('INFO',fin);

    f = f_load_grid(fin);

    if isempty(Global)
        for i = 1 : length(f.nv)
            for j = 1 : 3
                F.Lon(i,j) = f.LON(f.nv(i,j));
                F.Lat(i,j) = f.LAT(f.nv(i,j));
            end
        end

    else
        f_h = f_2d_mesh(f,'Global');
        F.Lon = f_h.XData';
        F.Lat = f_h.YData';
        clf;close
    end

    LL = [F.Lon(:,1),F.Lat(:,1),F.Lon(:,2),F.Lat(:,2),F.Lon(:,3),F.Lat(:,3)];
    clear i j

    % write to website format
    [fout_path, name, ~] = fileparts(fout);
    if ~contains(fout,'/')
        fout_path = pwd;
    end
    makedirs(fout_path);
    if ~endsWith(fout_path, '.web')
        fout = [fout_path, filesep, name, '.web'];
    end
    osprint2('INFO',fout);
    fid = fopen(fout,'w+');
    fprintf(fid, '%.8f, %.8f  %.8f, %.8f  %.8f, %.8f\n',LL');
    % fprintf(fid,['%12.8f',',', '%12.8f','%14.8f',',', '%12.8f','%14.8f',',', '%12.8f', '\n'],LL');
    fclose(fid);
    return
end
