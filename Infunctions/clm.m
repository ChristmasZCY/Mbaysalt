function clm(varargin)
    %       Means: clear clc close all
    % =================================================================================================================
    % Parameters:
    %       varargin: (input argument) 
    %           'cmd' : 'clear', 'clc', 'close all', 'noclose', 'clf' || required: False || type: text || example: 'clc'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created,            by Christmas;
    %       2024-05-30:     Added 'noclose',    by Christmas;
    %       2024-09-19:     Fixed 'noclose',    by Christmas;
    % =================================================================================================================
    % Example:
    %       clm()
    %       clm('clear')
    %       clm('clc')
    %       clm('noclose')
    % =================================================================================================================

    arguments(Input,Repeating)
        varargin {mustBeMember(varargin,{'clear','close all','clc', 'noclose', 'clf'})}
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
            figs = findobj('Type', 'figure');
            if ~isempty(figs)
                shg
                clf
            end
        case 'clf'
            clf
            monitor_positions = get(0, 'MonitorPositions');
            if nargin > 1
                pos = varargin{2};
            else
                pos = size(monitor_positions,1);
            end

            set(gcf, 'Units', 'pixels', ...
    'Position', [monitor_positions(pos,1), monitor_positions(pos,2), monitor_positions(pos,3), monitor_positions(pos,4)]);

        otherwise
            error('Error: Invalid input argument')
        end
    end
end
