function makedirs(varargin)
    %       Check whether the path exists, if not, create it
    % =================================================================================================================
    % Parameters:
    %       varargin{n}: path of folders        || required: True || type: char    || example: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Example:
    %       makedirs(path1,path2)
    % =================================================================================================================
    
    arguments(Input,Repeating)
        varargin
    end

    for num = 1: nargin
        if ~exist(varargin{num},'dir') && ~isempty(varargin{num})
            mkdir(varargin{num});
        end
    end

end
