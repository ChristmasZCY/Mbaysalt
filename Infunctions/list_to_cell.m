function varargout =  list_to_cell(str,varargin)
    %       Convert str of python list format to matlab cell
    % =================================================================================================================
    % Parameter:
    %       str: str of python list format   || required: True || type: string || format: "['key1','key2','key3']"
    %       varargin: index of cell          || required: False|| type: int    || format: 1
    %       varargout: cell                  || required: False|| type: cell   || format: {'key1','key2','key3'}
    %       varargout: value                 || required: False|| type: string || format: 'key1'
    % =================================================================================================================
    % Example:
    %       C = list_to_cell(str)
    %       [value1, C] = list_to_cell(str,1)
    % =================================================================================================================

    str = str(2:end-1);
    cellstr = strsplit(str, ',');
    cellstr = strip(cellstr);
    cellstr = strip(cellstr, "'");
    cellstr = strip(cellstr, '"');
    varargout{1} = cell_del_empty(strip(cellstr));

    if nargin > 1
        varargout{2} = varargout{1};
        varargout{1} = varargout{2}{varargin{1}};
    end

    function C = cell_del_empty(C)
        C = C(~cellfun(@isempty, C));
    end

end
