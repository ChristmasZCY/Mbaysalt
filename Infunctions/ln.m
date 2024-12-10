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
    % =================================================================================================================
    % Example:
    %       ln('/Users/christmas/Downloads/1.txt', '/Users/christmas/Downloads/2.txt')
    %       ln('/Users/christmas/Downloads/1.txt', '/Users/christmas/Downloads/2.txt', 'O')
    %       ln('C:\Users\christmas\Downloads\1.txt', 'C:\Users\christmas\Downloads\2.txt.lnk')
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

    switch checkOS
    case {'WIN'}
        % $shell = New-Object -ComObject WScript.Shell
        % $desktop = [System.Environment]::GetFolderPath('Desktop')
        % $shortcut = $shell.CreateShortcut("$desktop\clickme.lnk")
        % $shortcut.TargetPath = "calc.exe"
        % $shortcut.IconLocation = "shell32.dll,23"
        % $shortcut.Save()
        if ~endsWith(fout, '.lnk') || ~endsWith(fout, '.url')
            fout = [fout, '.lnk'];
        end
        cmd = sprintf(['powershell -Command "', ...
            '$shell = New-Object -ComObject WScript.Shell; ', ...
            '$shortcut = $shell.CreateShortcut(''%s''); ', ...
            '$shortcut.TargetPath = ''%s'';  ', ...
            '$shortcut.Save()"'],fout,fin);
        disp(cmd);
    case {'MAC', 'LNX'}
        cmd = ['ln -s ', fin, ' ', fout];
    end

    switch upper(mode)
    case 'O'
    case 'P'
        if exist(fout,"file") || exist(fout, "dir")
            error('%s is existing!', fout)
        end
    end

    if ~isMATLABReleaseOlderThan("R2024b")
        createSymbolicLink(fout, fin,"ReplacementRule","overwrite");
    else
        system(cmd);
    end
end
