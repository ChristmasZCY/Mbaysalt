function figcopy(varargin)
    %       Copy the figure to the clipboard
    % =================================================================================================================
    % Parameters:
    %   varargin: (optional) 
    %       fig:        figure handle       || required: positional || type: figure || example: gcf
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-09-19:     Created,    by Christmas;
    % =================================================================================================================
    % Examples:
    %       figcopy;
    %       figcopy(gcf);
    % =================================================================================================================

    if len(varargin) >0 && isa(varargin{1},'matlab.ui.Figure')
        fig = varargin{1};
        varargin(1) = [];
    else
        fig = gcf;
    end

    copygraphics(fig);

    contents = clipboard('paste');
    if len(contents) == 0
        print(fig,'-clipboard','-dbitmap');
    end
end
