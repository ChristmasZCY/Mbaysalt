function var = nr(fin,varName, varargin)
    %       Read netcdf file, the same as ncread
    % =================================================================================================================
    % Parameters:
    %       fin: file name                                     || required: True  || type: string || example: "d01.nc"
    %       varargin: the same as ncread                       || required: False || type: string || example: "T2"
    % =================================================================================================================
    % Returns:
    %       var: variable matrix                               || required: False || type: double || format: matrix
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2024-01-16:     Fixed filename str with ' ', by Christmas;
    % =================================================================================================================
    % Example:
    %       var = nr(file,'x');
    %       var = nr(file,'x',[1,1],[Inf,Inf]);
    % =================================================================================================================

    arguments(Input)
        fin % {mustBeFile}
        varName {mustBeTextScalar}
    end

    arguments(Input,Repeating)
        varargin
    end

    arguments(Output)
        var
    end
    fin = strtrim(fin);
    var = ncread(fin,varName, varargin{:});

end
