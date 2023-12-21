function osprint(varargin)
    %       print the string to the screen
    % =================================================================================================================
    % Parameters:
    %       varargin{n}: string to be printed     || required: True || type: char or string
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Example:
    %       osprint('hello world1', 'hello world2')
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin{mustBeTextScalar}
    end

    for i = 1:nargin
        system(['echo `date "+%Y-%m-%d %T"` "--->" "', convertStringsToChars(varargin{i}),'"']);
    end
