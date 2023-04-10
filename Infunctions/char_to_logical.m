function varargout =  char_to_logical(varargin)
    % =================================================================================================================
    % discription:
    %       convert char to logical
    % =================================================================================================================
    % parameter:
    %       varargin{n}: char to convert || required: True || type: char     || format: '.True.' or '.False.'
    %       varargout{n}: logical        || required: True || type: logical  || format: true or false
    % =================================================================================================================
    % example:
    %       TF = char_to_logical('.True.')
    % =================================================================================================================

    for num = 1: nargin
        T = strcmpi(varargin{num},'.True.');
        F = strcmpi(varargin{num},'.False.');
        if T == 1 && F == 0
            varargout{num} = true;
        elseif T == 0 && F == 1
            varargout{num} = false;
        else
            error('char_to_logical: wrong input format')
        end
    end

end