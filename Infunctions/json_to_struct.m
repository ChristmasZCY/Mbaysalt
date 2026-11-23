function varargout = json_to_struct(text, varargin)
    %       Convert json string to struct for read_conf(function)
    % =================================================================================================================
    % Parameter:
    %       text: json string                || required: True || type: text   || example: "{'key1':'value1','key2':'value2'}"
    %       varargin:
    %           key: key of value            || required: False|| type: text   || example: "key1"
    % =================================================================================================================
    % Returns:
    %       varargout:
    %         nargin == 1
    %           struct: json struct          || required: False|| type: struct || example: struct('key1','value1','key2','value2')
    %         nargin == 2
    %           value: value of key          || required: False|| type: string || example: "value1"
    %           struct: json struct          || required: False|| type: struct || example: struct('key1','value1','key2','value2')
    % =================================================================================================================
    % Example:
    %       Struct = json_to_struct(text);
    %       [value1,Struct] = json_to_struct(text,'key1');
    % =================================================================================================================

    arguments (Input)
        text {mustBeTextScalar}
    end

    arguments (Input, Repeating)
        varargin
    end

    arguments (Output, Repeating)
        varargout
    end

    text = convertStringsToChars(text);

    if nargin == 2
        key = convertStringsToChars(varargin{1});
    end

    body = text(2:end);
    if ~isempty(body) && body(end) == '}'
        body = body(1:end - 1);
    end
    parts_cell = strsplit(body, ',');
    parts_cell = cellfun(@strip, parts_cell, 'UniformOutput', false);

    keys = {};
    value = {};

    for i = 1:length(parts_cell)
        item = parts_cell{i};
        colon = find(item == ':', 1);
        if isempty(colon)
            continue;
        end
        keys{end + 1} = del_quotation(strip(item(1:colon - 1)));
        value{end + 1} = del_quotation(strip(item(colon + 1:end)));
    end

    if isempty(keys)
        varargout{1} = struct();
    else
        varargout{1} = KeyValue2Struct(keys, value);
    end

    if nargin > 1

        if nargout == 2
            varargout{2} = varargout{1};
        end

        if isfield(varargout{1}, key)
            varargout{1} = varargout{1}.(key);
        else
            varargout{1} = '';
            warning('Key "%s" not found in json string', key);
        end

    end

end
