function fout = getPath(fin)
    %       Get file path of fin
    % =================================================================================================================
    % Parameter:
    %       fin:            file name              || required: True || type: char || format: 'fin.txt'
    % =================================================================================================================
    % Returns:
    %       fout:           file path              || required: True || type: char || format: '/Users/christmas/fin.txt'
    % =================================================================================================================
    % Update:
    %       2026-03-31:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       fout = getPath('fin.txt');
    %       fout = getPath('~/fin.txt');
    %       fout = getPath('./fin.txt');
    % =================================================================================================================

    fin = convertStringsToChars(fin);

    % 替换输入文件名中的'~/'为HOME路径
    if startsWith(fin, '~/')
        HOME = getHome();
        fin = replace(fin, '~/', [HOME, filesep]);
    end

    % 以./开头的相对路径，转换为绝对路径
    % 文件中不含有路径的情况，转换为当前路径下的文件
    if startsWith(fin, './') || ~contains(fin, filesep)
        fin = fullfile(pwd, fin);
    end

    fout = fin;

end
