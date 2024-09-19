function TF = isaequal(A, B, eps, varargin)
    %       approximate equality A, B(not support NaN)
    % =================================================================================================================
    % Parameters:
    %       A:          input A             || required: True       || type: matrix     || format: matrix
    %       B:          input B             || required: True       || type: matrix     || format: matrix
    %       eps:        tolerance           || required: positional || type: double     || format: numeric
    %       varargin: (optional) 
    % =================================================================================================================
    % Returns:
    %       TF:         logical             || required: True       || type: logical    || format: matrix
    % =================================================================================================================
    % Updates:
    %       2024-09-19:     Created,    by Christmas;
    % =================================================================================================================
    % Examples:
    %       TF = isaequal(A, B);
    %       TF = isaequal(A, B, eps);
    %       TF = isaequal(A, B, 1e-6);
    % =================================================================================================================

    narginchk(2, 4)

    if any(isnan(A),"all") || any(isnan(B),"all")
        error('There''s NaN in %s or %s, please use ''isaequaln'' instead!', inputname(1), inputname(2))
    end

    % eps也是函数


    if ~isMATLABReleaseOlderThan("R2024b")
        if exist("eps","var")
            TF1 = isapprox(A, B, "AbsoluteTolerance", eps);
        else
            TF1 = isapprox(A, B);
        end
        TF = all(TF1,'all');
    else
        TF = max(A-B)<eps;
    end
    
    return

end
