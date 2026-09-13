function out = parse_varargin(in, names, defaults, flags)
    %       Parse name-value options and standalone flags in varargin.
    %       Parsed values are assigned to caller variables named by names or flags.
    % =================================================================================================================
    % Parameters:
    %       in:        varargin cell array                  || required: True  || type: cell
    %       names:     name-value option names              || required: False || type: cell/char/string || default: {}
    %       defaults:  name-value option defaults           || required: False || type: cell || default: {}
    %       flags:     standalone switch names; absent='', present=name || required: False || type: cell/char/string || default: {}
    % =================================================================================================================
    % Returns:
    %       out:       Unrecognized input arguments         || type: cell
    % =================================================================================================================
    % Updates:
    %       2026-09-13: Created, by Codex;
    %       2026-09-14: Changed to the read_varargin-compatible interface, by Codex;
    % =================================================================================================================
    % Examples:
    %       varargin = parse_varargin(varargin, {'Method'}, {'common'});
    %       varargin = parse_varargin(varargin, {'Method'}, {'common'}, {'Verbose'});
    % =================================================================================================================
    % References:
    %       None
    % =================================================================================================================

    if nargin < 2
        names = {};
    end

    if nargin < 3
        defaults = {};
    end

    if nargin < 4
        flags = {};
    end

    if ~iscell(in)
        error('parse_varargin:InvalidInput', 'Input arguments must be a cell array.');
    end

    names = normalize_names(names, 'names');
    flags = normalize_names(flags, 'flags');

    if ~iscell(defaults) || numel(names) ~= numel(defaults)
        error('parse_varargin:InvalidDefaults', ...
            'Defaults must be a cell array with one value for each option name.');
    end

    for i = 1:numel(names)
        assignin('caller', names{i}, defaults{i});
    end

    for i = 1:numel(flags)
        if any(strcmpi(names, flags{i}))
            error('parse_varargin:DuplicateName', ...
                'Option ''%s'' cannot be both a name-value option and a flag.', flags{i});
        end

        assignin('caller', flags{i}, '');
    end

    out = in;
    i = 1;

    while i <= numel(out)
        name = option_name(out{i});
        optionIndex = find(strcmpi(names, name), 1);
        flagIndex = find(strcmpi(flags, name), 1);

        if ~isempty(name) && ~isempty(optionIndex)
            if i == numel(out)
                error('parse_varargin:MissingValue', ...
                    'Option ''%s'' requires a value.', names{optionIndex});
            end

            assignin('caller', names{optionIndex}, out{i + 1});
            out(i:i + 1) = [];
        elseif ~isempty(name) && ~isempty(flagIndex)
            assignin('caller', flags{flagIndex}, flags{flagIndex});
            out(i) = [];
        else
            i = i + 1;
        end
    end
end

function names = normalize_names(names, argumentName)
    if ischar(names)
        names = {names};
    elseif isa(names, 'string')
        names = cellstr(names(:));
    end

    if ~iscell(names)
        error('parse_varargin:InvalidNames', '%s must be a cell array of names.', argumentName);
    end

    names = names(:)';

    for i = 1:numel(names)
        names{i} = option_name(names{i});

        if isempty(names{i}) || ~isvarname(names{i})
            error('parse_varargin:InvalidName', ...
                'Each entry in %s must be a valid variable name.', argumentName);
        end
    end
end

function name = option_name(value)
    if ischar(value) && (isempty(value) || size(value, 1) == 1)
        name = value;
    elseif isa(value, 'string') && isscalar(value)
        name = char(value);
    else
        name = '';
    end
end
