function clm(varargin)
    %       Means: clear clc close all
    % =================================================================================================================
    % Parameters:
    %       varargin: (input argument) 
    %           'cmd' : 'clear', 'clc', 'close all', 'noclose' || required: False || type: text || example: 'clc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created,            by Christmas;
    %       2024-05-30:     Added 'noclose',    by Christmas;
    % =================================================================================================================
    % Example:
    %       clm()
    %       clm('clear')
    %       clm('clc')
    %       clm('noclose')
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin {mustBeMember(varargin,{'clear','close all','clc', 'noclose'})}
    end

    if nargin == 0
        evalin('base', 'clear');
        clc 
        close all
    else
        str = varargin{1};
        switch str
        case 'clear'
            evalin('base', 'clear all');
        case 'clc'
            clc
        case 'close all'
            close all
        case 'noclose'
            evalin('base', 'clear');
            clc
        otherwise
            error('Error: Invalid input argument')
        end
    end
end
