function TF = isaequal(A, B, tol, varargin)
    %       approximate equality A, B(not support NaN)
    % =================================================================================================================
    % Parameters:
    %       A:          input A             || required: True       || type: matrix     || format: matrix
    %       B:          input B             || required: True       || type: matrix     || format: matrix
    %       tol:        tolerance           || required: positional || type: double     || format: numeric
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       TF:         logical             || required: True       || type: logical    || format: matrix
    % =================================================================================================================
    % Updates:
    %       2024-09-19:     Created,                by Christmas;
    %       2026-04-23;     Fixed error at R2022b,  by Christmas;
    % =================================================================================================================
    % Examples:
    %       TF = isaequal(A, B);
    %       TF = isaequal(A, B, eps);
    %       TF = isaequal(A, B, 1e-6);
    % =================================================================================================================

    narginchk(2, 4)

    if any(isnan(A), "all") || any(isnan(B), "all")
        error('There''s NaN in %s or %s, please use ''isaequaln'' instead!', inputname(1), inputname(2))
    end

    % eps是函数
    if ~exist("tol", "var") == 1
        tol = eps;
    end

    if ~isMATLABReleaseOlderThan("R2024b")
        % TF1 = isapprox(A, B);
        TF1 = isapprox(A, B, "AbsoluteTolerance", tol);
        TF = all(TF1, 'all');
    else
        TF = max(A - B) < tol;
    end

    return

end
