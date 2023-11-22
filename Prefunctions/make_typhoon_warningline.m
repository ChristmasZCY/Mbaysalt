function make_typhoon_warningline(varargin)
    %       make typhoon warning line
    % =================================================================================================================
    % Parameter:
    %       varargin{1}: 24 or 48 hours || required: True || type: double || format: martix
    %       varargin{2}: 24 or 48 hours || required: True || type: double || format: martix
    % =================================================================================================================
    % Example:
    %       make_typhoon_warningline(24)
    %       make_typhoon_warningline(24,48)
    %       make_typhoon_warningline(48)
    % =================================================================================================================

%% 24小时和48小时警戒线部分

if varargin{1} == 24
    % 24小时警戒线,纬度在前经度在后，相当于[y,x]
    % [34, 127], [22, 127],[18, 119], [11, 119],[4.5, 113], [0, 105]

    m_plot([127 127],[34 22],'color','y','LineStyle','-','LineWidth',1.4);
    m_plot([127 119],[22 18],'color','y','LineStyle','-','LineWidth',1.4);
    m_plot([119 119],[18 11],'color','y','LineStyle','-','LineWidth',1.4);
    m_plot([119 113],[11 4.5],'color','y','LineStyle','-','LineWidth',1.4);
    m_plot([113 105],[4.5 0],'color','y','LineStyle','-','LineWidth',1.4);
end

if varargin{1} == 48 | varargin{2} == 48 
    % 48小时警戒线,纬度在前经度在后，相当于[y,x]
    %[34, 132], [15, 132], [0, 120], [0, 105]
    
    m_plot([132 132],[34 15],'color','y','LineStyle','--','LineWidth',1.4);
    m_plot([132 120],[15 0],'color','y','LineStyle','--','LineWidth',1.4);
    m_plot([120 105],[0 0],'color','y','LineStyle','--','LineWidth',1.4);
end
