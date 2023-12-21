function jdata = json_load(file,varargin)
    %       Load json file
    % =================================================================================================================
    % Parameters:
    %       file: file name                  || required: True || type: string || example: "file.json"
    %       varargin: 
    %           Method_load                  || required: False|| type: string || example: "MATLAB" or "jsonlab"
    % =================================================================================================================
    % Returns:
    %       jdata: json data                 || required: False|| type: struct || example: struct('key1','value1','key2','value2')
    % =================================================================================================================
    % Example:
    %       jdata = json_load('file.json');
    %       jdata = json_load('file.json','method','MATLAB');
    %       jdata = json_load('file.json','method','jsonlab');
    % =================================================================================================================

    arguments(Input)
        file {mustBeFile}
    end

    arguments(Input,Repeating)
        varargin
    end

    arguments(Output)
        jdata {struct}
    end

    file = convertStringsToChars(file);

    varargin = read_varargin(varargin,{'method'},{'MATLAB'});
    
    switch Method_load
        case "MATLAB"
            json_str = fileread(file);
            jdata = jsondecode(json_str);
        case "jsonlab"
            jdata = loadjson(file);
    end

end
