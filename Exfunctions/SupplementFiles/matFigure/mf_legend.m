%==========================================================================
%
%
% input  :
% 
% output :
%
% Siqi Li, SMAST
% yyyy-mm-dd
%
% Updates:
%
%==========================================================================
function hl = mf_legend(target, label, NumColumns, varargin)

hl = legend(target, label);
hl.EdgeColor = 'none';
hl.AutoUpdate = 'off';
hl.NumColumns = NumColumns;

% hl.IconColumnWidth = 5;  图标的宽度
% hl.BackgroundAlpha = .5; 透明度
% hl.Direction = "reverse"; 图例方向
% ./Mbaysalt/Docs/pics/matlab_legend.png

if ~isempty(varargin)
    set(hl, varargin{:})
end
