function [list_content,line_id] = grep(file, text)
    %       Simulation of unix grep command
    % =================================================================================================================
    % Parameters:
    %       file: full path of the file   || required: True  || type: text   || example: "xxxx/xxxx/xxxx"
    %       text: text to match           || required: True  || type: text   || example: "xxxx"
    % =================================================================================================================
    % Returns:
    %       list_content: matched line    || required: True  || type: cell   || example: {'Method_interpn =  Siqi_ESMF'}
    %       line_id: matched in file line || required: False || type: double || example: [1]
    % =================================================================================================================
    % Example:
    %       [list_content,line_id] = grep("Post_fvcom.conf",'Method')
    % =================================================================================================================

    arguments(Input)
        file % {mustBeFile}  %环境变量中也可
        text {mustBeTextScalar}
    end

    arguments(Output)
        list_content {cell}
        line_id {double}
    end

    % warning('This function is not recommend');

    file = convertStringsToChars(file);
    text = convertStringsToChars(text);
    fid = fopen(file, 'r');
    if fid == -1
        error('Cannot open file: %s', file);
    end
    line_number = 0;
    list_content = {};
    line_id = [];
    %-fgets 和 fgetl ： 可从文件读取信息
    while feof(fid) == 0
        line = fgetl(fid);
        if contains(line,text)
            line = strip(line);
            if  ~ startsWith(line,"#")
            % -输出格式： 行号，对应行内容
                % fprintf('%d: %s \n', line_number,line);
                list_content =[list_content;line];
                line_id = [line_id;line_number + 1];
            end
        end
        line_number = line_number + 1;
    end
    fclose(fid);

end
