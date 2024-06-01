function LCout=LargestCircle(image,varargin)
%Function to find the largest inscribed circle in an arbitrary shape with multiple holes.
%INPUT:
% image:        Image, RGB, grey or BW. By preference BW.
% Graphic:      Optional, default: 1 (Plot graphic), 0: no graphic
%OUTPUT LCout:
% 1st value: Area of the largest circle in px
% 2nd value: radius in px
% 3rd and 4th value: x,y of the circle center. x: from left, y: from top of image
% If area=0, black image, no circle found
%
%EXAMPLES:
% LCout=LargestCircle(myImage)% Run and plot graphic
% LCout=LargestCircle(myImage,0)% Run and do not plot graphic
%
%REMARK:
% Any hole (black pixel), even only one pixel wide,
%  will not be inside the largest circle
%
%Peter Seibold August 2020

if nargin>1 && varargin{1}==0
  boolGraphic=false;
else
  boolGraphic=true;
end
ImBWc=image;
if ~islogical(image)
  ImBWc=im2bw(ImBWc);
end
[rows, columns] = find(ImBWc);
numWhitePx=numel(rows);
if isempty(rows)
  %totaly black image
  disp ('Totaly black image! No rectangle found.');
  %LCout= Area, radius, center-x, center-y
  LCout=[0,0,1,1];
  return;
end
%determine smallest black border arround image
leftCrop = min(columns);
topCrop = min(rows);
rightCrop = max(columns);
bottomCrop = max(rows);
%crop image:
ImBWc=ImBWc(topCrop:bottomCrop,leftCrop:rightCrop);
ImBWc=[false(1,size(ImBWc,2)+2);...%add top border
  false(size(ImBWc,1),1),ImBWc,false(size(ImBWc,1),1);...%add left+right border  + image
  false(1,size(ImBWc,2)+2)];%add bottom border
boundary = bwperim(ImBWc);
[rowb,colb] = find(boundary);
%Minimize search range:
ImBWc2=ImBWc;
sizeImBWc=size(ImBWc);
rsf=2^round(log2(min(sizeImBWc))-8);%resize factor
IsEroded=false;
if rsf>1
  %Downsize image in order to speed up erosion.
  %make image size multiple of rsf:
  BorderN=ceil(sizeImBWc/rsf)*rsf-sizeImBWc;
  %add left and bottom black border
  ImBWc2=[ImBWc2,false(sizeImBWc(1),BorderN(2));...
    false(BorderN(1),sizeImBWc(2)+BorderN(2))];
  %reduce image size
  for rsf=rsf:-2:2
    ImBWe=imresize(ImBWc2,1/rsf);%TEST
    if sum(ImBWe(:))>numWhitePx/(rsf^2/4)
      break;
    end
  end
  if rsf==2 && sum(ImBWe(:))<numWhitePx/(rsf^2/4)
    %No resize
    ImBWe=ImBWc2;
    rsf=1;
  end
  ImBWe=[false(1,size(ImBWe,2)+2);...%add top border
    false(size(ImBWe,1),1),ImBWe,false(size(ImBWe,1),1);...%add left+right border  + image
    false(1,size(ImBWe,2)+2)];%add bottom border
  SE=strel('square',9);%Eroding shape
  ImBWeOLD=ImBWe;
  numWhitePxE=sum(ImBWe(:));
  numWhitePxr=numWhitePxE;
  while numWhitePxE>numWhitePxr*0.08
    ImBWe=imerode(ImBWe,SE);
    numWhitePxE=sum(ImBWe(:));
    if numWhitePxE<numWhitePxr*0.04
      %only a few white px
      ImBWe=ImBWeOLD;
      break;%exit while
    else
      %still many white px
      ImBWeOLD=ImBWe;
      IsEroded=true;
    end
  end
  %remove black border
  ImBWe=ImBWe(2:end-1,2:end-1);
  ImBWe=imresize(ImBWe,rsf);%Back to original size
  %Remove extra border left and bottom
  ImBWe=ImBWe(1:sizeImBWc(1),1:sizeImBWc(2));
else
  %No resize
  ImBWe=ImBWc;
end
%Refine erosion:
SE=strel('square',5);
numWhitePxE=sum(ImBWe(:));
ImBWeOLD=ImBWe;
for i=1:2
  %erode first with 5x5 element, then with 3x3 element
  while numWhitePxE>max(numWhitePx*0.01 ,numWhitePx/numel(rowb)*300)
    ImBWe=imerode(ImBWe,SE);
    numWhitePxE=sum(ImBWe(:));
    if numWhitePxE<numWhitePx*0.005
      %Minimum white px passed, could be zero, take previous erosion
      ImBWe=ImBWeOLD;
      break;%exit while
    else
      ImBWeOLD=ImBWe;
      if i==1
        IsEroded=true;
      end
    end
  end
  if IsEroded
    %erosion with 5x5 successfull, no second refined erosion
    break;
  else
    SE=strel('square',3);
  end
end
if ~IsEroded
  %no erosion possible, too small areas
  %exclude boundary px for the search range, since with them r is always zero
  ImBWe=ImBWe&~boundary;
end
%Main process, search largest integer position circle:
[us,vs] = find(ImBWe);%y and x position of possible circle centers
Circles=zeros(1000,3);%radius^2,row=y,col=x, for circles with same r
Circle=[0,0,0];
Ci=0;
for ui=1:numel(us)
  u=us(ui);
  v=vs(ui);
  dists=(rowb-u).^2+(colb-v).^2;
  distMin=min(dists);
  if distMin>Circle(1)
    Circle=[distMin,u,v];
    Circles(1,:)=[distMin,u,v];
    Ci=1;
  elseif distMin==Circle(1) && distMin>1
    boolLdist=true;%long distance (not same circle)
    for i=1:Ci
      if (u-Circles(i,2))^2+(v-Circles(i,3))^2<distMin
        %new center too close to old centers
        boolLdist=false;
        break;
      end
    end
    if boolLdist
      %Store circles with same r
      Ci=Ci+1;
      if Ci>1000;Ci=1000;end;%So far never happened
      Circles(Ci,:)=[distMin,u,v];
    end
  end
end
Circles=Circles(1:Ci,:);
%Exeptions for small areas:
if Circle(1)<1
  %find tiny circle
  Circle=findTinyCircle(ImBWc);
  LCout=[Circle(1)^2*pi,Circle(1),Circle(3)+leftCrop-2,Circle(2)+topCrop-2];
  if boolGraphic
    plotResult(image,LCout)
  end
  return%done
elseif   Circle(1)==1
  Circle=findSmallCircle(ImBWc);
  LCout=[Circle(1)*pi,sqrt(Circle(1)),Circle(3)+leftCrop-2,Circle(2)+topCrop-2];
  if boolGraphic
    plotResult(image,LCout)
  end
  return%done
end
%No exeption (big arteas)
%check if center is border px of search range:
for Cii=1:Ci
  Circle=Circles(Cii,:);
  s=sum(sum(ImBWe(Circle(2)-1:Circle(2)+1,Circle(3)-1:Circle(3)+1)));
  if s<9
    %Is border px, enlarge search range
    Circles(Cii,:)=SearchOutsideRange(ImBWc,ImBWe,Circle);
  end
end
maxr2=max(Circles(:,1));
Circles=Circles(Circles(:,1)==maxr2,:);%keep all equal largest r^2
Ci=size(Circles,1);
for Cii=1:Ci
  Circles(Cii,:)=RefineToPixelBorder(ImBWc,Circles(Cii,:));
end
[~,indx]=max(Circles(:,1));
Circle=Circles(indx(1),:);
%translation to image coordinates:
Circle=[Circle(:,1),Circle(:,2)+topCrop-2,Circle(:,3)+leftCrop-2];
% TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
%LCout= Area, radius, center-x, center-y
LCout=[pi*Circle(1),sqrt(Circle(1)),Circle(3),Circle(2)];
% TestPlotCircle(image,LCout(3),LCout(4),r);%For test purpose
if boolGraphic
  plotResult(image,LCout)
end

function Circle=SearchOutsideRange(ImBWc,ImBWe,Circle)
%Center is at border of search range, enlarge search range
%crop image by 1.5*r around last circle center
%add some u,v to search range around center and track
rCrop=round(sqrt(Circle(1))*1.5);
leftCrop2 = max(1,Circle(3)-rCrop);
topCrop2 = max(1,Circle(2)-rCrop);
rightCrop2 = min(size(ImBWc,2),Circle(3)+rCrop);
bottomCrop2 = min(size(ImBWc,1),Circle(2)+rCrop);
ImBWc2=ImBWc(topCrop2:bottomCrop2,leftCrop2:rightCrop2);
%Add black border outside
ImBWc2=[false(1,size(ImBWc2,2)+2);...%add top border
  false(size(ImBWc2,1),1),ImBWc2,false(size(ImBWc2,1),1);...%add left+right border  + image
  false(1,size(ImBWc2,2)+2)];%add bottom border
boundary = bwperim(ImBWc2);
[rowb,colb] = find(boundary);
%crop search range
ImBWe2=ImBWe(topCrop2:bottomCrop2,leftCrop2:rightCrop2);
ImBWe2=[false(1,size(ImBWe2,2)+2);...%add top border
  false(size(ImBWe2,1),1),ImBWe2,false(size(ImBWe2,1),1);...%add left+right border  + image
  false(1,size(ImBWe2,2)+2)];%add bottom border
%adjust circle parameters for new coordinate system
Circle=[Circle(1),Circle(2)-topCrop2+2,Circle(3)-leftCrop2+2];
%   TestPlotCircle(ImBWc2,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
for i=1:floor(0.66*rCrop)
  ImBWe3=ImBWe2;
  ImBWe3(Circle(2)-3:Circle(2)+3,Circle(3)-3:Circle(3)+3)=true;
  %Make sure test px are inside white area:
  ImBWe3=ImBWe3&ImBWc2;
  ImBWe4=ImBWe3-ImBWe2;%remove already tested u,v
  [us,vs] = find(ImBWe4);
  distMinOld=Circle(1);
  for ui=1:numel(us)
    u=us(ui);
    v=vs(ui);
    dists=(rowb-u).^2+(colb-v).^2;
    distMin=min(dists);
    if distMin>Circle(1)
      Circle=[distMin,u,v];
    end
  end
  if distMinOld==Circle(1)
    % No change in radius
    break;
  end
  ImBWe2=ImBWe3;
end
%   TestPlotCircle(ImBWc2,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
Circle=[Circle(1),Circle(2)+topCrop2-2,Circle(3)+leftCrop2-2];
%   TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose

function Circle=RefineToPixelBorder(image,Circle)
%Circle=radius^2,row=y,col=x
% TestPlotCircle(image,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
r=sqrt(Circle(1));
rCrop=r+5;%Allow a search range of 5 px
%crop image around circle
leftCrop = floor(max(Circle(3)-rCrop,1));
topCrop =floor(max(Circle(2)-rCrop,1));
rightCrop = ceil(min(Circle(3)+rCrop,size(image,2)));
bottomCrop = ceil(min(Circle(2)+rCrop,size(image,1)));
%crop image:
ImBWc=image(topCrop:bottomCrop,leftCrop:rightCrop);
Circle=[Circle(1),Circle(2)-topCrop+1,Circle(3)-leftCrop+1];%r^2,row=y,col=x
% TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
%make corner regions of ImBWc black
[rows, columns] = find(ImBWc);%extract white px
[theta,rho] = cart2pol(columns-Circle(3),rows-Circle(2));
thetaRho=[theta,rho];
thetaRho=thetaRho(thetaRho(:,2)>rCrop+2,:);
[x,y] = pol2cart(thetaRho(:,1),thetaRho(:,2));
x=round(x+Circle(3));
y=round(y+Circle(2));
for i=1:numel(x)
  ImBWc(y(i),x(i))=false;
end
%  TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
%Add black border outside
ImBWc=[false(1,size(ImBWc,2)+2);...%add top border
  false(size(ImBWc,1),1),ImBWc,false(size(ImBWc,1),1);...%add left+right border  + image
  false(1,size(ImBWc,2)+2)];%add bottom border
Circle=[Circle(1),Circle(2)+1,Circle(3)+1];
% TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
[rowb,colb]=AddPixelBorderPositions(ImBWc,r);
% TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
% figure;;%For test purpose, plot refined px borders
% imshow(ImBWc,'border', 'tight','InitialMagnification','fit');
% hold on;plot(colb,rowb,'r+');
% hold off;
gbMax=min(round(sqrt(Circle(1))*.5/0.0625)*0.0625,3);
Circle(1)=0;
CircleOld=Circle-1;
for i=1:6
  if i>4
    gb=gs;%meshgrid border
    gs=gs/2;%gridstep
  else
    %start with 0.0625 steps and large search range
    %search and track
    if CircleOld==Circle
      %No change, proceed with smaller range,faster
      gb=gs;%meshgrid border
      gs=gs/2;%gridstep
    else
      gb=gbMax;%0.5
      gs=0.0625;
      
      CircleOld=Circle;
    end
  end
  [vs,us]=meshgrid(Circle(3)-gb:gs:Circle(3)+gb,Circle(2)-gb:gs:Circle(2)+gb);
  us=us(:);%y
  vs=vs(:);%x
  for ui=1:numel(us)
    u=us(ui);
    v=vs(ui);
    dists=(rowb-u).^2+(colb-v).^2;
    distMin=min(dists);
    if distMin>Circle(1)
      Circle=[distMin,u,v];
    end
  end
  %  disp(Circle);TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
end
%  TestPlotCircle(ImBWc,Circle(3),Circle(2),sqrt(Circle(1)));%For test purpose
Circle=[Circle(1),Circle(2)+topCrop-2,Circle(3)+leftCrop-2];

function [rowb,colb]=AddPixelBorderPositions(ImBWc,r)
boundary = bwperim(ImBWc);
[rowb,colb] = find(boundary);
%find adjacent black px and add pixelborder positions:
j=0;
k=max(round(7-0.009*r)*2+1,3);%number of extra positions, odd number!
rowColc=zeros(numel(rowb)*2*k,2);
extraPos=(-0.5:1/(k-1):0.5)';
for i=1:numel(rowb)
  if ~ImBWc(rowb(i),colb(i)-1)
    %left black px
    j1=j+1;
    j=j+k;
    rowColc(j1:j,1)=rowb(i)+extraPos;
    rowColc(j1:j,2)=colb(i)-0.5;
  end
  if ~ImBWc(rowb(i)-1,colb(i))
    %top black px
    j1=j+1;
    j=j+k;
    rowColc(j1:j,1)=rowb(i)-0.5;
    rowColc(j1:j,2)=colb(i)+extraPos;
  end
  if ~ImBWc(rowb(i),colb(i)+1)
    %right black px
    j1=j+1;
    j=j+k;
    rowColc(j1:j,1)=rowb(i)+extraPos;
    rowColc(j1:j,2)=colb(i)+0.5;
  end
  if ~ImBWc(rowb(i)+1,colb(i))
    %bottom black px
    j1=j+1;
    j=j+k;
    rowColc(j1:j,1)=rowb(i)+0.5;
    rowColc(j1:j,2)=colb(i)+extraPos;
  end
end
rowColc=rowColc(1:j,:);
rowColc=unique(rowColc,'rows');%remove duplicates
rowb=rowColc(:,1);
colb=rowColc(:,2);

function Circle=findTinyCircle(ImBWc)
%Find circle by pattern
[L,Lnum] = bwlabel(ImBWc);
S2=sqrt(2);
%Pattern types:
%1 2x2 area
P1=[[0,1];[1,1];[1,0]];
Circ1=[1,0.5,0.5];%r,row,col
%2 T
P2=zeros(3,2,4);
Circ3=zeros(4,3);
P2(:,:,1)=[[0,-1];[0,1];[1,0]];%top, regular T
Circ3(1,:)=[0.625,0.125,0];
P2(:,:,2)=[[0,-1];[-1,0];[1,0]];%right
Circ3(2,:)=[0.625,0,-0.125];
P2(:,:,3)=[[0,-1];[0,1];[-1,0]];%bottom
Circ3(3,:)=[0.625,-0.125,0];
P2(:,:,4)=[[-1,0];[1,0];[0,1]];%left
Circ3(4,:)=[0.625,0,0.125];
%3 corner
P3=zeros(2,2,4);
Circ4=Circ3;
r4=S2/(1+S2);
P3(:,:,1)=[[0,1];[1,0]];%top left
Circ4(1,:)=[r4,r4-0.5,r4-0.5];
P3(:,:,2)=[[1,0];[0,-1]];%top right
Circ4(2,:)=[r4,r4-0.5,0.5-r4];
P3(:,:,3)=[[-1,0];[0,-1]];%bottom right
Circ4(3,:)=[r4,0.5-r4,0.5-r4];
P3(:,:,4)=[[-1,0];[0,1]];%bottom left
Circ4(4,:)=[r4,0.5-r4,r4-0.5];
Circle=[0,1,1];
for i=1:Lnum
  [rowb, colb] = find(L==i);%extract white px
  topCrop=min(rowb);
  leftCrop=min(colb);
  sizeIm=[max(rowb)-topCrop+1,max(colb)-leftCrop+1];
  rowb2=rowb-min(rowb)+2;
  colb2=colb-min(colb)+2;
  ImBW2=false(sizeIm(1)+2,sizeIm(2)+2);
  for j=1:numel(rowb)
    ImBW2(rowb2(j),colb2(j))=true;
  end
  numWhitePx=numel(rowb);
  for j=1:numel(rowb)
    %Check all white px for all patterns
    %Check pattern 1, 2x2
    if numWhitePx>3
      rowb3=P1(:,1)+rowb2(j);
      colb3=P1(:,2)+colb2(j);
      if ImBW2(rowb3(1),colb3(1))&&ImBW2(rowb3(2),colb3(2))&&ImBW2(rowb3(3),colb3(3))
        Circle=[Circ1(1),Circ1(2)+rowb2(j)+topCrop-2,Circ1(3)+colb2(j)+leftCrop-2];
        break;%largest circle found
      end
    end
    %Check pattern 2 , T
    if Circle(1)<0.625 && numWhitePx>3
      for k=1:4
        rowb3=P2(:,1,k)+rowb2(j);
        colb3=P2(:,2,k)+colb2(j);
        if ImBW2(rowb3(1),colb3(1))&&ImBW2(rowb3(2),colb3(2))&&...
            ImBW2(rowb3(3),colb3(3))
          Circle=[Circ3(k,1),Circ3(k,2)+rowb2(j)+topCrop-2,Circ3(k,3)+colb2(j)+leftCrop-2];
        end
      end
    end
    %Check pattern 3 , corners
    if Circle(1)<r4 && numWhitePx>2
      for k=1:4
        rowb3=P3(:,1,k)+rowb2(j);
        colb3=P3(:,2,k)+colb2(j);
        if ImBW2(rowb3(1),colb3(1))&&ImBW2(rowb3(2),colb3(2))
          Circle=[Circ4(k,1),Circ4(k,2)+rowb2(j)+topCrop-2,Circ4(k,3)+colb2(j)+leftCrop-2];
        end
      end
    end
    %Check single px
    if Circle(1)<0.5
      Circle=[0.5,rowb2(j)+topCrop-2,colb2(j)+leftCrop-2];%1px
    end
  end
  if Circle(1)==1
    break;%largest circle found
  end
end

function Circle=findSmallCircle(ImBWc)
%enlarge image
ImBWc2=imresize(ImBWc,2);
SE=strel('square',5);
ImBWe=imerode(ImBWc2,SE);
boundary = bwperim(ImBWc2);
[rowb,colb] = find(boundary);
[us,vs] = find(ImBWe);
Circle=[0,0,0];
for ui=1:numel(us)
  u=us(ui);
  v=vs(ui);
  dists=(rowb-u).^2+(colb-v).^2;
  distMin=min(dists);
  if distMin>Circle(1)
    Circle=[distMin,u,v];
  end
end
Circle(2:3)=Circle(2:3)+1;
Circle=Circle/2;
Circle=RefineToPixelBorder(ImBWc,Circle);

function plotResult(image,LCout)
%Plot result
hFigPlotLRC = findobj( 'Type', 'Figure', 'Tag', 'Fig$PlotLRC' );
if isempty(hFigPlotLRC)
  screensize=get(0, 'MonitorPositions');
  hFigPlotLRC=figure('Tag','Fig$PlotLRC','Name','Largest shape',...
    'OuterPosition',[825,40,screensize(1,3)-825,screensize(1,4)-85]);
end
figure(hFigPlotLRC);
cla reset;
%remove next 3 lines, if you want to display the original image
if ~islogical(image)
  image=im2bw(image);
end
imshow(image,'InitialMagnification','fit','border', 'tight');
axis on;
hold on
plot(LCout(3),LCout(4),'r+')
th = 0:pi/1000:2*pi;
r=LCout(2);
xunit = r * cos(th) + LCout(3);
yunit = r * sin(th) +LCout(4);
plot(xunit, yunit,'r-');
text(LCout(3),LCout(4)-min(9,LCout(2)/8),['Area=' num2str(round(LCout(1),1)) ' px'],...
  'HorizontalAlignment','center','VerticalAlignment','bottom','Color','r');
txt={['x=' num2str(LCout(3),'%.2f') '  y=' num2str(LCout(4),'%.2f')],['r=' num2str(round(r,1))]};
text(LCout(3),LCout(4)+min(3,LCout(2)/9),txt,...
  'HorizontalAlignment','center','VerticalAlignment','top','Color','r');
hold off

function TestPlotCircle(image,x,y,r)
%Only for test purpose, you may delete this function
hFigTestPlotLRC = findobj( 'Type', 'Figure', 'Tag', 'Fig$TestPlotLRC' );
if isempty(hFigTestPlotLRC)
  hFigTestPlotLRC=figure('Tag','Fig$TestPlotLRC','Name','Test');
end
figure(hFigTestPlotLRC);
cla reset;
imshow(image,'border', 'tight','InitialMagnification','fit');
axis on;
hold on
plot(x,y,'r+')
th = 0:pi/500:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) +y;
plot(xunit, yunit,'r-');
ax=gca;
ax.Position=[0.03,0.03,0.965,0.965];
grid on

function TestPlotCircle2(Circle,Farbe)
%Only for test purpose, you may delete this function
x=Circle(3);
y=Circle(2);
r=Circle(1);
axis on;
hold on
plot(x,y,[Farbe '+'])
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) +y;
plot(xunit, yunit,[Farbe '-']);
grid on
hold off