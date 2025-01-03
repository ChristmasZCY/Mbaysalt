function OS = checkOS(str)
    %       Check OS
    % =================================================================================================================
    % Parameters:
    %       str: OS choice      || required: False || type: positional || example: 'MAC'
    % =================================================================================================================
    % Returns:
    %       OS: Computer system || type: char   || example: 'LNX' 'WIN' 'MAC' (nargin = 0)
    %       OS: True or False   || type:logical || example: true or false     (nargin = 1)
    % =================================================================================================================
    % Update:
    %       2024-12-10:     Created,            by Christmas;
    %       2025-01-03:     Added nargin=1,     by Christmas;
    % =================================================================================================================
    % Example:
    %       OS = checkOS();
    %       TF = checkOS('MAC');
    % =================================================================================================================

    OS1 = computer;

    if contains(OS1, 'MAC')
        OS = 'MAC';
    elseif contains(OS1, 'WIN')
        OS = 'WIN';
    elseif contains(OS1, 'LNX')
        OS = 'LNX';
    else
        error('Platform error !!!')
    end

    if nargin > 0 
        OS = strcmp(OS, str);
    end

end
