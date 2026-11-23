function [YN, Ofile] = readlink(file)
    %       Simulation of unix command "readlink"
    % =================================================================================================================
    % Parameters:
    %       file: path of file or folder            || required: True || type: char    || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       YN: whether link or not                 || required: True || type: logical || example: 1
    %       Ofile: Original file                    || required: True || type: char    || example: 'D:\data\mask.nc'
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                                        by Christmas;
    %       2024-04-16:     Added strip,                                    by Christmas;
    %       2024-04-16:     swap output order,                              by Christmas;
    %       2024-05-13:     Fixed opposite output, judge'file not found',   by Christmas;
    %       2024-09-19:     Use isSymbolicLink(>=R2024b),                   by Christmas;
    %       2026-03-30:     Dealing with ~/ in input file,                  by Christmas;
    %       2026-11-22:     Legacy branch reads links without shell,        by Christmas;
    % =================================================================================================================
    % Example:
    %       [YN, Ofile] = readlink('D:\data\mask.nc')
    % =================================================================================================================

    arguments (Input)
        file {mustBeTextScalar}
    end

    arguments (Output)
        YN logical
        Ofile
    end

    file = getPath(file);

    if isempty(file) || (~exist(file, "file") && ~exist(file, "dir"))
        warning('file not found')
        YN = false;
        Ofile = file;
        return
    end

    if ~isMATLABReleaseOlderThan("R2024b")
        [YN, Ofile] = isSymbolicLink(file);

        if ~YN
            Ofile = file;
        end

        return
    end

    Ofile = file;
    linkPath = java.io.File(pwd).toPath().resolve(java.io.File(file).toPath());
    if ispc
        % % $lnkPath = "D:\Beihai(lonlat3).2dm.lnk"; $shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut($lnkPath); Write-Host "$($shortcut.TargetPath)"
        YN = endsWith(file, '.lnk', 'IgnoreCase', true);
        if YN
            shell = actxserver('WScript.Shell');
            cleanup = onCleanup(@() delete(shell)); %#ok<NASGU>
            shortcut = invoke(shell, 'CreateShortcut', char(linkPath.toString()));
            Ofile = char(shortcut.TargetPath);
        end
    else
        YN = java.nio.file.Files.isSymbolicLink(linkPath);
        if YN
            Ofile = char(linkPath.toRealPath(javaArray('java.nio.file.LinkOption', 0)).toString());
        end
    end
end
