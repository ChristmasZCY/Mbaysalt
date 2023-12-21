function varargout =  listStr_to_cell(str,index)
    %       Convert str of python list format to matlab cell
    % =================================================================================================================
    % Parameters:
    %       str: str of python list format   || required: True || type: string || example: "['key1','key2','key3']"
    %       index: index of cell             || required: False|| type: int    || example: 1
    % =================================================================================================================
    % Returns:
    %       varargout: 
    %         nargin == 1:
    %           cell                  || required: False|| type: cell   || example: {'key1','key2','key3'}
    %         nargin == 2:
    %           value                 || required: False|| type: string || example: 'key1'
    %           cell                  || required: False|| type: cell   || example: {'key1','key2','key3'}
    % =================================================================================================================
    % Example:
    %       C = listStr_to_cell(str)
    %       [value, C] = listStr_to_cell(str,1)
    % =================================================================================================================

    % No need arguments

    str = convertStringsToChars(str);
    str = str(2:end-1);
    cellstr = strsplit(str, ',');
    cellstr = strip(cellstr);
    cellstr = strip(cellstr, "'");
    cellstr = strip(cellstr, '"');
    varargout{1} = cell_del_empty(strip(cellstr));

    if nargin > 1
        varargout{2} = varargout{1};
        varargout{1} = varargout{2}{index};
    end

    function C = cell_del_empty(C)
        C = C(~cellfun(@isempty, C));
    end

end
