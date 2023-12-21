function TF = is_number(text)
    %       Check if the texting is a number
    % =================================================================================================================
    % Parameter:
    %       text: text to be checked      || required: True || type: texting || example: '12'
    % =================================================================================================================
    % Returns:
    %       TF:  True or False            || required: True || type: logical || example: True
    % =================================================================================================================
    % Example:
    %       TF = is_number('12')
    % =================================================================================================================

    arguments(Input)
        text {mustBeTextScalar}
    end

    arguments(Output)
        TF {true,false}
    end

    text = convertStringsToChars(text);

    pattern = '^[+-]?\d*(\.\d+)?(e[+-]?\d+)?$'; % 科学计数法表示的实数

%         pattern = '^[-+]?(\d+\.?\d*|\.\d+)$'; % 实数
%         pattern = '^[+-]?\d+$'; % 整数
    if isempty(regexp(text, pattern, 'once'))
        TF = false; % 非数字
    else
        TF = true;
    end

end
