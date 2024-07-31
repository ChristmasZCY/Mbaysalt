classdef SSpiral < handle
% Copyright (c) 2024, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). Spiral diagram 
% (https://www.mathworks.com/matlabcentral/fileexchange/164966-spiral-diagram), 
% MATLAB Central File Exchange. Retrieved May 1, 2024.
    properties
        ax,
        XLim, XTick, XMinorTick = 'on';
        YLim, YTick,
        Height = 1;
        BackgroundColor = [239,239,239]./255
        TLim = [0, 2*360]
        TickLength = [.055, .02];
        TickColor = [0,0,0];
        TickWidth = 1;
        XTickLabel
        YTickLabel
        TickLabelFont = {'FontSize',10, 'FontName','Times New Roman'}
        TickLabelFormat = @(x) num2str(x)
        arginList = {'XLim', 'YLim', 'TLim', 'XTick', 'YTick', 'Height',...
                      'BackgroundColor', 'TickLength', 'TickColor', 'TickWidth',...
                      'TickLabelFont', 'TickLabelFormat', 'TickLabel', ...
                      'XMinorTick', 'YMinorTick', 'XTickLabel', 'YTickLabel'}
        ColorOrder = [    0.2392    0.4627    0.6392
            0.3686    0.6784    0.7451
            0.3686    0.6314    0.4627
            0.6549    0.3804    0.1373
            0.4784    0.2510    0.0941
            0.7059    0.5529    0.2824
            0.4627    0.4902    0.4627];
        ColorOrderIndex = 1;
        BkgHdl, XTickHdl, XMinorTickHdl, YTickHdlS, YTickHdlE
    end
% =========================================================================
    methods
        function obj = SSpiral(ax)
            if nargin < 1, ax = gca; end
            obj.ax = ax;
            obj.ax.NextPlot = 'add';
            obj.ax.XGrid = 'off';
            obj.ax.YGrid = 'off';
            obj.ax.Box = 'off';
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.ax.DataAspectRatio = [1,1,1];
            help SSpiral
            obj.drawAxes(0)
        end
% =========================================================================
        function set(obj, varargin)
            for i = 1:2:(length(varargin)-1)
                tid = ismember(obj.arginList, varargin{i});
                if any(tid)
                obj.(obj.arginList{tid}) = varargin{i+1};
                end
            end
            obj.drawAxes(1)
        end
% =========================================================================
        function drawAxes(obj, flag)
            tT  = linspace(obj.TLim(1), obj.TLim(2), ceil(abs(diff(obj.TLim)))+10)./180.*pi;
            tX1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*cos(tT);
            tY1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*sin(tT);
            tL  = vecnorm([tX1;tY1]);
            tX2 = tX1./tL.*(tL + obj.Height.*2.*pi);
            tY2 = tY1./tL.*(tL + obj.Height.*2.*pi);
            tX  = [tX1, tX2(end:-1:1)];
            tY  = [tY1, tY2(end:-1:1)];
            if flag == 0 
                obj.BkgHdl = fill(obj.ax, tX,tY,obj.BackgroundColor, 'EdgeColor','none');
                obj.BkgHdl.Annotation.LegendInformation.IconDisplayStyle='off';
                
            else
                set(obj.BkgHdl, 'XData',tX, 'YData',tY, 'FaceColor',obj.BackgroundColor)
            end
            if ~isempty(obj.XLim) && ~isempty(obj.YLim)
                if isempty(obj.XTick)
                    tXT = obj.getTick(obj.XLim, (abs(diff(obj.TLim))/360)*10);
                else 
                    tXT = obj.XTick;
                    tXT(tXT<obj.XLim(1)) = [];
                    tXT(tXT>obj.XLim(2)) = [];
                end
                if isempty(obj.YTick)
                    tYT = obj.getTick(obj.YLim, 2);
                else
                    tYT = obj.XTick;
                    tYT(tYT<obj.YLim(1)) = [];
                    tYT(tYT>obj.YLim(2)) = [];
                end
                % ---------------------------------------------------------
                tMXTD = diff(tXT);
                tMXT  = tXT(1) - tMXTD(1) : tMXTD(1)/5 : tXT(end) + tMXTD(1);
                tMXT(tMXT<obj.XLim(1)) = [];
                tMXT(tMXT>obj.XLim(2)) = [];
                % ---------------------------------------------------------
                tT  = (tXT-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
                tT  = tT./180.*pi;
                tX1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*cos(tT);
                tY1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*sin(tT);
                tL  = vecnorm([tX1; tY1]);
                tX2 = tX1./tL.*(tL + obj.Height.*2.*pi);
                tY2 = tY1./tL.*(tL + obj.Height.*2.*pi);
                tX3 = tX1./tL.*(tL + obj.Height.*2.*pi + obj.TickLength(1).*2.*pi);
                tY3 = tY1./tL.*(tL + obj.Height.*2.*pi + obj.TickLength(1).*2.*pi);
                tX  = [tX2; tX3; tX2.*nan]; tX = tX(:);
                tY  = [tY2; tY3; tY2.*nan]; tY = tY(:);
                % ---------------------------------------------------------
                tMT  = (tMXT-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
                tMT  = tMT./180.*pi;
                tMX1 = (3.77 + 1.4.*abs(tMT-obj.TLim(1)./180.*pi)).*cos(tMT);
                tMY1 = (3.77 + 1.4.*abs(tMT-obj.TLim(1)./180.*pi)).*sin(tMT);
                tML  = vecnorm([tMX1; tMY1]);
                tMX2 = tMX1./tML.*(tML + obj.Height.*2.*pi);
                tMY2 = tMY1./tML.*(tML + obj.Height.*2.*pi);
                tMX3 = tMX1./tML.*(tML + obj.Height.*2.*pi + obj.TickLength(2).*2.*pi);
                tMY3 = tMY1./tML.*(tML + obj.Height.*2.*pi + obj.TickLength(2).*2.*pi);
                tMX  = [tMX2; tMX3; tMX2.*nan]; tMX = tMX(:);
                tMY  = [tMY2; tMY3; tMY2.*nan]; tMY = tMY(:);
                % ---------------------------------------------------------
                if isempty(obj.XTickHdl)
                    obj.XTickHdl = plot(tX, tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth);
                    obj.XTickHdl.Annotation.LegendInformation.IconDisplayStyle='off';
                else
                    set(obj.XTickHdl, 'XData',tX, 'YData',tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth)
                end
                if isempty(obj.XMinorTickHdl)
                    obj.XMinorTickHdl = plot(tMX, tMY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth, 'Visible',obj.XMinorTick);
                    obj.XMinorTickHdl.Annotation.LegendInformation.IconDisplayStyle='off';
                else
                    set(obj.XMinorTickHdl, 'XData',tMX, 'YData',tMY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth, 'Visible',obj.XMinorTick)
                end
                % ---------------------------------------------------------
                tObj = findobj(obj.ax,'Tag','SSpiralTxt'); delete(tObj);
                for i = 1:length(tX3)
                    tR = -90+tT(i)/pi*180;
                    if isempty(obj.XTickLabel)
                        tLbl = obj.TickLabelFormat(tXT(i));
                    else
                        tLbl = obj.XTickLabel{min(i,length(obj.XTickLabel))};
                    end
                    if mod(tT(i)/pi*180, 360) >180
                        tR = tR +180;
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                        'HorizontalAlignment','center', 'VerticalAlignment','top',...
                        'Rotation', tR, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    else
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                        'HorizontalAlignment','center', 'VerticalAlignment','bottom',...
                        'Rotation', tR, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    end      
                end
                % ---------------------------------------------------------
                tX1 = cos(obj.TLim(1)/180*pi).*((tYT-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77);
                tY1 = sin(obj.TLim(1)/180*pi).*((tYT-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77);
                tT = (obj.TLim(1) - 2.*((diff(obj.TLim)>0)-.5).*(90 + 15))/180*pi;
                tX2 = tX1 + cos(tT).*obj.TickLength(1).*2.*pi;
                tY2 = tY1 + sin(tT).*obj.TickLength(1).*2.*pi;
                tX3 = tX1 + cos(tT).*obj.TickLength(1).*1.5.*2.*pi;
                tY3 = tY1 + sin(tT).*obj.TickLength(1).*1.5.*2.*pi;
                tX  = [tX1; tX2; tX2.*nan]; tX = tX(:);
                tY  = [tY1; tY2; tY2.*nan]; tY = tY(:);
                if isempty(obj.YTickHdlS)
                    obj.YTickHdlS= plot(tX, tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth);
                    obj.YTickHdlS.Annotation.LegendInformation.IconDisplayStyle='off';
                else
                    set(obj.YTickHdlS, 'XData',tX, 'YData',tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth)
                end
                tR = tT/pi*180;
                for i = 1:length(tX2)
                    if isempty(obj.YTickLabel)
                        tLbl = obj.TickLabelFormat(tYT(i));
                    else
                        tLbl = obj.YTickLabel{min(i,length(obj.YTickLabel))};
                    end
                    if mod(tR, 360) > 90 && mod(tR, 360) < 270
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                            'HorizontalAlignment','right', 'VerticalAlignment','middle',...
                            'Rotation', tR + 180, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    else
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                            'HorizontalAlignment','left', 'VerticalAlignment','middle',...
                            'Rotation', tR, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    end

                end
                % ---------------------------------------------------------
                tX1 = cos(obj.TLim(2)/180*pi).*((tYT-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((obj.TLim(2)-obj.TLim(1))./180.*pi));
                tY1 = sin(obj.TLim(2)/180*pi).*((tYT-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((obj.TLim(2)-obj.TLim(1))./180.*pi));
                tT  = (obj.TLim(2) + 2.*((diff(obj.TLim)>0)-.5).*(90))/180*pi;
                tX2 = tX1 + cos(tT).*obj.TickLength(1).*2.*pi;
                tY2 = tY1 + sin(tT).*obj.TickLength(1).*2.*pi;
                tX3 = tX1 + cos(tT).*obj.TickLength(1).*1.5.*2.*pi;
                tY3 = tY1 + sin(tT).*obj.TickLength(1).*1.5.*2.*pi;
                tX  = [tX1; tX2; tX2.*nan]; tX = tX(:);
                tY  = [tY1; tY2; tY2.*nan]; tY = tY(:);
                if isempty(obj.YTickHdlE)
                    obj.YTickHdlE = plot(tX, tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth);
                    obj.YTickHdlE.Annotation.LegendInformation.IconDisplayStyle='off';
                else
                    set(obj.YTickHdlE, 'XData',tX, 'YData',tY, 'Color',obj.TickColor, 'LineWidth',obj.TickWidth)
                end
                tR = tT/pi*180;
                for i = 1:length(tX2)
                    if isempty(obj.YTickLabel)
                        tLbl = obj.TickLabelFormat(tYT(i));
                    else
                        tLbl = obj.YTickLabel{min(i,length(obj.YTickLabel))};
                    end
                    if mod(tR, 360) > 90 && mod(tR, 360) < 270
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                            'HorizontalAlignment','right', 'VerticalAlignment','middle',...
                            'Rotation', tR + 180, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    else
                        text(obj.ax,tX3(i),tY3(i),tLbl,...
                            'HorizontalAlignment','left', 'VerticalAlignment','middle',...
                            'Rotation', tR, obj.TickLabelFont{:},'Tag','SSpiralTxt')
                    end

                end
            end
            axis tight
            obj.ax.XLim = obj.ax.XLim + [-1,1].*max(obj.ax.XLim).*.1;
            obj.ax.YLim = obj.ax.YLim + [-1,1].*max(obj.ax.YLim).*.1;
        end
% =========================================================================
        function ticks = getTick(~, XLim, N)
            tXS = abs(diff(XLim)) / N;
            tXN = ceil(log(tXS) / log(10));
            tXS = round(round(tXS / 10^(tXN-2)) / 5) * 5 * 10^(tXN-2);
            tON = ceil(log(abs(XLim(1))) / log(10));
            tON(isinf(tON)) = 1;
            tOS = round(round(XLim(1) / 10^(tON-2)) / 5) * 5 * 10^(tON-2);
            ticks = tOS:tXS:XLim(2);
        end
% =========================================================================
        function barHdl = bar(obj, Y, varargin)
            arginListBar = {'FaceColor', 'EdgeColor', 'FaceAlpha', 'EdgeAlpha',...
                            'LineWidth', 'BarWidth', 'CData'};
            barProp.FaceColor = [];
            barProp.EdgeColor = [0,0,0];
            barProp.FaceAlpha = 1;
            barProp.EdgeAlpha = 1;
            barProp.LineWidth = .5;
            barProp.BarWidth = 1;
            if isempty(varargin) || ischar(varargin{1})
                if size(Y,1) == 1
                    barProp.XData = 1:size(Y,2);
                    barProp.YData = Y;
                else
                    barProp.XData = 1:size(Y,1);
                    barProp.YData = Y.';
                end
            else
                barProp.XData = Y(:).';
                barProp.YData = varargin{1}; varargin(1) = [];
                if size(barProp.XData,1) == 1
                else
                    barProp.YData = barProp.YData.';
                end
            end

            for i = 1:2:(length(varargin)-1)
                tid = ismember(arginListBar, varargin{i});
                if any(tid)
                    barProp.(arginListBar{tid}) = varargin{i+1};
                end
            end
            % if isempty(barProp.FaceColor)
            %     if size(barProp.YData,1) > 1
            %         barProp.FaceColor = obj.ColorOrder(mod(obj.ColorOrderIndex + (0:size(areaProp.YData,1)-1) -1, size(obj.ColorOrder,1)) + 1, :);
            %         obj.ColorOrderIndex = obj.ColorOrderIndex + size(areaProp.YData,1);
            %     else
            %         barProp.FaceColor = obj.ColorOrder(mod(obj.ColorOrderIndex-1, size(obj.ColorOrder,1)) + 1, :);
            %         obj.ColorOrderIndex = obj.ColorOrderIndex + 1;
            %     end
            % end
            if isempty(barProp.FaceColor)
                barProp.FaceColor = obj.ColorOrder(mod(obj.ColorOrderIndex + (0:size(barProp.YData,1)-1) -1, size(obj.ColorOrder,1)) + 1, :);
                obj.ColorOrderIndex = obj.ColorOrderIndex + size(barProp.YData,1);
            end
            bX1 = linspace(-.5.*barProp.BarWidth, .5.*barProp.BarWidth, 50);
            CY1 = zeros(1,size(barProp.YData,2));
            CY2 = zeros(1,size(barProp.YData,2));
            % if size(barProp.YData,1) > 1
                for i = 1:size(barProp.YData,1)
                    tX = repmat(barProp.XData(:), [1,100]) + repmat([bX1, bX1(end:-1:1)], [size(barProp.YData,2),1]);
                    tY = [repmat(barProp.YData(i,:).', [1,50]), zeros(size(barProp.YData,2),50)] + repmat(CY1(:).*(barProp.YData(i,:).'>0) + CY2(:).*(barProp.YData(i,:).'<0), [1,100]);
                    CY1 = CY1 + barProp.YData(i,:).*(barProp.YData(i,:)>0);
                    CY2 = CY2 + barProp.YData(i,:).*(barProp.YData(i,:)<0);
                    tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
                    tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
                    tT = tT.'; tR = tR.';
                    barHdl(i,:) = fill(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, barProp.FaceColor(i,:), 'EdgeColor',barProp.EdgeColor,...
                        'LineWidth',barProp.LineWidth, 'FaceAlpha',barProp.FaceAlpha, 'EdgeAlpha',barProp.EdgeAlpha);
                    for j = 2:length(barHdl)
                        barHdl(i,j).Annotation.LegendInformation.IconDisplayStyle='off';
                    end
                end
            % else
            %     % for i = 1:size(barProp.YData,2)
            %     %     tX = barProp.XData(i) + [-.5.*barProp.BarWidth, bX, .5.*barProp.BarWidth];
            %     %     tY = [barProp.YData(i), zeros(1,50), barProp.YData(i)];
            %     %     tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
            %     %     tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
            %     %     barHdl(i) = fill(obj.ax, cos(tT/180*pi).*tR,sin(tT/180*pi).*tR, barProp.FaceColor, 'EdgeColor',barProp.EdgeColor,...
            %     %         'LineWidth',barProp.LineWidth, 'FaceAlpha',barProp.FaceAlpha, 'EdgeAlpha',barProp.EdgeAlpha);
            %     % end
            %     tX = repmat(barProp.XData(:), [1,100]) + repmat([bX1, bX1(end:-1:1)], [size(barProp.YData,2),1]);
            %     tY = [repmat(barProp.YData(:), [1,50]), zeros(size(barProp.YData,2),50)];
            %     tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
            %     tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
            %     tT = tT.'; tR = tR.';
            %     barHdl = fill(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, barProp.FaceColor, 'EdgeColor',barProp.EdgeColor,...
            %         'LineWidth',barProp.LineWidth, 'FaceAlpha',barProp.FaceAlpha, 'EdgeAlpha',barProp.EdgeAlpha);
            %     for i = 2:length(barHdl)
            %         barHdl(i).Annotation.LegendInformation.IconDisplayStyle='off';
            %     end
            % end
        end

        function areaHdl = area(obj, X, Y, varargin)
            arginListBar = {'FaceColor', 'EdgeColor', 'FaceAlpha', 'EdgeAlpha',...
                            'LineWidth', 'BarWidth', 'CData'};
            areaProp.FaceColor = [];
            areaProp.EdgeColor = 'none';
            areaProp.FaceAlpha = .5;
            areaProp.EdgeAlpha = 1;
            areaProp.LineWidth = .5;
            areaProp.XData = X(:).';
            areaProp.YData = Y.';
            for i = 1:2:(length(varargin)-1)
                tid = ismember(arginListBar, varargin{i});
                if any(tid)
                    areaProp.(arginListBar{tid}) = varargin{i+1};
                end
            end
            if isempty(areaProp.FaceColor)
                areaProp.FaceColor = obj.ColorOrder(mod(obj.ColorOrderIndex + (0:size(areaProp.YData,1)-1) -1, size(obj.ColorOrder,1)) + 1, :);
                obj.ColorOrderIndex = obj.ColorOrderIndex + size(areaProp.YData,1);
            end
            bX1 = linspace(areaProp.XData(1), areaProp.XData(end), length(areaProp.XData)*10);
            CY1 = zeros(1, length(areaProp.XData)*10);
            CY2 = zeros(1, length(areaProp.XData)*10);
            for i = 1:size(areaProp.YData,1)
                tX = [bX1, bX1(end:-1:1)];
                tYq = interp1(areaProp.XData, areaProp.YData(i,:), bX1);
                tY = [tYq, zeros(1,length(bX1))] + [CY1,CY1(end:-1:1)].*([tYq,tYq(end:-1:1)]>0) + [CY2,CY2(end:-1:1)].*([tYq,tYq(end:-1:1)]<0);%repmat(CY1.*(tYq>0) + CY2.*(tYq<0), [1,2]);
                CY1 = CY1 + tYq.*(tYq>0);
                CY2 = CY2 + tYq.*(tYq<0);
                tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
                tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
                areaHdl(i) = fill(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, areaProp.FaceColor(i,:), 'EdgeColor',areaProp.EdgeColor,...
                        'LineWidth',areaProp.LineWidth, 'FaceAlpha',areaProp.FaceAlpha, 'EdgeAlpha',areaProp.EdgeAlpha);
            end
        end
        function plotHdl = plot(obj, X, Y, varargin)
            if any(size(X) == 1)
                tN = length(X);
            else
                tN = size(X,1);
            end
            tTq = linspace(1, tN, (tN-1)*10+1);
            tX = interp1(1:tN, X, tTq);
            tY = interp1(1:tN, Y, tTq);
            tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
            tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
            plotHdl = plot(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, 'MarkerIndices',1:10:(tN-1)*10+1, varargin{:});
        end
        function lineHdl = line(obj, X, Y, varargin)
            if any(size(X) == 1)
                tN = length(X);
            else
                tN = size(X,1);
            end
            for i = 1:size(Y,2)
                tNq = ceil((max(max(X(:,i)))-min(min(X(:,i))))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)))/2+10;
                tTq = linspace(1, tN, tNq);
                tX = interp1(1:tN, X(:,i), tTq);
                tY = interp1(1:tN, Y(:,i), tTq);
                tT = (tX-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
                tR = (tY-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
                lineHdl(i) = plot(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, varargin{:},'Marker','none');
            end
        end
        function scatterHdl = scatter(obj, X, Y, varargin)
            tT = (X-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)).*2.*((diff(obj.TLim)>0)-.5) + obj.TLim(1);
            tR = (Y-obj.YLim(1))./abs(diff(obj.YLim)).*(obj.Height.*2.*pi) + 3.77 + 1.4.*abs((tT-obj.TLim(1))./180.*pi);
            scatterHdl = scatter(obj.ax, cos(tT./180.*pi).*tR,sin(tT./180.*pi).*tR, varargin{:});
        end
        function regionHdl = xregion(obj, Lim, varargin)
            Lim = (Lim-obj.XLim(1))./abs(diff(obj.XLim)).*abs(diff(obj.TLim)) + obj.TLim(1);
            tT  = linspace(Lim(1), Lim(2), ceil(abs(diff(Lim)))+10)./180.*pi;
            tX1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*cos(tT);
            tY1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*sin(tT);
            tL  = vecnorm([tX1;tY1]);
            tX2 = tX1./tL.*(tL + obj.Height.*2.*pi);
            tY2 = tY1./tL.*(tL + obj.Height.*2.*pi);
            tX  = [tX1, tX2(end:-1:1)];
            tY  = [tY1, tY2(end:-1:1)];
            regionHdl = fill(obj.ax, tX,tY, [114,146,184]./255, 'EdgeColor','none', 'FaceAlpha',.5, varargin{:});
        end
        function regionHdl = yregion(obj, Lim, varargin)
            tT  = linspace(obj.TLim(1), obj.TLim(2), ceil(abs(diff(obj.TLim)))+10)./180.*pi;
            tX1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*cos(tT);
            tY1 = (3.77 + 1.4.*abs(tT-obj.TLim(1)./180.*pi)).*sin(tT);
            tL  = vecnorm([tX1;tY1]);
            tX2 = tX1./tL.*(tL + obj.Height.*2.*pi.*(Lim(1)-obj.YLim(1))./abs(diff(obj.YLim)));
            tY2 = tY1./tL.*(tL + obj.Height.*2.*pi.*(Lim(1)-obj.YLim(1))./abs(diff(obj.YLim)));
            tX3 = tX1./tL.*(tL + obj.Height.*2.*pi.*(Lim(2)-obj.YLim(1))./abs(diff(obj.YLim)));
            tY3 = tY1./tL.*(tL + obj.Height.*2.*pi.*(Lim(2)-obj.YLim(1))./abs(diff(obj.YLim)));
            tX  = [tX2, tX3(end:-1:1)];
            tY  = [tY2, tY3(end:-1:1)];
            regionHdl = fill(obj.ax, tX,tY, [114,146,184]./255, 'EdgeColor','none', 'FaceAlpha',.5, varargin{:});
        end
    end
end