function rmfiles(varargin)
    %       Delete files or folders
    % =================================================================================================================
    % Parameter:
    %       varargin{n}: path of file or folder  || required: True || type: char || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Example:
    %       rmfiles(path1)
    %       rmfiles(path1,path2)
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin {mustBeTextScalar}
    end

    for num = 1: nargin
        file = convertStringsToChars(varargin{num});
        if exist(file, 'file') || exist(file, 'dir')
            delete(file);
        end
    end

end
