function [V] = Mncload(ncFile, varName, varargin)
    %       Read netcdf file and return the variable matrix.
    %       Same as ncload.
    % =================================================================================================================
    % Parameter:
    %       ncFile: file name                                  || required: True  || type: string || format: "file"
    %       varName: variable name                             || required: False || type: string || format: "var1"
    %       varargin: 
    %           None: No need           || required: False || type: int    || format: [1,1]
    % =================================================================================================================
    % Example:
    %       Mncload d03.nc;
    %       V = Mncload("d03.nc");
    %       V = Mncload("d03.nc", 'T2');
    % =================================================================================================================

    % No need arguments

    ncFile = convertStringsToChars(ncFile);
    if nargin == 1
        S = ncload(ncFile);
        for s = fieldnames(S)'
            if nargout == 0
                assignin('base', s{1}, S.(s{1}));
            else
                eval(sprintf('V.%s=S.(''%s'');',s{1},s{1}));
            end
        end
    else
        varName = convertStringsToChars(varName);
        if nargout == 0 
            assignin('base', varName, ncload(ncFile, varName));
        else
            V = ncload(ncFile, varName);
        end

    end

    
end
