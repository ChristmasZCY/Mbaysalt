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
    %       2026-11-23:     Unified value rules,     by Christmas;
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
    first_line = true;

    while ~feof(fid)
        line = strip(fgetl(fid));

        if first_line
            line = strip(line, char(65279)); % UTF-8 BOM
            first_line = false;
        end

        if isempty(line) || startsWith(line, '#') || startsWith(line, '!') || startsWith(line, '//') || startsWith(line, ';')
            continue;
        end

        F = strfind(line, "#"); % 可能有多个

        if ~isempty(F)
            line = strip(line(1:F(1) - 1));
        end

        if ~contains(line, '=')
            warning('read_conf:NoAssignment', '配置行缺少等号，已跳过: %s', line);
            continue;
        end

        kv_conf{l_num} = line;
        l_num = l_num + 1;

    end

    fclose(fid);

    %-cellfun: 对cell中的每个元素执行函数
    %-strsplit: 将字符串分割成单词
    %-str2bool: 将字符串转换为逻辑值
    %-str2func: 将字符串转换为函数句柄
    %-str2sym: 将字符串转换为符号表达式
    %-str2mat: 将字符串转换为矩阵
    [key, value] = cellfun(@parse_line, kv_conf, 'UniformOutput', false);

    valid = ~cellfun(@isempty, key);
    key = key(valid);
    value = value(valid);

    % 重复键改名为 <key>_dup<N>；手写键名与已分配名永不作为候选
    original = key;
    seen = {};
    used = {};
    for i = 1:numel(key)
        k = key{i};
        if ismember(k, seen)
            n = 1;
            while true
                cand = sprintf('%s_dup%d', k, n);
                n = n + 1;
                if ~ismember(cand, original) && ~ismember(cand, used)
                    break
                end
            end
            key{i} = cand;
        else
            seen{end + 1} = k; %#ok<AGROW>
        end
        used{end + 1} = key{i}; %#ok<AGROW>
    end

    if ismember('FILEPATH', key)
        warning('read_conf:ReservedKey', '配置文件已定义 FILEPATH，保留配置值');
    else
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

    if isempty(key)
        warning('read_conf:EmptyKey', '配置行键为空，已跳过: %s', line);
        key = '';
        value = [];
        return
    end

    value = del_quotation(value);

    if isstrprop(key(1), 'digit')
        key = ['f', key];
    end

    if isempty(value)
        value = [];
    elseif strcmpi(value, '.True.') % 不区分大小写
        value = true;
    elseif strcmpi(value, '.False.')
        value = false;
    elseif startsWith(value, '[')

        [array, ok] = parse_conf_array(value);

        if ok
            value = array;
        else
            value = listStr_to_cell(value);
        end

    elseif startsWith(value, '{')
        value = json_to_struct(value);
    elseif is_conf_number(value)
        value = str2double(value);
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
    max_depth = 64; % [, ( 与一元符号共用的最大嵌套层数，单位：层；超出按解析失败处理。
    depth = 1; % 嵌套深度，外层 [ 计为第 1 层。
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
                depth = depth + 1;
                if depth > max_depth
                    invalid();
                end
                block = matrix();
                depth = depth - 1;
            else
                block = expression(0, true);
                if strcmp(tokens{pos}, ':')
                    pos = pos + 1;
                    second = expression(0, true);
                    if strcmp(tokens{pos}, ':')
                        pos = pos + 1;
                        block = colon_operand(block):colon_operand(second):colon_operand(expression(0, true));
                    else
                        block = colon_operand(block):colon_operand(second);
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
            depth = depth + 1;
            if depth > max_depth
                invalid();
            end
            out = expression(0, false);
            require(')');
            depth = depth - 1;
        elseif any(strcmp(token, {'+', '-'}))
            depth = depth + 1;
            if depth > max_depth
                invalid();
            end
            out = expression(3, inRow); % Unary signs bind below exponentiation.
            depth = depth - 1;
            if strcmp(token, '-')
                out = -out;
            end
        else
            if strcmp(token, 'pi')
                out = pi;
            elseif strcmp(token, 'Inf')
                out = Inf;
            elseif strcmp(token, 'NaN')
                out = NaN;
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
                    if ~isreal(out)
                        invalid();
                    end
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

    function s = colon_operand(v)
        % MATLAB colon uses the first element of array operands and requires finite scalars.
        if isempty(v) || ~isnumeric(v)
            invalid();
        end
        s = v(1);
        if ~isreal(s) || ~isfinite(s)
            invalid();
        end
    end

    function invalid()
        error('parse_conf_array:Invalid', 'Unsupported array syntax.');
    end
end

function Struct = make_DEFAULT(structIn)
    Struct = structIn;
    if isfield(Struct, 'DEFAULT')
        warning('read_conf:ReservedKey', '配置文件已定义 DEFAULT，保留配置值');
    else
        Struct.DEFAULT = structIn;
    end
end

function tf = is_conf_number(value)
    % Local scalar-number check for read_conf values; shared is_number.m is unchanged.
    tf = ~isempty(regexp(value, '^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?$', 'once')) ...
        || ~isempty(regexp(value, '^[+-]?(nan|inf)$', 'once', 'ignorecase'));
end
