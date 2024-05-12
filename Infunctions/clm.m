function clm(varargin)
    %       Means: clear clc close all
    % =================================================================================================================
    % Parameters:
    %       varargin: (input argument) 
    %           'cmd' : 'clear', 'clc', 'close all' || required: False || type: text || example: 'clc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Example:
    %       clm()
    %       clm('clear')
    %       clm('clc')
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin {mustBeMember(varargin,{'clear','close all','clc'})}
    end

    if nargin == 0
        evalin('base', 'clear');
        clc 
        close all
    else
        str = varargin{1};
        if strcmp(str, 'clear')
            evalin('base', 'clear');
        elseif strcmp(str, 'clc')
            clc
        elseif strcmp(str, 'close all')
            close all
        else
            error('Error: Invalid input argument')
        end
    end
end
