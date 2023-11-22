function cc = make_colormap(mode, varargin)
    %       make_colormap is a function to create a colormap from a list of colors
    % =================================================================================================================
    % Parameter:
    %       mode: 1 or 2 || required: True || type: char || format: martix
    %       cc: colormap || required: True || type: char || format: martix
    % =================================================================================================================
    % Example:
    %       cc = make_colormap(1);
    %       cc = make_colormap(2);
    % =================================================================================================================

    switch mode
        case {'1', 1}
            rr(1:10,1) = 0;                     % 0 0 1
            gg(1:10,1) = linspace(0,0.9,10);    %  到
            bb(1:10,1) = 1;                     % 0 1 1
            
            rr(11:20,1) = linspace(0,0.9,10);    % 0 1 1
            gg(11:20,1) = 1;                     %  到
            bb(11:20,1) = linspace(1,0.1,10);    % 1 1 0
            
            rr(21:30,1) = 1;                     % 1 1 0
            gg(21:30,1) = linspace(1,0.1,10);    %  到
            bb(21:30,1) = 0;                     % 1 0 0
            
            cc=[rr gg bb];
            clear rr bb gg;
        
        case {'2', 2}
            aa = ((m_colmap('diverging',12)));
            bb = [aa(5,:);aa(3,:);aa(9,:);aa(12,:)];
            map = interp_colormap(bb,60);
            cc = [1,1,1;map;map(end,:)];
            clear aa bb map
    end
end
