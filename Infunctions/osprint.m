function osprint(varargin)
    %       print the string to the screen
    % =================================================================================================================
    % Parameters:
    %       varargin{n}: string to be printed     || required: True || type: char or string
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2026-11-22:     Print literally with time zone and UTC offset, by Christmas;
    % =================================================================================================================
    % Example:
    %       osprint('hello world1', 'hello world2')
    % =================================================================================================================

    arguments (Input, Repeating)
        varargin{mustBeTextScalar}
    end

    for i = 1:nargin
        stamp = datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ss z Z');
        fprintf('%s ---> %s\n', char(stamp), varargin{i});
    end
end
