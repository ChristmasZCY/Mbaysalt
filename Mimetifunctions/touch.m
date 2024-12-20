function varargout = touch(fin)
    %       touch command line
    % =================================================================================================================
    % Parameter:
    %       fin:    file name   || required: True  || type: Text  || example: '~/test.md'
    % =================================================================================================================
    % Returns:
    %       fin:    file id     || required: False || type: file  || example: '/home/ocean/test.md'
    % =================================================================================================================
    % Update:
    %       2024-12-20: Created,    by Christmas;
    % =================================================================================================================
    % Example:
    %       touch ~/test.md
    %       touch('~/test.md');
    %       fin = touch('~/test.md');
    % =================================================================================================================


    if startsWith(fin, '~/')
        HOME = getHome();
        fin = replace(fin, '~/', [HOME, filesep]);
    end
    
    path = fileparts(fin);  % get the path of the file
    makedirs(path);       % create the path if it does not exist

    fid = fopen(fin,"A+");
    fclose(fid);

    if nargout > 0 
        varargout{1} = fin;
    end

end
