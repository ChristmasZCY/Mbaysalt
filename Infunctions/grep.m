function list = grep(file, text)
    %       Simulation of unix grep command
    % =================================================================================================================
    % Parameters:
    %       file: full path of the file  || required: True || type: text || example: "xxxx/xxxx/xxxx"
    %       text: text to match          || required: True || type: text || example: "xxxx"
    % =================================================================================================================
    % Returns:
    %       list: matched line           || required: True || type: cell || example: "xxxx"
    % =================================================================================================================
    % Example:
    %       file = grep("c_load_grid.m",'f_load_grid')
    % =================================================================================================================

    arguments(Input)
        file {mustBeFile}
        text {mustBeTextScalar}
    end

    arguments(Output)
        list {cell}
    end

    warning('This function is not recommend');

    file = convertStringsToChars(file);
    text = convertStringsToChars(text);
    fid = fopen(file, 'r');
    if fid == -1
        error('Cannot open file: %s', file);
    end
    line_number = 0;
    list = {};
    %-fgets 和 fgetl ： 可从文件读取信息
    while feof(fid) == 0
        line = fgetl(fid);
        if contains(line,text)
            line = strip(line);
            if  ~ startsWith(line,"#")
            % -输出格式： 行号，对应行内容
                % fprintf('%d: %s \n', line_number,line);
                list =[list;line];
            end
        end
        line_number = line_number + 1;
    end
    fclose(fid);

end
