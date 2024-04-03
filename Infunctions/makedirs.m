function makedirs(varargin)
    %       Check whether the path exists, if not, create it
    % =================================================================================================================
    % Parameters:
    %       varargin{n}: path of folders        || required: True || type: char    || example: 'D:\data\mask.nc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created, by Christmas;
    %       2024-04-02:     Added strip, by Christmas;
    %       2024-04-03:     Change exist to isfolder, because of exist will search at PATH, by Christmas
    % =================================================================================================================
    % Example:
    %       makedirs(path1)
    %       makedirs(path1,path2)
    % =================================================================================================================
    
    arguments(Input,Repeating)
        varargin
    end

    for num = 1: nargin
        % if ~exist(varargin{num},'dir') && ~isempty(varargin{num})
        dir1 = strip(convertStringsToChars(varargin{num}));
        if ~isfolder(dir1) && ~isempty(dir1)
            mkdir(dir1);
        end
    end

end
