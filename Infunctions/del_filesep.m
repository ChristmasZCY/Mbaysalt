function varargout = del_filesep(varargin)
    %       Delete the last '/' from a path
    % =================================================================================================================
    % Parameters:
    %       varargin: path                     || required: True  || type: Text ||  example: '/home/xxx/xxx/'
    % =================================================================================================================
    % Returns:
    %       varargout: path without last '/'   || required: True  || type: Text ||  example: '/home/xxx/xxx'
    % =================================================================================================================
    % Example:
    %       path = del_filesep('/home/xxx/xxx/')
    %       [path1,path2] = del_filesep('/home/xxx/xxx', '/home/xxx/yyy/')
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin
    end

    arguments(Output,Repeating)
        varargout
    end

    varargout = cellfun(@zeros,cell(1:nargin),'UniformOutput',false);

    for i = 1 : nargin
        varargin{i} = convertStringsToChars(varargin{i});
        % if ~ischar(varargin{i})
        %     varargin{i} = char(varargin{i});
        % end
        if varargin{i}(end) == filesep
            varargout{i} = varargin{i}(1:end-1);
        else
            varargout{i} = varargin{i};
        end
    end

end
