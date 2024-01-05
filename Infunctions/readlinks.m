function [Ofile, YN] = readlinks(file)
    %       Simulation of unix command "readlink"
    % =================================================================================================================
    % Parameters:
    %       file: path of file or folder            || required: True || type: char    || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       Ofile: Orignal file                     || required: True || type: char    || example: 'D:\data\mask.nc'
    %       YN: whether link or not                 || required: True || type: logical || example: 1
    % =================================================================================================================
    % Example:
    %       [Ofile, YN] = readlinks('D:\data\mask.nc')
    % =================================================================================================================

    arguments(Input)
        file {mustBeTextScalar}
    end

    arguments(Output)
        Ofile {mustBeFile}
        YN logical
    end

    file = which(file);
    if isempty(file)
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
    
    if ~strcmp(file, Ofile)
        YN = false;
    else
        YN = true;
    end

end
