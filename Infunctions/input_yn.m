function yn = input_yn(prompt)
    % TODO: add description
    % =================================================================================================================
    % discription:
    %       Make tide current u/v/h from TPXO9-atlas, and write to nc file.
    % =================================================================================================================
    % parameter:
    %       yyyy: year                             || required: True || type: double         ||  format: 2019 or '2019'
    %       mm: month                              || required: True || type: double         ||  format: 1 or '1'
    %       varargin{1}: day_length                || required: False|| type: double         ||  format: 1:31
    % =================================================================================================================
    % example:
    %       make_tide_from_tpxo(2023,5)
    %       make_tide_from_tpxo(2023,5,[1,3,5])
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