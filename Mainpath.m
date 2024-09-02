function varargout = Mainpath(varargin)
    %       Mainpath is a function to add all path of this package
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters      
    %           add:        add all path                    || required: False|| type: Text || format: 'add'
    %           rm:         remove all path                 || required: False|| type: Text || format: 'rm'
    %           noclone:    add all path without clone git  || required: False|| type: Text || format: 'noclone'
    %           init:       Initialize                      || required: False|| type: Text || format: 'init',true
    %           cd:         cd here                         || required: False|| type: Text || format: 'cd'
    %           noset:      no set pref                     || required: False|| type: Text || format: 'noset'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created, by Christmas;
    %       2023-12-27:     Added check_command, OceanData, FVCOM_NML, by Christmas;
    %       2024-01-02:     Added path pref, by Christmas;
    %       2024-01-31:     Added gitclone(built-in) and return clones info, by Christmas;
    %       2024-02-05:     Added 'cd' feature, by Christmas;
    %       2024-02-22:     Added Exfunctions-kmz2struct, by Christmas;
    %       2024-02-22:     Added Exfunctions/SupplementFiles for toolox, by Christmas;
    %       2024-03-17:     Added Exfunctions/inpolygons-pkg for toolox, by Christmas;
    %       2024-03-21:     Added seawater, GSW, WindRose toolbox , by Christmas; 
    %       2024-03-21:     Extract download,unzip to function, by Christmas; 
    %       2024-04-01:     Added Post_mitgcm, MITgcmTools, by Christmas; 
    %       2024-04-03:     Added install DHI-MATLAB-Toolbox,   by Christmas;
    %       2024-04-04:     Added noset,   by Christmas;
    %       2024-04-07:     Fixed init, change noset,    by Christmas;
    %       2024-04-18:     Added lanczosfilter, CallCodes, by Christmas;
    %       2024-04-23:     Changed TMDToolbox to TMDToolbox_v2_5,  by Christmas;
    %       2024-04-23:     Added TMDToolbox_v3_0, ellipse, JSONLab, MEXNC,  by Christmas;
    %       2024-04-26:     Added OceanMesh2D, ann_wrapper,  by Christmas;
    %       2024-08-30:     Code Refactoring, by Christmas;
    % =================================================================================================================
    % Examples:
    %       Mainpath                        % Add all path
    %       Mainpath('add')                 % Add all path
    %       Mainpath('rm')                  % Remove all path
    %       Mainpath('noclone')             % Add all path without clone git
    %       Mainpath('init', true)          % Initialize
    %       Mainpath('cd')                  % Change current directory to the path of this function
    %       Mainpath('noset', true)         % Do not set pref
    %       Mainpath('add','init', true)    % Initialize and add all path
    % =================================================================================================================
    
    arguments(Input, Repeating)
        varargin
    end

    warning('Not recommended now, please use "ST_Mbaysalt" instead of "Mainpath"!');

    ST_Mbaysalt(varargin{:});

end
