function ln(fin, fout)
    %       Simulate the ln command in linux
    % =================================================================================================================
    % Parameters:
    %       fin:    The file to be linked  || required: True  || type: Text || example: 'file1'
    %       fout:   The file to be created || required: True  || type: Text || example: 'file2'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-07-03:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       ln('/Users/christmas/Downloads/1.txt', '/Users/christmas/Downloads/2.txt')
    %       ln('C:\Users\christmas\Downloads\1.txt', 'C:\Users\christmas\Downloads\2.txt.lnk')
    % =================================================================================================================

    fin = convertStringsToChars(fin);
    fout = convertStringsToChars(fout);

    switch computer('arch')
    case {'win32','win64'}
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
        system(cmd);

    case {'glnxa64','maci64','maca64'}
        cmd = ['ln -s ', fin, ' ', fout];
        system(cmd);
    end
end
