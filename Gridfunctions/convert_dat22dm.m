function convert_dat22dm(modelName, din, f2dm, varargin)
    %       Convert FVCOM dat file to 2dm file.
    % =================================================================================================================
    % Parameters:
    %       modelName:  Model Name      || required: True  || type: Text    || example: 'wzinu3'
    %       din:        Dir in          || required: True  || type: dir     || example: './dat'
    %       f2dm:       2dm filename    || required: True  || type: Text    || example: 'wzinu3.2dm'
    %       varargin: (optional)    
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-12-08:     Created,    by Christmas;
    % =================================================================================================================
    % Examples:
    %       convert_dat22dm('wzinu3', '/Users/christmas/Downloads/dingyang/FVCOM_WZinu3/Control/data/dat', './wzinu3.2dm')
    % =================================================================================================================
    
    arguments(Input)
        modelName {mustBeTextScalar}
        din {mustBeFolder}
        f2dm {mustBeTextScalar}
    end
    arguments(Input, Repeating)
        varargin
    end
    
    fdat_grd = fullfile(din, sprintf('%s_grd.dat',modelName));
    fdat_dep = fullfile(din, sprintf('%s_dep.dat',modelName));
    fdat_obc = fullfile(din, sprintf('%s_obc.dat',modelName));

    [x, y, nv] = read_grd(fdat_grd);
    [~, ~, h] = read_dep(fdat_dep);
    [obc, ~] = read_obc(fdat_obc);

    write_2dm(f2dm, x, y, nv, h, obc)

end
