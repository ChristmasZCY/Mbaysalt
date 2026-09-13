function test_parse_varargin()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repoRoot, 'Infunctions'));

    rest = parse_varargin( ...
        {'METHOD', 'fast', 'Verbose', 'other', 42, 'Count', 3}, ...
        {'Method', 'Count'}, {'common', 1}, {'Verbose'});

    assert(strcmp(Method, 'fast'));
    assert(strcmp(Verbose, 'Verbose'));
    assert(Count == 3);
    assert(isequal(rest, {'other', 42}));

    parse_varargin({'Method', 'Verbose'}, {'Method'}, {'common'}, {'Verbose'});
    assert(strcmp(Method, 'Verbose'));
    assert(isempty(Verbose));

    try
        parse_varargin({'Count'}, {'Count'}, {1});
        error('test_parse_varargin:ExpectedError', 'Missing value was accepted.');
    catch exception
        assert(strcmp(exception.identifier, 'parse_varargin:MissingValue'));
    end
end
