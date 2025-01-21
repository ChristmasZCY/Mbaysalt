function Str = del_quotation(str)
    %       Delete the quotation of string
    % =================================================================================================================
    % Parameters:
    %       str: string                      || required: True || type: string || format: ''value''
    % =================================================================================================================
    % Returns:
    %       Str: string without quotation    || required: True || type: string || format: 'value'
    % =================================================================================================================
    % Updates:
    %       ****-**-**: Created,        by Christmas;
    %       2025-01-13: Added strip,    by Christmas;  
    % =================================================================================================================
    % Example:
    %       Str = del_quotation("''value''")
    % =================================================================================================================
    
    arguments(Input)
        str {mustBeTextScalar}
    end

    arguments(Output)
        Str {mustBeTextScalar}
    end

    str = convertStringsToChars(str);
    if or(and(startsWith(str, "'") , endsWith(str, "'")) , and(startsWith(str, '"') , endsWith(str, '"')))
        Str = str(2:end-1);
    else
        Str = str;
    end

    Str = strip(Str);

end
