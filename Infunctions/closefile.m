function S = closefile()
    %       Close all opened files.
    % =================================================================================================================
    % Parameters:
    %       None
    % =================================================================================================================
    % Returns:
    %       S: Structs of opened files.  || required: False  || type: struct ||  example: 
    % =================================================================================================================
    % Update:
    %       2024-03-25:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       closefile
    % =================================================================================================================
    
    fids = openedFiles();  % fopen('all')

    S = struct('filename', {}, 'permission', {}, 'machinefmt', {}, 'encodingOut', {});

    for i = 1:length(fids)
        [S(i).filename, S(i).permission, S(i).machinefmt, S(i).encodingOut] = fopen(fids(i));
    end

    fclose('all');
end
