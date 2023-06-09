function osprint(varargin)
    % =================================================================================================================
    % discription:
    %       print the string to the screen
    % =================================================================================================================
    % parameter:
    %       varargin{n}: string to be printed     || required: True || type: char or string
    % =================================================================================================================
    % example:
    %       osprint('hello world1', 'hello world2')
    % =================================================================================================================

    for i = 1:nargin
        system(['echo `date "+%Y-%m-%d %T"` "--->" "', varargin{i},'"']);
    end