function osprints(log,varargin)
    %       print the string to the screen with INFO\WARING and so on.
    % =================================================================================================================
    % Parameter:
    %       log: message of log                   || required: True  || type: char or string ||  format: 'INFO', 'WARING', 'ERROR'
    %       varargin{1}: string to be printed     || required: True  || type: char or string ||  format: 'hello world'
    %       varargin{2}: wrfile                   || required: False || type: char or string ||  format: 'wrfile'
    %       varargin{3}: file of wrfile           || required: False || type: char or string ||  format: 'log.txt'
    % =================================================================================================================
    % Example:
    %       osprints('INFO', 'hello world')
    %       osprints('DEBUG', 'hello world')
    %       osprints('ERROR', 'hello world')
    %       osprints('WARNING', 'hello world', 'wrfile', 'log.txt')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'wrfile'},{false});
    varargin = read_varargin(varargin,{'new_line'},{true});
    varargin = read_varargin(varargin,{'ddt_log'},{true});

    ddt = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));

    ddt_disp = [ddt,' ---> '];
    log_disp = sprintf('[%s] ',log);
    mess_disp = [varargin{1},' '];

    switch log
        case 'WARNING'
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

    if ~wrfile
        if ddt_log
            cprintf('text',ddt_disp);
            cprintf(color_l,log_disp);
        end
        cprintf(color_m, mess_disp);
        if new_line
            cprintf('\n');
        end
    else
        fid = fopen(wrfile,'a+');
        % 判断是否是从头一行的开头开始写入
        if new_line
            if fid > 0
                cont = readlines(wrfile);
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
