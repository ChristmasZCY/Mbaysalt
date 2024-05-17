clm

obs = target_vars3(1,:);
pre = target_vars3(2,:);

C = allstats(obs,pre);
MYSTATS(1,:) = C(:,2);
stdev = MYSTATS(1,2);
MYSTATS(1,2)=MYSTATS(1,2)/stdev; % 标准化处理
MYSTATS(1,3)=MYSTATS(1,3)/stdev; % 标准化处理

%% 泰勒图绘制与保存
%  [hp ht axl] = taylordiag(STDs,RMSs,CORs,['option',value])
% STDs: Standard deviations RMSs: Centered Root Mean Square Difference 
% CORs: Correlation
 [hp,ht,axl] =taylordiag(MYSTATS(:,2),MYSTATS(:,3),MYSTATS(:,4), ...
                 'tickrms',[0:.2:1],'titleRMS', 1 ,'showlabelsRMS',1,... 
                 'widthRMS',1,'colRMS',[0,0.6,0],...
                 'tickSTD',[0:.25:1.25],'limSTD',1.25,'styleSTD','-',... 
                 'tickCOR',[.1:.1:.9 .95 .99],'showlabelsCOR',1,'titleCOR',1);
title(sprintf('%s: Taylor Diagram of DIR at Buoy','Fig2'),'fontweight','bold');
% print('-djpeg', '-r400',[path0,'/save/平均波向泰勒图']); 
