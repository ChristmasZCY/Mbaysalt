function Var = limit_var(var, range, varargin)
    %       Limit variable to a range.
    % =================================================================================================================
    % Parameter:
    %       var: variable to be limited            || required: True || type: numeric        ||  format: matrix
    %       range: range of variable               || required: True || type: 1D array       ||  format: [min,max]
    %       varargin: (optional)
    %
    % =================================================================================================================
    % Returns:
    %       Var: limited variable                  || required: True || type: numeric        ||  format: matrix
    % =================================================================================================================
    % Update:
    %       2024-01-25:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       Var = limit_var(var, range)
    %       Var = limit_var(var, [-1,1])
    % =================================================================================================================

    % Check input
    arguments (Input)
        var
        range (1,2) double {mustBeNumeric, mustBeReal}
    end

    arguments (Repeating)
        varargin
    end

    Var = var;
    lims = minmax(range);
    Var(Var < lims(1)) = lims(1);
    Var(Var > lims(2)) = lims(2);

    return
end