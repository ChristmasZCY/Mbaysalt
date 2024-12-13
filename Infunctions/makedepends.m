function [fList,pList] = makedepends(funName, varargin)
    %       Generate depends functions to folder, for giving others.
    % =================================================================================================================
    % Parameters:    
    %       funName:    function Name       || required: True  || type: *.m       || example: './surge_high_tide.m'
    %       varargin: (optional)
    %           depDir: Output depends dir  || required: False || type: namevalue || default: './depends'
    % =================================================================================================================
    % Returns:
    %       fList:  Full paths of user MATLAB program files required by "files". 
    %       pList:  A list of MathWorks products required by "files".
    % =================================================================================================================
    % Updates:
    %       2024-12-13:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       makedepends('./surge_high_tide.m');
    %       makedepends('./surge_high_tide.m', 'depDir', './depends');
    %       [fList,pList] = makedepends('./surge_high_tide.m');
    % =================================================================================================================


    arguments(Input)
        funName {mustBeFile}
    end

    arguments(Input, Repeating)
        varargin
    end

    read_varargin(varargin, {'depDir'}, {'./depends'});

    fList = {};
    pList = {};

    if exist(depDir, "dir")
        warning('%s is already exist !!!', depDir);
        yn = input_yn('Are you sure you want to do continue?');
        if ~yn
            return
        end
    else
        makedirs(depDir)
    end

    [fList,pList] = matlab.codetools.requiredFilesAndProducts(funName);

    for i = 1: len(fList)
        copyfile(fList{i}, depDir)
    end

end
