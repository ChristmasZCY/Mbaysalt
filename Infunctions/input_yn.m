function yn = input_yn(prompt)
    % =================================================================================================================
    % discription:
    %       Check if the input is yes or no
    % =================================================================================================================
    % parameter:
    %       prompt: the prompt to show in the input || required: True || type: string  ||  format: 'prompt'
    % =================================================================================================================
    % example:
    %       yn = input_yn('Are you sure you want to do this?')
    % =================================================================================================================

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