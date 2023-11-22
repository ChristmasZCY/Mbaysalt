function varargout = del_separator(varargin)
    %       Delete the last '/' from a path
    % =================================================================================================================
    % Parameter:
    %       varargin: path                     || required: True  || type: char or string ||  format: '/home/xxx/xxx/'
    %       varargout: path without last '/'   || required: True  || type: char or string ||  format: '/home/xxx/xxx'
    % =================================================================================================================
    % Example:
    %       path = del_separator('/home/xxx/xxx/')
    %       [path1,path2] = del_separator('/home/xxx/xxx', '/home/xxx/yyy/')
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
