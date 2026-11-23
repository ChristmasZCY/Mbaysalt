function ln(fin, fout, varargin)
    %       Simulate the ln command in linux
    % =================================================================================================================
    % Parameters:
    %       fin:    The file to be linked  || required: required   || type: Text || example: 'file1'
    %       fout:   The file to be created || required: required   || type: Text || example: 'file2'
    %   varargin: (optional)
    %       mode:   write mode             || required: positional || type: Text || example: 'O' or 'P'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-07-03:     Created,                            by Christmas;
    %       2024-09-19:     Added createSymbolicLink(>=R2024b), by Christmas;
    %       2026-11-22:     Legacy links without shell,         by Christmas;
    %       2026-11-22:     Not append .lnk twice on Windows,   by Christmas;
    % =================================================================================================================
    % Example:
    %       ln('/Users/christmas/Downloads/1.txt', '/Users/christmas/Downloads/2.txt')
    %       ln('/Users/christmas/Downloads/1.txt', '/Users/christmas/Downloads/2.txt', 'O')
    %       ln('C:\Users\christmas\Downloads\1.txt', 'C:\Users\christmas\Downloads\2.txt.lnk')
    % =================================================================================================================
    % References:
    %       WIN:
    %           $shell = New-Object -ComObject WScript.Shell
    %           $desktop = [System.Environment]::GetFolderPath('Desktop')
    %           $shortcut = $shell.CreateShortcut("$desktop\clickme.lnk")
    %           $shortcut.TargetPath = "calc.exe"
    %           $shortcut.IconLocation = "shell32.dll,23"
    %           $shortcut.Save()
    %
    % =================================================================================================================

    narginchk(2, 3)

    if nargin == 2
        mode = 'P';
    else
        mode = varargin{1};
        varargin(1) = [];
    end

    if ~strcmpi(mode, 'O') && ~strcmpi(mode, 'P')
        error('Mode must be ''O'' or ''P''!')
    end

    fin = convertStringsToChars(fin);
    fout = convertStringsToChars(fout);

    legacy = isMATLABReleaseOlderThan("R2024b");
    if ispc && ~endsWith(fout, '.lnk', 'IgnoreCase', true)
        fout = [fout, '.lnk'];
    end
    protect = strcmpi(mode, 'P');
    if protect && (isfile(fout) || isfolder(fout))
        error('ln:Exists', '%s is existing!', fout);
    end
    if ~legacy
        if protect
            createSymbolicLink(fout, fin);
        else
            createSymbolicLink(fout, fin, "ReplacementRule", "overwrite");
        end
        return
    end

    % Legacy POSIX links retain a relative target. Windows .lnk uses the COM path API.
    workingDir = java.io.File(pwd).toPath();
    dest = workingDir.resolve(java.io.File(fout).toPath());
    attributes = javaArray('java.nio.file.attribute.FileAttribute', 0);
    if protect && ~ispc
        java.nio.file.Files.createSymbolicLink(dest, java.io.File(fin).toPath(), attributes);
        return
    end
    staging = java.nio.file.Files.createTempDirectory(dest.getParent(), '.mbaysalt-link-', attributes);
    link = staging.resolve(dest.getFileName());
    cleanup = onCleanup(@() clean_stage(link, staging)); %#ok<NASGU>
    if ispc
        shell = actxserver('WScript.Shell');
        release = onCleanup(@() delete(shell)); %#ok<NASGU>
        shortcut = invoke(shell, 'CreateShortcut', char(link.toString()));
        shortcut.TargetPath = char(workingDir.resolve(java.io.File(fin).toPath()).toString());
        invoke(shortcut, 'Save');
    else
        java.nio.file.Files.createSymbolicLink(link, java.io.File(fin).toPath(), attributes);
    end
    if protect
        java.nio.file.Files.move(link, dest, javaArray('java.nio.file.CopyOption', 0));
    else
        opts = javaArray('java.nio.file.CopyOption', 2);
        opts(1) = java.nio.file.StandardCopyOption.ATOMIC_MOVE;
        opts(2) = java.nio.file.StandardCopyOption.REPLACE_EXISTING;
        java.nio.file.Files.move(link, dest, opts);
    end
end

function clean_stage(link, staging)
    % Remove the staging link itself and its empty directory without following the link.
    java.nio.file.Files.deleteIfExists(link);
    java.nio.file.Files.deleteIfExists(staging);
end
