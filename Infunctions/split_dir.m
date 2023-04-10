function f4 = split_dir(dir)
    % =================================================================================================================
    % discription:
    %       split the dir string from the status file with "grep" function
    % =================================================================================================================
    % parameter:
    %       dir: dir string from the status file  || required: True || type: string || format: "xxxx"
    %       f4: the matched line                  || required: True || type: string || format: "xxxx"
    % =================================================================================================================
    % example:
    %       file_ncmask = split_dir(file);
    % =================================================================================================================

    f1 = strip(dir);
    if endsWith(f1,",")
        f1 = split(dir,',')
        f1 = f1{1};
    end

    f2 = split(f1,'=');
    f3 = split(strip(f2{2}),"'");
    f3 = (f3{end});
    F = strfind(f3,"#");

    if ~ isempty(F)
        f3 = strip(f3(1:F-1));
    end
    f4 = split(f3," ");
    f4 = f4{end};

end

