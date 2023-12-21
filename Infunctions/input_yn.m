function yn = input_yn(prompt)
    %       Check if the input is yes or no
    % =================================================================================================================
    % Parameter:
    %       prompt: the prompt to show in the input || required: True || type: Text  ||  Example: 'Are you sure?'
    % =================================================================================================================
    % Returns:
    %       yn: true or false                       || required: True || type: logical ||  Example: true
    % =================================================================================================================
    % Example:
    %       yn = input_yn('Are you sure you want to do this?')
    % =================================================================================================================

    arguments(Input)
        prompt {mustBeTextScalar}
    end

    arguments(Output)
        yn {mustBeNonnegative}
    end

    yn = input(prompt, 's');
    switch lower(yn)
        case {'y', 'yes', 'true', '1', 't', 'on', 'enable', 'enabled', 'active', 'activated'}
            yn = true;
        case {'n', 'no', 'false', '0', 'f', 'off', 'disable', 'disabled', 'inactive', 'deactivated'}
            yn = false;
        otherwise
            error('Invalid input');
    end
end
