function rmfiles(varargin)
    %       Delete files or folders
    % =================================================================================================================
    % Parameter:
    %       varargin{n}: path of file or folder  || required: True || type: char || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created, by Christmas;
    %       2024-04-03:     Change exist to isfolder isfile(same as makedirs), by Christmas
    %       2024-04-03:     Fixed, can be delete folder, by Christmas
    % =================================================================================================================
    % Example:
    %       rmfiles(path1)
    %       rmfiles(path1,path2)
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin {mustBeTextScalar}
    end

    for num = 1: nargin
        file = strip(convertStringsToChars(varargin{num}));
        % if exist(file, 'file') || exist(file, 'dir')
        if isfolder(file)
            rmdir(file);
        elseif isfile(file)
            delete(file);
        end
    end

end
