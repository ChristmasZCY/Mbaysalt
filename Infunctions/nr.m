function var = nr(file,varargin)
    %       read netcdf file, the same as ncread
    % =================================================================================================================
    % Parameter:
    %       file: file name                                    || required: True  || type: string || format: "file"
    %       varargin: the same as ncread                       || required: False || type: string || format: "var1"
    %       var: variable matrix                               || required: False || type: double || format: matrix
    % =================================================================================================================
    % Example:
    %       var = nr(file,'x');
    %       var = nr(file,'x',[1,1],[Inf,Inf]);
    % =================================================================================================================

    var = ncread(file,varargin{:});

end
