function [YN, Ofile] = readlink(file)
    %       Simulation of unix command "readlink"
    % =================================================================================================================
    % Parameters:
    %       file: path of file or folder            || required: True || type: char    || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       Ofile: Original file                    || required: True || type: char    || example: 'D:\data\mask.nc'
    %       YN: whether link or not                 || required: True || type: logical || example: 1
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                                        by Christmas;
    %       2024-04-16:     Added strip,                                    by Christmas;
    %       2024-04-16:     swap output order,                              by Christmas;
    %       2024-05-13:     Fixed opposite output, judge'file not found',   by Christmas;
    % =================================================================================================================
    % Example:
    %       [YN, Ofile] = readlink('D:\data\mask.nc')
    % =================================================================================================================

    arguments(Input)
        file {mustBeTextScalar}
    end

    arguments(Output)
        YN logical
        Ofile
    end

    file = convertStringsToChars(file);

    if startsWith(file, './') || ~contains(file, '/')
        file = fullfile(pwd, file);
    end

    if isempty(file) || (~exist(file,"file") && ~exist(file,"dir"))
        error('file not found')
    end

    switch computer('arch')
        case {'win32','win64'}
            cmd = sprintf('powershell -Command "(Get-Item -Path %s).Target"', file);  %% TODO: test
        case {'glnxa64','maci64','maca64'}
            cmd = ['readlink -f ', file];
        otherwise
            error('platform error')
    end
    [~, Ofile] = system(cmd);
    Ofile = strip(Ofile);
    if ~strcmp(file, Ofile)
        YN = true;
    else
        YN = false;
    end

end
