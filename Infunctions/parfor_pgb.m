classdef parfor_pgb < handle
    %       parfor progress bar
    % =================================================================================================================
    % Parameter:
    %       N:  num of parfor                   || required: True || type: double       || example: 50
    %       varargin:   (optional)
    %           LineN:  nextline print or not   || required: False|| type: namevalue    || example: 'LineN',false
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-12-20:     Created,    by Christmas;
    % =================================================================================================================
    % Example:
    %       clm
    %       hbar = parfor_pgb(100,'LineN',true);
    %       parfor i=1:100
    %           pause(rand);
    %           if mod(i,5) == 0
    %               hbar.iterate(5);   % update progress by one iteration
    %           end
    %       end
    %       hbar.close
    % =================================================================================================================

    properties
        N;  % 总迭代次数
        Nnum = 0;  % 迭代次数
        widthBar = 50;  % 宽度
        ipcfile = fullfile(tempdir, sprintf('%s%d.txt', mfilename, round(rand*1000))); % Path to temporary file for inter-process communication
        percent = 0;  % 0.99
        LineN = true;
    end


    methods
        function obj = parfor_pgb(N, varargin)
            varargin = read_varargin(varargin,{'LineN'},{obj.LineN});
            obj.LineN = LineN;
            obj.N = N;
            rmfiles(obj.ipcfile);
            touch(obj.ipcfile);
            disp(['[>', repmat(' ', 1, obj.widthBar), ']   0.0%']);
        end

        function iterate(obj, num)
            if nargin == 0
                num = 1;  % default
            end
            fid = fopen(obj.ipcfile,"a+");
            fprintf(fid, '%d\n', num);
            fclose(fid);

            fid = fopen(obj.ipcfile, 'r' );
            obj.Nnum = max(obj.Nnum,sum(fscanf(fid, '%d')));
            obj.percent = obj.Nnum / obj.N;
            obj.percent = max(0, min(1,obj.percent) );
            fclose(fid);
            perc = sprintf('% 6.1f%%', obj.percent*100);
            if obj.LineN
                txt = sprintf('[%s>%s]%s',repmat('=', 1, round(obj.percent*obj.widthBar)),repmat(' ', 1, obj.widthBar - round(obj.percent*obj.widthBar)),perc);
            else
                txt = sprintf('%s[%s>%s]%s',[repmat(char(8), 1, (obj.widthBar+12))],repmat('=', 1, round(obj.percent*obj.widthBar)),repmat(' ', 1, obj.widthBar - round(obj.percent*obj.widthBar)),perc);
            end
            disp(txt);

        end

        function close(obj)
            rmfiles(obj.ipcfile)
            w = obj.widthBar;
            disp([ '[', repmat('=', 1, w+1), '] 100.0%']);
        end
    end

end

