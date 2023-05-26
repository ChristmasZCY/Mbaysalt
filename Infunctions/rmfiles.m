function rmfiles(varargin)
    % =================================================================================================================
    % discription:
    %       delete files or folders
    % =================================================================================================================
    % parameter:
    %       varargin{n}: path of file or folder  || required: True || type: char || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % example:
    %       rmfiles(path1)
    %       rmfiles(path1,path2)
    % =================================================================================================================

    for num = 1: nargin
        if exist(varargin{num}, 'file') || exist(varargin{num}, 'dir')
            delete(varargin{num});
        end
    end

end
