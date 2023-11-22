function TF = is_number(str)
    %       Check if the string is a number
    % =================================================================================================================
    % Parameter:
    %       str: str to be checked      || required: True || type: string || format: '12'
    %       TF:  True or False          || required: True || type: bool   || format: True
    % =================================================================================================================
    % Example:
    %       TF = is_number('12')
    % =================================================================================================================

    pattern = '^[+-]?\d*(\.\d+)?(e[+-]?\d+)?$'; % 科学计数法表示的实数
%         pattern = '^[-+]?(\d+\.?\d*|\.\d+)$'; % 实数
%         pattern = '^[+-]?\d+$'; % 整数
    if isempty(regexp(str, pattern, 'once'))
        TF = false; % 非数字
    else
        TF = true;
    end

end
