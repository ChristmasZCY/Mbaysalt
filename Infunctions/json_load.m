function jdata = json_load(file,varargin)
    % =================================================================================================================
    % discription:
    %       Load json file
    % =================================================================================================================
    % parameter:
    %       file: file name                  || required: True || type: string || format: "file.json"
    %       varargin: Method_load            || required: False|| type: string || format: "MATLAB" or "jsonlab"
    %       varargout: json data             || required: False|| type: struct || format: struct('key1','value1','key2','value2')
    % =================================================================================================================
    % example:
    %       jdata = json_load('file.json');
    %       jdata = json_load('file.json','Method_load','jsonlab');
    % =================================================================================================================

    varargin = read_varargin(varargin,{'Method_load'},{'MATLAB'});
    varargin = read_varargin2(varargin,{'S'});
    
    switch Method_load
        case "MATLAB"
            json_str = fileread(file);
            jdata = jsondecode(json_str);
        case "jsonlab"
            jdata = loadjson(file);
    end

    if ~isempty(S)
        disp('Switch_S is Open')
    end

end