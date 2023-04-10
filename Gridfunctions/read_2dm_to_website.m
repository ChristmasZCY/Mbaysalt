function read_2dm_to_website(varargin)
    % =================================================================================================================
    % discription:
    %       read 2dm file and write to website format
    % =================================================================================================================
    % parameter:
    %       varargin: None  || required: False || type: X || format: X
    % =================================================================================================================
    % example:
    %       read_2dm_to_website()
    % =================================================================================================================

    file = read_conf('Grid_functions.conf','f2dmfile');
    osprints('INFO',file);
    [~,name,~]=fileparts(file);
    save_path = read_conf('Grid_functions.conf','save_path');
    save_path = split_path(save_path);

    f = f_load_grid(file);

    for i = 1 : length(f.nv)
        for j = 1 : 3
            F.Lon(i,j) = f.LON(f.nv(i,j));
            F.Lat(i,j) = f.LAT(f.nv(i,j));
        end
    end

    LL = [F.Lon(:,1),F.Lat(:,1),F.Lon(:,2),F.Lat(:,2),F.Lon(:,3),F.Lat(:,3)];
    clear i j

    % write to website format
    Outputfile = [save_path,filesep,name,'.web'];
    osprints('INFO',Outputfile);
    fid = fopen(Outputfile,'w');
    fprintf(fid,['%12.8f',',', '%11.8f','%13.8f',',', '%11.8f','%13.8f',',', '%11.8f', '\n'],LL');
    fclose(fid);
