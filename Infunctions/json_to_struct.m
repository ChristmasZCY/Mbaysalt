function varargout = json_to_struct(str,varargin)
    %       Convert json string to struct
    % =================================================================================================================
    % Parameter:
    %       str: json string                 || required: True || type: string || format: "{'key1':'value1','key2':'value2'}"
    %       varargin: key                    || required: False|| type: string || format: "key1"
    %       varargout: value of varargin     || required: False|| type: string || format: "value1"
    %       varargout: struct                || required: False|| type: struct || format: struct('key1','value1','key2','value2')
    % =================================================================================================================
    % Example:
    %       Struct = json_to_struct(str);
    %       [value1,Struct] = json_to_struct(str,'key1');
    % =================================================================================================================

    parts_cell = strsplit(str(2:end-1), ',');
    parts_cell = cellfun(@strip, parts_cell, 'UniformOutput', false);
    parts_cell = cellfun(@(x) strsplit(x, ':'), parts_cell, 'UniformOutput', false);
    parts_cell = cellfun(@strip, parts_cell, 'UniformOutput', false);

    key = cell(0);
    value = cell(0);
    for i = 1:length(parts_cell)
        key{i} = del_quotation(parts_cell{i}{1});
        value{i} = del_quotation(parts_cell{i}{2});
    end
    if nargin > 1
        varargout{2} = KeyValue2Struct(key,value);
        varargout{1} = KeyValue2Struct(key,value).(varargin{1});
    else
        varargout{1} = KeyValue2Struct(key,value);
    end


    function str = del_quotation(str)
        if or(and(startsWith(str, "'") , endsWith(str, "'")) , and(startsWith(str, '"') , endsWith(str, '"')))
            str = str(2:end-1);
        end
    end

end
