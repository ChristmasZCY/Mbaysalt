function varargout = LRC_Demo(varargin)
%Demo to find the largest inscribed rectangle, square or circle  in an arbitary image with multiple holes.

% Last Modified by GUIDE v2.5 09-Oct-2020 09:39:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LRC_Demo_OpeningFcn, ...
                   'gui_OutputFcn',  @LRC_Demo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before LRC_Demo is made visible.
function LRC_Demo_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
movegui(handles.figure1,'west');
pathTop=mfilename('fullpath');
fileseps=strfind(pathTop,filesep);
pathTop=pathTop(1:fileseps(end-1));
addpath(genpath(pathTop));
bgLR=1;%default largest rectangle
if exist([pwd '\LRC_DemoIni.mat'],'file') == 2%LRC_DemoIni.mat existing?
  load('LRC_DemoIni.mat');
  if exist(imFullName,'file') == 2%image file existing?
    [~,imName,ext] = fileparts(imFullName);
    Img=imread(imFullName);
    axes(handles.axImageIn);
    imshow(Img);
    set (handles.txtImg,'string',[imName ext '  ' ...
      num2str(size(Img,1)) 'x' num2str(size(Img,2)) ' px']);
    handles.imFullName=imFullName;
    if bgLR==1
    elseif bgLR==2
      set(handles.rbSquare,'Value',1);
    else
      set(handles.rbCircle,'Value',1);
    end
    set(handles.cmdRun,'Enable','on');
    set(handles.txtRotationStep,'string',num2str(RotationStep));
    set(handles.chkIterate,'value',iterate);
    set(handles.txtFirstAngle,'string',num2str(FirstAngle));
    set(handles.txtLastAngle,'string',num2str(LastAngle));
    set(handles.chkGraphic,'value',Graphic);
    set(handles.chkPlotDetail,'value',PlotDetailValue);
  else
    %set default values
    handles.imFullName=[pwd filesep 'none.none'];
    set (handles.txtImg,'string','none');
    set(handles.txtRotationStep,'string','5');
    set(handles.chkIterate,'value',1);
    set(handles.txtFirstAngle,'string',0);
    set(handles.txtLastAngle,'string',89.9999);
    set(handles.chkGraphic,'value',1);
    set(handles.cmdRun,'Enable','off');
  end
else
  %set default values
  handles.imFullName=[pwd filesep 'none.none'];
  if exist([pwd filesep 'TestImages'],'dir') == 7%Folder TestImages existing?
    handles.imFullName=[pwd filesep 'TestImages' filesep 'none.none'];
  end
end
SetbgLRC(bgLR,handles)
guidata(hObject, handles);
%check for parallel:
if ~isempty(ver('distcomp'))
  set(handles.chkParallel,'visible','on');
end

% --- Outputs from this function are returned to the command line.
function varargout = LRC_Demo_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in cmdSelectImage.
function cmdSelectImage_Callback(hObject, eventdata, handles)
[filepath,~,~] = fileparts(handles.imFullName);
[imName, imPath] = uigetfile({'*.*';'*.tif';'*.png';'*.jpg'},...
  'Select file type and then select a file',[filepath filesep]);
imFullName=fullfile(imPath,imName);
if isequal(imName,0)
  disp('------------------------- Please select an image file! ------------------------');
  return
end
set(handles.cmdRun,'Enable','on');
handles.imFullName=imFullName;
guidata(hObject,handles);
popEnlarge_Callback(hObject, eventdata, handles);%Show image

function cmdRun_Callback(hObject, eventdata, handles)
ErrorDisp=0;
imFullName=handles.imFullName;
image=imread(imFullName);
bgLR=get(handles.bgLRC,'UserData');
% FindRectangle=get(handles.rbRectangle,'Value');
RotationStep=str2double(get(handles.txtRotationStep,'string'));
FirstAngle=str2double(get(handles.txtFirstAngle,'string'));
LastAngle=str2double(get(handles.txtLastAngle,'string'));
PlotDetailValue=handles.chkPlotDetail.Value;%for save LRC_DemoIni.mat
if FirstAngle>LastAngle && bgLR<3
  disp('--------------- FirstAngle must be <= LastAngle!');
  ErrorDisp=1;
elseif FirstAngle==LastAngle
  set(handles.chkIterate,'value',0);
end
Graphic=get(handles.chkGraphic,'value');
if Graphic
  set(handles.txtGraphic,'visible','on');
else
  set(handles.txtGraphic,'visible','off');
end
iterate=get(handles.chkIterate,'value');
if ErrorDisp
  set(handles.txtProcessTime,'string','Input error!');drawnow;
else
  save('LRC_DemoIni.mat','imFullName','bgLR','RotationStep',...
    'iterate','FirstAngle','LastAngle','Graphic','PlotDetailValue');
  set(handles.txtProcessTime,'string','running...');
  popEnlargeValue=2^(get(handles.popEnlarge,'value')-1);
  if popEnlargeValue>1
    if ~islogical(image)
      image=im2bw(image);
    end
    image=imresize(image,popEnlargeValue,'nearest');
  end
  [~,imName,ext] = fileparts(imFullName);
  axes(handles.axImageIn);
  cla reset
  imshow(image);
  set (handles.txtImg,'string',[imName ext '  ' ...
    num2str(size(image,1)) 'x' num2str(size(image,2)) ' px']);
  drawnow;
  tStart = tic;
  if bgLR==1
    %Rectangle
    if get(handles.chkParallel,'Value')
      LRout=LargestRectangleParFor(image,RotationStep,iterate,...
        FirstAngle,LastAngle,Graphic);
    else
      LRout=LargestRectangle(image,RotationStep,iterate,...
        FirstAngle,LastAngle,Graphic);
    end
  elseif bgLR==2
    %Square
    if get(handles.chkParallel,'Value')
      LRout=LargestSquareParFor(image,RotationStep,iterate,...
        FirstAngle,LastAngle,Graphic);
    else
      LRout=LargestSquare(image,RotationStep,iterate,...
        FirstAngle,LastAngle,Graphic);
    end
    handles.Lout=LRout;guidata(hObject, handles);%save LCout
  else
    %Circle
    LCout=LargestCircle(image,Graphic);
    handles.Lout=LCout;guidata(hObject, handles);%save LCout
    ProcessTime = toc(tStart);
    set(handles.txtProcessTime,'string',[num2str(ProcessTime,3) ' s']);
    set(handles.txtDimension,'string',sprintf('%.2f px',LCout(2)));
    set(handles.txtArea,'string',sprintf('%.2f px',LCout(1)));
    set(handles.txtRotation,'string','-   ');
    set(handles.tblXY,'data',{num2str(LCout(3),'%.2f'),num2str(LCout(4),'%.2f')});
    axes(handles.axImageIn);
    hold on;
    plot(LCout(3),LCout(4),'r+')
    th = 0:pi/50:2*pi;
    xunit = LCout(2) * cos(th) + LCout(3);
    yunit = LCout(2) * sin(th) +LCout(4);
    plot(xunit, yunit,'r-');
    PlotDetail(handles);
    return
  end
  ProcessTime = toc(tStart);
  handles.Lout=LRout;guidata(hObject, handles);%save LCout
  PlotDetail(handles)
  LRoutCf=arrayfun(@(x) ['  ' sprintf('%.1f',x)],LRout(2:5,:),'UniformOutput',false);
  set(handles.tblXY,'data',LRoutCf);
  L2=sqrt((LRout(3,1)-LRout(2,1))^2+(LRout(3,2)-LRout(2,2))^2)+1;
  L1=sqrt((LRout(2,1)-LRout(5,1))^2+(LRout(5,2)-LRout(2,2))^2)+1;
  set(handles.txtDimension,'string',sprintf('%.0f x %.0f px',L1,L2));
  set(handles.txtArea,'string',sprintf('%.0f px',LRout(1)));
  set(handles.txtRotation,'string',sprintf('%.2f°',LRout(1,2)));
  set(handles.txtProcessTime,'string',[num2str(ProcessTime,3) ' s']);
  axes(handles.axImageIn);
  hold on;
  x=[LRout(2:5,1);LRout(2,1)];
  y=[LRout(2:5,2);LRout(2,2)];
  plot(x,y,'r-','LineWidth',1);
  hold off;
end

function chkParallel_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  %check if pool is running
  if isempty(gcp('nocreate'))
    set(handles.cmdRun,'Enable','off');
    set(handles.cmdRun,'string','WAIT...');drawnow;
    parpool;
    set(handles.cmdRun,'string','run');
    imFullName=handles.imFullName;
    if ~strcmp(imFullName(end-4:end),'.none')
      set(handles.cmdRun,'Enable','on');
    end
  end
  % else
  %   delete(gcp('nocreate'));
end

% --- Executes when selected object is changed in bgLRC.
function bgLRC_SelectionChangedFcn(hObject, eventdata, handles)
%Select Largest rectangle, Largest square or Largest circle
bgLRCnewValue=eventdata.NewValue.UserData;
SetbgLRC(bgLRCnewValue,handles)

function SetbgLRC(bgLRCnewValue,handles)
handles.bgLRC.UserData=bgLRCnewValue;
if bgLRCnewValue==1
  %Largest rectangle
  handles.chkParallel.Enable='on';
  handles.panelLR.Visible='on';
  set(handles.txtCorner,'string','Corner positions of largest rectangle');
  set(handles.txtDimRadius,'string','Dimension:');
  set(handles.tblXY, 'TooltipString', sprintf('1 top corner\n2 right corner\n3 bottom corner\n4 left corner'))
elseif bgLRCnewValue==2
  %Largest square
  handles.chkParallel.Enable='on';
  handles.panelLR.Visible='on';
  set(handles.txtCorner,'string','Corner positions of largest square');
  set(handles.txtDimRadius,'string','Dimension:');
  set(handles.tblXY, 'TooltipString', sprintf('1 top corner\n2 right corner\n3 bottom corner\n4 left corner'))
else
  %Largest circle
  handles.chkParallel.Enable='off';
  handles.panelLR.Visible='off';
  set(handles.txtCorner,'string','Center position of largest circle');
  set(handles.txtDimRadius,'string','Radius:');
  set(handles.tblXY, 'TooltipString', sprintf('x-position and y-position of circle center'))
end
% --- Executes on selection change in popEnlarge.
function popEnlarge_Callback(hObject, eventdata, handles)
imFullName=handles.imFullName;
[~,imName,ext] = fileparts(imFullName);
if strcmp([imName ext],'none.none')
  return
end
image=imread(imFullName);
popEnlargeValue=2^(get(handles.popEnlarge,'value')-1);
if popEnlargeValue>1
  if ~islogical(image)
    image=im2bw(image);
  end
  image=imresize(image,popEnlargeValue,'nearest');
end
axes(handles.axImageIn);
cla reset
imshow(image);
set (handles.txtImg,'string',[imName ext '  ' ...
  num2str(size(image,1)) 'x' num2str(size(image,2)) ' px']);

function PlotDetail(handles)
if ~handles.chkPlotDetail.Value
  return
end
hFigPlotLRC = findobj( 'Type', 'Figure', 'Tag', 'Fig$PlotLRC');
if isempty(hFigPlotLRC)
  return;
end
Lout=handles.Lout;
figure(hFigPlotLRC);
ax=gca;
YTL=ax.YTickLabel;
LeftSpace=size(YTL{end,1},2)*1.65+2.6;
image=getimage(ax);
if isequal(ax.Position,[0 0 1 1])
  ax.Units='characters';
  PosC=ax.Position;
  PosC=[PosC(1)+LeftSpace,PosC(2)+2.5,PosC(3)-LeftSpace-0.3,PosC(4)-2.5];
  ax.Position=PosC;
end
ax.Units='normalized';
if handles.bgLRC.UserData==3 %Type==3
  %Circle
  r=Lout(2);
  rCrop=r*1.05;
  xLeft=max(floor(Lout(3)-rCrop)-0.5,0.5);
  xRight=min(ceil(Lout(3)+rCrop)+0.5,size(image,2)+.5);
  yTop=max(floor(Lout(4)-rCrop)-0.5,0.5);
  yBottom=min(ceil(Lout(4)+rCrop)+0.5,size(image,1)+.5);
else
  %LR
  xmin=min(Lout(2:5,1));
  xmax=max(Lout(2:5,1));
  ymin=min(Lout(2:5,2));
  ymax=max(Lout(2:5,2));
  Diff=max([(xmax-xmin)*0.05,(ymax-ymin)*0.05,4]);
  xLeft=max(floor(xmin-Diff),0.5);
  xRight=min(ceil(xmax+Diff),size(image,2)+.5);
  yTop=max(floor(ymin-Diff),0.5);
  yBottom=min(ceil(ymax+Diff),size(image,1)+.5);
end
xlim([xLeft,xRight])
ylim([yTop,yBottom])
grid on

% --- Executes on button press in chkPlotDetail.
function chkPlotDetail_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  %Show detail
  PlotDetail(handles)
else
  %Show full size image
  hFigPlotLRC = findobj( 'Type', 'Figure', 'Tag', 'Fig$PlotLRC' );
  if isempty(hFigPlotLRC)
    return;
  end
  figure(hFigPlotLRC);
  ax=gca;
  ax.Position=[0 0 1 1];
  image=getimage(ax);
  xlim([0.5,size(image,2)+0.5])
  ylim([0.5,size(image,1)+0.5])
end
