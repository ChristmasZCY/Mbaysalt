function varargout = split_path(varargin)
    % =================================================================================================================
    % discription:
    %       Delete the last '/' from a path
    % =================================================================================================================
    % parameter:
    %       varargin: path                     || required: True  || type: char or string ||  format: '/home/xxx/xxx/'
    %       varargout: path without last '/'   || required: True  || type: char or string ||  format: '/home/xxx/xxx'
    % =================================================================================================================
    % example:
    %       path = split_path('/home/xxx/xxx/')
    %       [path1,path2] = split_path('/home/xxx/xxx', '/home/xxx/yyy/')
    % =================================================================================================================

    varargout = cellfun(@zeros,cell(1:nargin),'UniformOutput',false);

    for i = 1 : nargin
        if ~ischar(varargin{i})
            varargin{i} = char(varargin{i});
        end
        if varargin{i}(end) == filesep
            varargout{i} = varargin{i}(1:end-1);
        else
            varargout{i} = varargin{i};
        end
    end

end