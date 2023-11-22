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

    for num = 1: nargin
        if exist(varargin{num}, 'file') || exist(varargin{num}, 'dir')
            delete(varargin{num});
        end
    end

end
