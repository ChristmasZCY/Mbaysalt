function Str = del_quotation(str)
    % =================================================================================================================
    % discription:
    %       Delete the quotation of string
    % =================================================================================================================
    % parameter:
    %       str: string                      || required: True || type: string || format: ''value''
    %       Str: string without quotation    || required: True || type: string || format: 'value'
    % =================================================================================================================
    % example:
    %       Str = del_quotation('''value''')
    % =================================================================================================================

    if or(and(startsWith(str, "'") , endsWith(str, "'")) , and(startsWith(str, '"') , endsWith(str, '"')))
        Str = str(2:end-1);
    else
        Str = str;
    end

end