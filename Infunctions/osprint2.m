function osprint2(level, message, options)
    %       print the string to the screen with INFO\WARING and so on.
    % =================================================================================================================
    % Parameter:
    %       level: level of log                   || required: True  || type: char or string ||  format: 'INFO', 'WARING', 'ERROR'
    %       message: message of log               || required: True  || type: char or string ||  format: 'hello world'
    %       varargin:
    %           output: output to file            || required: False || type: char or string ||  format: 'log.txt'
    %           new_line: new line                || required: False || type: logical        ||  format: true or false
    %           ddt_log: display datetime         || required: False || type: logical        ||  format: true or false
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Example:
    %       osprint2('INFO', 'hello world')
    %       osprint2('DEBUG', 'hello world')
    %       osprint2('ERROR', 'hello world')
    %       osprint2('WARNING', 'hello world', 'output', 'log.txt')
    %       osprint2('INFO', 'hello world', 'output', 'log.txt', 'new_line', false)
    %       osprint2('INFO', 'hello world', 'output', 'log.txt', 'ddt_log', false)
    %       osprint2('INFO', 'hello world', 'output', 'log.txt', 'new_line', false, 'ddt_log', false)
    % =================================================================================================================
    
    arguments(Input)
        level {mustBeMember(level,["DEBUG","INFO","WARNING","ERROR","CRACTICAL"])}
        message {mustBeTextScalar}
        options.output {mustBeTextScalar} = 'screen'
        options.newline {mustBeNonnegative} = true
        options.ddt_log {mustBeNonnegative} = true
    end

    level = convertStringsToChars(level);
    message = convertStringsToChars(message);

    output = options.output;
    newline = options.newline;
    ddt_log = options.ddt_log;

    ddt = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));

    ddt_disp = [ddt,' ---> '];
    log_disp = sprintf('[%s] ', level);
    mess_disp = [message,' '];

    switch level
        case {'WARNING','WARN'}
            color_l = '*[255, 165, 0]';
            color_m = [1,0.5,0];
        case 'INFO'
            color_l = '*blue';
            color_m = 'blue';
        case 'DEBUG'
            color_l = '*text';
            color_m = 'text';
        case 'ERROR'
            color_l = '*err';
            color_m = 'err';
        case 'CRITICAL'
            error('Catastrophic Accident')
        otherwise
            error('UNKOWN log mode')
    end

    if strcmp(output,'screen')
        if ddt_log
            cprintf('text',ddt_disp);
            cprintf(color_l,log_disp);
        end
        cprintf(color_m, mess_disp);
        if newline
            cprintf('\n');
        end
    else
        fid = fopen(output,'a+');
        % 判断是否是从头一行的开头开始写入
        if newline
            if fid > 0
                cont = readlines(output);
                if ~isempty(char(cont(end)))
                    fprintf(fid,'\n');
                end
            end
        end

        if ddt_log
            fprintf(fid,[ddt_disp, log_disp, mess_disp]);
        else
            fprintf(fid, mess_disp);
        end

        % fprintf(fid,'\n');
        fclose(fid);
    end
        
end
