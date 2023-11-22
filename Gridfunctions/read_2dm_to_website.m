function read_2dm_to_website(varargin)
    %       read 2dm file and write to website format
    % =================================================================================================================
    % Parameter:
    %       Global: whether is global grid  || required: False || type: logical || format: 'Global'
    % =================================================================================================================
    % Example:
    %       read_2dm_to_website()
    %       read_2dm_to_website('Global')
    % =================================================================================================================

    varargin = read_varargin2(varargin,{'Global'});

    file = read_conf('Grid_functions.conf','f2dmfile');
    osprints('INFO',file);
    [~,name,~]=fileparts(file);
    save_path = read_conf('Grid_functions.conf','save_path');
    save_path = del_separator(save_path);

    f = f_load_grid(file);

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
    Outputfile = [save_path,filesep,name,'.web'];
    osprints('INFO',Outputfile);
    fid = fopen(Outputfile,'w');
    fprintf(fid,['%12.8f',',', '%12.8f','%14.8f',',', '%12.8f','%14.8f',',', '%12.8f', '\n'],LL');
    fclose(fid);

end
