function Str = del_quotation(str)
    %       Delete the quotation of string
    % =================================================================================================================
    % Parameter:
    %       str: string                      || required: True || type: string || format: ''value''
    %       Str: string without quotation    || required: True || type: string || format: 'value'
    % =================================================================================================================
    % Example:
    %       Str = del_quotation('''value''')
    % =================================================================================================================

    if or(and(startsWith(str, "'") , endsWith(str, "'")) , and(startsWith(str, '"') , endsWith(str, '"')))
        Str = str(2:end-1);
    else
        Str = str;
    end

end
