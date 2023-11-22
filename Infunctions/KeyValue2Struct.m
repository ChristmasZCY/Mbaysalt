function varargout = KeyValue2Struct(key,value,varargin)
    %       Convert key and value to struct
    % =================================================================================================================
    % Parameter:
    %       key: key of struct               || required: True || type: string || format: {"key1","key2"}
    %       value: value of struct           || required: True || type: string || format: {"value1","value2"}
    %       varargin: key                    || required: False|| type: string || format: "key1"
    %       varargout: value of varargin     || required: False|| type: string || format: "value1"
    %       varargout: struct                || required: False|| type: struct || format: struct('key1','value1','key2','value2')
    % =================================================================================================================
    % Example:
    %       Struct = KeyValue2Struct(key,value);
    %       [value1,Struct] = KeyValue2Struct(key,value,'key1');
    % =================================================================================================================

    key = cellfun(@(Key) StartWith_digit(Key, 'f'), key, 'UniformOutput', false);
    key = matlab.lang.makeUniqueStrings(key, {}, namelengthmax);
    D = [key;value]';
    varargout{1} = cell2struct(value,key,2);
    fields = {'name', 'value'};
    varargout{2} = cell2struct(D, fields, 2);
    if nargin > 2
        varargout{3} = varargout{2};
        varargout{2} = varargout{1};
        varargout{1} = varargout{1}.(varargin{1});
    end


    function Key = StartWith_digit(Key,pre)
        if isstrprop(Key, 'digit')
            Key = [pre , Key];
        end
    end

end
