function [varargout] = grep(filename, pattern)
    % =================================================================================================================
    % discription:
    %       simulation of unix grep command
    % =================================================================================================================
    % parameter:
    %       filename: full path of the file  || required: True || type: string || format: "xxxx/xxxx/xxxx"
    %       pattern: pattern to match        || required: True || type: string || format: "xxxx"
    %       varargout: matched line          || required: True || type: string || format: "xxxx"
    % =================================================================================================================
    % example:
    %       file = grep(status_file,"MaskncFile");
    % =================================================================================================================

    fid = fopen(filename, 'r');
    line_number = 0;
    %-fgets 和 fgetl ： 可从文件读取信息
    while feof(fid) == 0
        line = fgetl(fid);
        if contains(line,pattern)
            line = strip(line);
            if  ~ startsWith(line,"#")
            % -输出格式： 行号，对应行内容
                % fprintf('%d: %s \n', line_number,line);
                varargout{1}=line;
            end
        end
        line_number = line_number + 1;
    end
    fclose(fid);

end
