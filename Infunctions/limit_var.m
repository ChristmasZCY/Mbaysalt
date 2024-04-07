function varOut = limit_var(varIn, range, varargin)
    %       Limit variable to a range. (Not recommended, replaced by 'clip')
    % =================================================================================================================
    % Parameter:
    %       varIn: variable to be limited          || required: True || type: numeric        ||  format: matrix
    %       range: range of variable               || required: True || type: 1D array       ||  format: [min,max]
    %       varargin: (optional)
    %
    % =================================================================================================================
    % Returns:
    %       varOut: limited variable               || required: True || type: numeric        ||  format: matrix
    % =================================================================================================================
    % Update:
    %       2024-01-25:     Created, by Christmas;
    %       2024-04-07:     Added call clip, by Christmas;
    % =================================================================================================================
    % Example:
    %       Var = limit_var(var, [-1,1])
    % =================================================================================================================

    % Check input
    arguments (Input)
        varIn
        range (1,2) double {mustBeNumeric, mustBeReal}
    end

    arguments (Repeating)
        varargin
    end

    if ~isMATLABReleaseOlderThan("R2024a")
        varOut = clip(varIn, range(1), range(2));
    else
        varOut = varIn;
        lims = minmax(range);
        varOut(varOut < lims(1)) = lims(1);
        varOut(varOut > lims(2)) = lims(2);
    end

    return
end
