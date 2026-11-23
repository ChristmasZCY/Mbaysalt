function varargout = read_conf(confin, varargin)
    %       Read configuration file from *.conf file
    % =================================================================================================================
    % Parameter:
    %       confin: configuration file             || required: True || type: char or string  ||  format: *.conf
    %       varargin: (optional input)
    %           varargin{1}: keyToGet              || required: False|| type: char or string  ||  format: 'f2dmFile'
    %       varargout: (optional output)
    %         nargin == 1:
    %           varargout{1}: struct               || required: False|| type: struct          ||  format: struct(1*1)
    %           varargout{2}: struct               || required: False|| type: struct          ||  format: struct(n*1) --> name value
    %         nargin == 2:
    %           varargout{1}: value                || required: False|| type: char or string  ||  format: '/Users/.../f2dmFile.2dm'
    %           varargout{2}: struct               || required: False|| type: struct          ||  format: struct(n*1) --> name value
    %           varargout{3}: struct               || required: False|| type: struct          ||  format: struct(1*1)
    % =================================================================================================================
    % Returns:
    %
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                by Christmas;
    %       2024-12-10:     Added key:FILEPATH,     by Christmas;
    %       2026-01-06:     Fixed strfind maybe >1, by Christmas;
    %       2026-11-22:     Safe array parsing,     by Christmas;
    %       2026-11-22:     Fixed digit key values, by Christmas;
    % =================================================================================================================
    % Example:
    %       conf = read_conf(confin)
    %       [conf, kv] = read_conf(confin)
    %       Value = read_conf(confin, 'f2dmFile')
    %       [Value, kv, conf] = read_conf(confin, 'f2dmFile')
    % =================================================================================================================

    arguments (Input)
        confin % {mustBeFile}
    end

    arguments (Repeating)
        varargin
    end

    fid = fopen(confin, 'r');

    if fid == -1
        error('Cannot open file %s', confin);
    end

    l_num = 1;
    kv_conf = cell(0);

    while ~feof(fid)
        line = strip(fgetl(fid));

        if contains(line, '=')

            if ~startsWith(line, "#")
                F = strfind(line, "#"); % 可能有多个

                if ~isempty(F)
                    line = strip(line(1:F(1) - 1));
                end

                kv_conf{l_num} = line;
                l_num = l_num + 1;
            end

        end

    end

    fclose(fid);

    %-cellfun: 对cell中的每个元素执行函数
    %-strsplit: 将字符串分割成单词
    %-str2bool: 将字符串转换为逻辑值
    %-str2func: 将字符串转换为函数句柄
    %-str2sym: 将字符串转换为符号表达式
    %-str2mat: 将字符串转换为矩阵
    [key, value] = cellfun(@parse_line, kv_conf, 'UniformOutput', false);

    if ~ismember('FILEPATH', key)
        key = [key, {'FILEPATH'}];
        value = [value, {confin}];
    end

    [varargout{1}, varargout{2}] = KeyValue2Struct(key, value);
    varargout{1} = make_DEFAULT(varargout{1});

    if nargin > 1
        varargout{3} = varargout{2};
        varargout{2} = varargout{1};

        keyToGet = varargin{1};
        varargin(1) = [];

        if ~isfield(varargout{1}, keyToGet)
            varargout{1} = '';
            warning('Key "%s" not found in struct', keyToGet);
        else
            varargout{1} = varargout{1}.(keyToGet);
        end

    end

end

function [key, value] = parse_line(line)
    % Split a configuration record at its first assignment and convert the value.
    separator = find(line == '=', 1);
    key = strip(line(1:separator - 1));
    value = strip(line(separator + 1:end));

    if size(key, 1) == 0
        key = 'NaN';
    end

    value = del_quotation(value);

    if isstrprop(key(1), 'digit')
        key = ['f', key];
    end

    if strcmpi(value, '.True.') % 不区分大小写
        value = true;
    elseif strcmpi(value, '.False.')
        value = false;
    elseif startsWith(value, '[')

        [array, ok] = parse_conf_array(value);

        if ok && ~isempty(array) && ~any(isnan(array(:)))
            value = array;
        else
            value = listStr_to_cell(value);
        end

    elseif startsWith(value, '{')
        value = json_to_struct(value);
    elseif is_number(value)
        value = str2double(value);
    end

    if size(value, 1) == 0
        value = NaN;
    end

end

function [result, ok] = parse_conf_array(source)
    % Parse a bracketed numeric array without executing code: + - * / ^, parentheses,
    % unary signs, colon ranges, nested [], ';' rows and constants pi Inf true false;
    % anything else returns ok = false.
    number = '(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?';
    identifier = '[A-Za-z_]\w*';
    pattern = [number '|' identifier '|\S'];
    [first, last, tokens] = regexp(source, pattern, 'start', 'end', 'match');
    tokens{end + 1} = ''; % End marker for lookahead.
    pos = 2; % read_conf already recognized the opening bracket.
    ok = false;
    result = [];
    try
        result = matrix();
        if pos ~= numel(tokens)
            invalid();
        end
        ok = true;
    catch ME
        if ~strcmp(ME.identifier, 'parse_conf_array:Invalid')
            rethrow(ME)
        end
    end

    function out = matrix()
        % Read rows up to the matching closing bracket; preserve MATLAB concatenation.
        rows = {};
        blocks = {};
        while ~strcmp(tokens{pos}, ']')
            if strcmp(tokens{pos}, '[')
                pos = pos + 1;
                block = matrix();
            else
                block = expression(0, true);
                if strcmp(tokens{pos}, ':')
                    pos = pos + 1;
                    second = expression(0, true);
                    if strcmp(tokens{pos}, ':')
                        pos = pos + 1;
                        block = block:second:expression(0, true);
                    else
                        block = block:second;
                    end
                end
            end
            blocks{end + 1} = block; %#ok<AGROW>
            switch tokens{pos}
                case ';'
                    rows{end + 1} = join_blocks(blocks, 2); %#ok<AGROW>
                    blocks = {};
                    pos = pos + 1;
                case ','
                    pos = pos + 1;
                case ']'
                    break
                otherwise
                    if pos == numel(tokens) || first(pos) == last(pos - 1) + 1
                        invalid();
                    end
            end
        end
        require(']');
        if ~isempty(blocks)
            rows{end + 1} = join_blocks(blocks, 2);
        end
        out = join_blocks(rows, 1);
    end

    function out = join_blocks(parts, dimension)
        % Concatenate numeric cells along dimension 1 (rows) or 2 (columns).
        if isempty(parts)
            out = [];
        else
            try
                out = cat(dimension, parts{:});
            catch
                invalid();
            end
        end
    end

    function out = expression(minimum, inRow)
        % Parse scalar arithmetic with precedence levels 1 (sum) to 4 (power).
        token = tokens{pos};
        pos = pos + 1;
        if strcmp(token, '(')
            out = expression(0, false);
            require(')');
        elseif any(strcmp(token, {'+', '-'}))
            out = expression(3, inRow); % Unary signs bind below exponentiation.
            if strcmp(token, '-')
                out = -out;
            end
        else
            if strcmp(token, 'pi')
                out = pi;
            elseif strcmp(token, 'Inf')
                out = Inf;
            elseif strcmp(token, 'true')
                out = 1;
            elseif strcmp(token, 'false')
                out = 0;
            elseif isempty(token) || isempty(regexp(token, ['^' number '$'], 'once'))
                invalid();
            else
                out = str2double(token);
            end
        end
        while true
            op = tokens{pos};
            switch op
                case {'+', '-'}
                    % In an array [1 -2] contains two values, [1 - 2] contains one.
                    if inRow && first(pos) > last(pos - 1) + 1 && pos < numel(first) && first(pos + 1) == last(pos) + 1
                        return
                    end
                    level = 1;
                case {'*', '/'}
                    level = 2;
                case '^'
                    level = 4;
                otherwise
                    return
            end
            if level < minimum
                return
            end
            pos = pos + 1;
            rhs = expression(level + 1, inRow);
            switch op
                case '+'
                    out = out + rhs;
                case '-'
                    out = out - rhs;
                case '*'
                    out = out * rhs;
                case '/'
                    out = out / rhs;
                case '^'
                    out = out ^ rhs;
            end
        end
    end

    function require(expected)
        % Consume one required delimiter, raising the internal parse error on mismatch.
        if ~strcmp(tokens{pos}, expected)
            invalid();
        end
        pos = pos + 1;
    end

    function invalid()
        error('parse_conf_array:Invalid', 'Unsupported array syntax.');
    end
end

function Struct = make_DEFAULT(structIn)
    Struct = structIn;
    Struct.DEFAULT = structIn;
end
