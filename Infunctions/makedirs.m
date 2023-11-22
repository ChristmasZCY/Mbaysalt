function makedirs(varargin)
    %       check whether the path exists, if not, create it
    % =================================================================================================================
    % Parameter:
    %       varargin{n}: path of folders        || required: True || type: char    || format: 'D:\data\mask.nc'
    % =================================================================================================================
    % Example:
    %       makedirs(path1,path2)
    % =================================================================================================================

    for num = 1: nargin
        if ~exist(varargin{num},'dir') && ~isempty(varargin{num})
            mkdir(varargin{num});
        end
    end

end
