function cm_disp2(varargin)
    %       Disp MATLAB colormap
    % =================================================================================================================
    % Parameters:
    %       None
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-03-25:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       cm_disp2
    % =================================================================================================================
    
    
    ymax = 40;
    cmaps = colormaplist;
    n = len(cmaps);
    
    disp('--------------------------------')
    disp('colormap list:')
    
    figure
    for inum = 1 : n
    
        cm_name = convertStringsToChars(cmaps(inum));
        cm = colormap(cmaps(inum));
        disp(['   ' cm_name])
    
        subplot(n,1,inum)
        hold on
        box off
        for i = 1 : size(cm, 1)
            x = [i-1 i i i-1 i-1];
            y = [0 0 ymax ymax 0];
            patch(x, y, cm(i,:), 'EdgeColor', 'none')
        end
    
        for i = 0:32:256
            plot([i i], [0 ymax], 'k-')
        end
    
        axis equal
        set(gca, 'xtick', [])
        set(gca, 'ytick', [])
        %     set(gca, 'xlim', [0 256])
        set(gca, 'xlim', [0 size(cm, 1)])
        set(gca, 'ylim', [0 ymax])
        set(get(gca,'YLabel'), 'Rotation', 0, 'HorizontalAlignment','right')
        ylabel(strrep(cm_name, '_', '\_'))

    end

end
