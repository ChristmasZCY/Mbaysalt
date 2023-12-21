function varargout = KeyValue2Struct(key_cell,value_cell,key_searched)
    %       Convert keys and values to struct
    % =================================================================================================================
    % Parameter:
    %       key_cell: key of struct               || required: True || type: cell   || example: {"key1","key2"}
    %       value_cell: value of struct           || required: True || type: cell   || example: {"value1","value2"}
    %       key_searched: searched key            || required: False|| type: text.  || example: "key1"
    % =================================================================================================================
    % Returns:
    %       varargout: 
    %         nargin == 2:
    %           struct                            || required: True || type: struct || example: struct('key1','value1','key2','value2')
    %           struct with fields name and value || required: True || type: struct || example: struct('name',{'key1','key2'},'value',{'value1','value2'})'
    %         nargin == 3:
    %           value of varargin                 || required: False|| type: string || example: "value1"
    %           struct                            || required: True || type: struct || example: struct('key1','value1','key2','value2')
    %           struct with fields name and value || required: True || type: struct || example: struct('name',{'key1','key2'},'value',{'value1','value2'})'
    % =================================================================================================================
    % Example:
    %       Struct = KeyValue2Struct(key_cell,value_cell);
    %       [value1,Struct] = KeyValue2Struct(key,value,'key1');  
    %       [a,b,c] = KeyValue2Struct({'a','b'},{1,2},'a');
    % =================================================================================================================

    % No need arguments

    if nargin > 2
        key_searched = convertStringsToChars(key_searched);
    end

    key_cell = cellfun(@(Key) StartWith_digit(Key, 'f'), key_cell, 'UniformOutput', false);
    key_cell = cellfun(@(Key) convertStringsToChars(Key), key_cell, 'UniformOutput', false);
    key_cell = matlab.lang.makeUniqueStrings(key_cell, {}, namelengthmax);
    D = [key_cell;value_cell]';
    varargout{1} = cell2struct(value_cell,key_cell,2);
    fields = {'name', 'value'};
    varargout{2} = cell2struct(D, fields, 2);
    if nargin > 2
        varargout{3} = varargout{2};
        varargout{2} = varargout{1};
        if ~ isfield(varargout{1}, key_searched)
            varargout{1} = '';
            warning('Key "%s" not found in struct', key_searched);
        else
            varargout{1} = varargout{1}.(key_searched);
        end
    end


    function Key = StartWith_digit(Key,pre)
        if isstrprop(Key, 'digit')
            Key = [pre , Key];
        end
    end

end
