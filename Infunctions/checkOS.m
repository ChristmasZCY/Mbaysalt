function OS = checkOS()
    %       Check OS
    % =================================================================================================================
    % Parameters:
    %       None
    % =================================================================================================================
    % Returns:
    %       OS: Computer system  || type: char || example: 'LNX' 'WIN' 'MAC'
    % =================================================================================================================
    % Update:
    %       2024-12-10:     Created,    by Christmas;
    % =================================================================================================================
    % Example:
    %       OS = checkOS();
    % =================================================================================================================

    OS1 = computer;

    if contains(OS1, 'MAC')
        OS = 'MAC';
    elseif contains(OS1, 'WIN')
        OS = 'WIN';
    elseif contains(OS1, 'LNX')
        OS = 'LNX';
    end

end