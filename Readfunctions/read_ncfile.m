function [lon,lat,time,varargout] = read_ncfile(ncin,varargin)
    % =================================================================================================================
    % discription:
    %       read 2dm file to msh file for Wave Watch III
    % =================================================================================================================
    % parameter:
    %       varargin{1}: replace point depth from land to sea  || required: True || type: int || format: -0.5
    %       varargin{2}: file                                  || required: False || type: string || format: "file"
    %       varargin{3}: file of file                          || required: False || type: string || format: "ECS6.2dm"
    %       varargin{4}: save_path                             || required: False || type: string || format: "save_path"
    %       varargin{5}: save_path of save_path                || required: False || type: string || format: "/home/ocean/"
    %       varargin{6}: read_method                           || required: False || type: string || format: "read_method"
    %       varargin{7}: read_method of read_method            || required: False || type: string || format: "Christmas"
    % =================================================================================================================
    % example:
    %       read_2dm_to_msh(-0.5)
    %       read_2dm_to_msh(-0.5,"file","ECS6.2dm")
    %       read_2dm_to_msh(-0.5,"file","ECS6.2dm","save_path","/home/ocean/")
    %       read_2dm_to_msh(-0.5,"file","ECS6.2dm","read_method","read_method")
    % =================================================================================================================

end