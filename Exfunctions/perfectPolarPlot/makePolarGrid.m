function ph = makePolarGrid(varargin)
%  ph = makePolarGrid(varargin)
%
% This is used to setup and draw a polar plot grid so that polar data can
% be displayed. It can be set to different orientations, such as having
% angles increase clockwise or counter-clockwise. It can have the zero
% angle at the sides, top, or bottom. It can show the full polar circle 
% or only limited area (i.e. a circular segment) for the figure. It can
% rotate the whole grid by an arbitrary amount.
%
% It also has built-in schemes for special cases such as for plotting wind
% data or sea wave data in polar formats.
%
% The input parameters are intended to mimic native matlab plot properties.
% The axis system used consists of angles (or the "spokes") of the polar 
% grid. These have properties such as ALim for limits, ATicks, MinorATicks,
% etc. (see top of makePolarGrid.m for full list and default values).
%
% The second axis are the radial circles. These have properties such as
% RLim, RTicks, MinorRTicks, etc.
%
% ph = makePolarGrid(...
%   'ADir',       'clockwise',... % 'clockwise'/'ccw' or 'counterclockwise'/'ccw'
%   'ALim',       [0,360],...     % span of circle grid
%   'AZeroPos',   'top',...       % initial 0deg position 'top',left','bottom','right'
%   'ATicks',      15,...         % A single value means the incriment, otherwise its a list
%   'AMinorTicks', 5,...          % (optional) extra spokes, but won't have labels
%   'AFontSize',   10,...         % (optional) change font size
%   'ALabelWrap', '0to360',...    % '0to360' or '-180to180', for spoke labels
%   'AUnits',      '',...         % (optional) ignored for some, used only for spokeLabelSchemes
%   'RLabelScheme', 'normal',...  % various schemes available
%   'RTicks',       0:.2:1,...    % Radial ticks (inner circles)
%   'RLim ',        [],...        % Radial Grid Limits (uses RTick range if empty)
%   'RMinorTicks',  [],...        % (optional) extra circles, but won't have labels
%   'RLabelAngle',  15,...        % Angle where the radial tick labels will go
%   'RLabelFormat', '%f',...      % Format for radial labels
%   'RFontSize',    10,...        % (optional) change font size
%   'RUnits',       '',...        % (optional) will be applied to last radial label
%   'rotateGrid',   0,...         % Rotate the grid (degrees, positive in direction of ADir)
%   'gridColor',    [0.5, 0.5, 0.5],...  % grid color [r,g,b]
%   'minorGridColor', [0.5, 0.5, 0.5]);  % minor grid color [r,g,b]
% 
% Eric Thornhill, January 2019

%% Extract Function Arguments
% Default values, unless over-ridden in varagin
inputArgs      = who;   % This is required by assignFunctionArgs.m
skipMakeGrid   = false;  % false will disable any drawing of polar grid
showMinorGrid  = true;  % easy way to turn off the minor grid

% Default Angle (spoke grid) Properties
ALabelScheme = 'normal';     % various schemes available
ADir         = 'clockwise';  % 'clockwise'/'ccw' or 'counterclockwise'/'ccw'
ALim         = [0,360];      % span of circle grid
AZeroPos     = 'top';        % initial 0deg position 'top',left','bottom','right'
ATicks       = 15;           % A single value means the incriment, otherwise its a list
AMinorTicks  = 5;            % (optional) extra spokes, but won't have labels
AFontSize    = 10;           % (optional) change font size
ALabelWrap   = '0to360';     % '0to360' or '-180to180', for spoke labels
AUnits       = '';           % (optional) ignored for some, used only for spokeLabelSchemes

% Default Radial (circle grid) Properties
RLabelScheme = 'normal';  % various schemes available
RTicks       = 0:.2:1;    % Radial ticks (inner circles)
RLim         = [];        % Radial Grid Limits (uses RTick range if empty)
RMinorTicks  = [];        % (optional) extra circles, but won't have labels
RLabelAngle  = 15;        % Angle where the radial tick labels will go
RLabelFormat = '%f';      % Format for radial labels
RFontSize    = 10;        % (optional) change font size
RUnits       = '';        % (optional) will be applied to last radial label

rotateGrid = 0;  % Rotate grid arbitrary amount (degrees, positive in direction of ADir)

majorGridLineStyle  = '-';             % major grid line style
majorGridLineWidth  = 0.25;            % major grid LineWidth
majorGridColor      = [0.5, 0.5, 0.5]; % major grid color

minorGridLineStyle  = ':';             % minor grid line style
minorGridLineWdith  = 0.1;             % minor grid LineWidth
minorGridColor      = [0.5, 0.5, 0.5]; % minor grid color

outerBoxLineStyle   = '-';             % outer bounding box line style
outerBoxLineWidth   = 1;               % outer bounding box LineWidth
outerBoxColor       = 'k';             % outer bounding box color

% Cannot use input names : 'inputArgs', 'kArg', 'xArg', 'tempArg', 'defArgs'
% See comments in assignFunctionArgs.m for instructions how to use.
assignFunctionArgs;

%% Preliminary Bits -------------------------------------------------------

ph = funArgs;  % holds handles for various plot object generated for grid

% Special Cases override default or input values for some properties.
switch ALabelScheme
  
  case 'wave1'
    
    ADir      = 'clockwise';
    AZeroPos  = 'bottom';
    
  case 'wave2'
    
    ADir      = 'counterclockwise';
    AZeroPos  = 'bottom';    
    
  case {'wind1', 'wind2'}
    
    ADir       = 'clockwise';
    ALabelWrap = '-180to180';
    AZeroPos   = 'top';
    
end

ph.ADir       = ADir;
ph.AZeroPos   = AZeroPos;
ph.rotateGrid = rotateGrid;

%% Prepare Spoke and Minor Spoke Ticks ------------------------------------

if isempty(ALim) && length(ATicks)>1
  ALim = [ATicks(1), ATicks(end)];
end  

% Plot can either be a full circle or circular segment
% this uses the ALim values to see which.
if isempty(ALim) || (mod(diff(ALim),360)==0)
  
  fullCircle = true;
  ALim   = [0,360];
  
else
  
  fullCircle = false;
  ALim = wrap360(ALim);

  if ALim(1) > ALim(2)
    ALim(2) = ALim(2) + 360;
  end
    
end

% If a single value is given for ATicks, then its the increment.
if length(ATicks) == 1
  ATicks = ALim(1) : ATicks : ALim(2);
end
ATicks = ATicks(:)';  % Make row vector

% Remove any duplicates (like 0,360)
ATicks = unique(wrap360(ATicks));

if ~isempty(AMinorTicks) 
  
  if length(AMinorTicks) == 1
     AMinorTicks = ALim(1) : AMinorTicks : ALim(2);
  end
  
  AMinorTicks = AMinorTicks(:)';  % Make row vector
  
  % Remove any duplicates (like 0,360)
  AMinorTicks = unique(wrap360(AMinorTicks));
  
  % Remove any coincidences with ATicks
  id = ~ismember(AMinorTicks, ATicks);
  AMinorTicks = AMinorTicks(id);
  clear id  

end

if ~fullCircle 
  % Remove any out-of-range ATick, AMinorTicks
  
    ALim = wrap360(ALim);
    
    if ALim(1) > ALim(2)
      % e.g. range from 330 to 30 (the short way through 0)
      id = ((ATicks < ALim(1)) & (ATicks > ALim(2)));
      idm = ((AMinorTicks <= ALim(1)) & (AMinorTicks >= ALim(2)));
    else
      % e.g. range from 30 to 330 (goes the long way through 180)
      id = ((ATicks < ALim(1)) | (ATicks > ALim(2)));
      idm = ((AMinorTicks <= ALim(1)) | (AMinorTicks >= ALim(2)));
    end
  
  ATicks(id)       = [];
  AMinorTicks(idm) = [];
  
  clear id idm
  
end

% convertToStdPolarAngle returns the angles in standard polar 
% system that correspond to the plot angles in the format specified
% for this polar grid. Input and output in degrees. output angles are 
% wrapped 0to360
axATicks      = convertToStdPolarAngle(ATicks, ph);
axAMinorTicks = convertToStdPolarAngle(AMinorTicks, ph);
axRLabelAngle = convertToStdPolarAngle(RLabelAngle, ph);                      

ph.fullCircle    = fullCircle;
ph.ALim          = ALim;
ph.ATicks        = ATicks;
ph.axATicks      = axATicks;
ph.AMinorTicks   = AMinorTicks;
ph.axAMinorTicks = axAMinorTicks;
ph.axRLabelAngle = axRLabelAngle;

%% Perpare Radial Ticks and Minor Ticks ------------------------------------

if ~isempty(RTicks)
  RTicks = sort(unique(RTicks(:)'));
  RTicks(RTicks<0) = [];
end

if isempty(RLim) && (length(RTicks)<2)
  error('Error: must specify RLim or RTicks');
end

if isempty(RLim)
  RLim = [RTicks(1), RTicks(end)];
end

if (length(RLim)~=2) || (diff(RLim)<=0)
  error('bad RLim');
end

if isempty(RTicks)
  
  % If RLim is given, but no RTicks, assume 5 equally spaced RTicks
  RTicks = linspace(Rlim(1),Rlim(2),5);
  
elseif length(RTicks) == 1

  % Case where RLim is given and a single value is given for RTicks,
  % it is assumed that RTicks is the increment to use between the RLim range.
  RTicks = RLim(1) : RTicks : RLim(2);
  
end

% Remove out-of-range RTicks
RTicks(RTicks<RLim(1)) = []; 
RTicks(RTicks>RLim(2)) = []; 

if ~isempty(RMinorTicks) 
  RMinorTicks(RMinorTicks<0) = [];
end

if ~isempty(RMinorTicks) 

  % Case where RLim is given and a single value is given for RTicks,
  % it is assumed that RTicks is the increment to use between the RLim range.
  if length(RMinorTicks) == 1
     RMinorTicks = RLim(1) : RMinorTicks : RLim(2);
  end
  
  RMinorTicks = sort(unique(RMinorTicks(:)'));
  
   % Remove center, grid at the outer boundaries, and 
   % coincidences with RTicks
  id = (RMinorTicks == 0) | (RMinorTicks <= RLim(1)) | ...
    (RMinorTicks >= RLim(2)) | ismember(RMinorTicks, RTicks);
  RMinorTicks(id) = [];
  clear id
    
end  
  
ph.RTicks        = RTicks;
ph.RLim          = RLim;
ph.RMinorTicks   = RMinorTicks;

%% Set Various Figure Properties -------------------------------------------
if skipMakeGrid
  % So the reason for this is if you're just after the "ph" output so it
  % can be used in polgrid2cart.m for some other purpose and don't need a
  % polar grid generated.
  return
end

if ~ishold
  clf
end

hold on
cax = gca;
set(gcf,'color','w');
%set(gca,'Color','none');
set(gcf,'Position',[200 50 900 700]); % this size is abitrary
view(cax, 2);  % set view to 2-D

set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
set(get(cax, 'XLabel'), 'Visible', 'on');
set(get(cax, 'YLabel'), 'Visible', 'on');

% Set size of plot area 
% This may need to be adjusted if doing something 
% fancy that may require extra space, but in most 
% cases I found the following works fine.
axis(cax, RLim(2) * [-1, 1, -1.15, 1.15]);

ph.figHnd = gcf;
ph.axHnd  = cax;

% Define a circle. These are used to help draw
% the various grid lines etc.
if ALim(1) > ALim(2)
  th = ALim(1) : 1 : (ALim(2)+360);
else
  th = ALim(1) : 1 : ALim(2);
end
th = convertToStdPolarAngle(th, ph) * pi/180;  
xunit = cos(th);
yunit = sin(th);
clear th

%% Draw Background Filled Circle -------------------------------------------

% This is not needed if the figure background is set to white.

% plot background circle 
% if 0 && ~ischar(get(cax, 'Color'))
%   hnd.backgroundCircle = patch(...
%     'XData', xunit * RLim(2), ...
%     'YData', yunit * RLim(2), ...
%     'EdgeColor', gc, ...
%     'FaceColor', get(cax, 'Color'), ...
%     'HandleVisibility', 'off', ...
%     'Parent', cax);
% end

%% Draw Minor Spoke Grid Lines --------------------------------------------

if showMinorGrid && ~isempty(AMinorTicks)
  
  px = [RLim(1)*cosd(axAMinorTicks)', RLim(2)*cosd(axAMinorTicks)']';
  py = [RLim(1)*sind(axAMinorTicks)', RLim(2)*sind(axAMinorTicks)']';
  
  hh = line(px,py,...
    'LineStyle', minorGridLineStyle,...
    'Color',     minorGridColor,...
    'LineWidth', minorGridLineWdith, ...
    'HandleVisibility', 'off',...
    'Parent', cax);
  
  ph.AMinorGrid = hh;
  
  clear px py hh
  
else
  
  ph.AMinorGrid = [];
  
end

%% Draw Major Spoke Grid Lines ---------------------------------------------
if ~isempty(ATicks)
  
  dax = axATicks;
  
  if ~fullCircle
    % Don't draw grid on outer boundaries for circle section case
    id = ismember(wrap360(ATicks), wrap360(ALim));
    dax(id) = [];
    clear id
  end
  
  px = [RLim(1)*cosd(dax)', RLim(2)*cosd(dax)']';
  py = [RLim(1)*sind(dax)', RLim(2)*sind(dax)']';
  
  hh = line(px, py, ...
    'LineStyle', majorGridLineStyle,...
    'Color',     majorGridColor,...
    'LineWidth', majorGridLineWidth, ...
    'HandleVisibility', 'off',...
    'Parent', cax);
  
  ph.AMajorGrid = hh;
  
  clear px py dax
  
else
  
  ph.AMajorGrid = [];
  
end

%% Draw Minor Circle Grid Lines -------------------------------------------
if showMinorGrid && ~isempty(RMinorTicks)
    
  [xm,ym] = meshgrid(xunit,RMinorTicks);
  px = xm .* ym;
  clear xm ym
  
  [xm,ym] = meshgrid(yunit,RMinorTicks);
  py = xm .* ym;
  clear xm ym

  hh = line(px', py', ...
      'LineStyle', minorGridLineStyle, ...
      'Color',     minorGridColor, ...
      'LineWidth', minorGridLineWdith, ...
      'HandleVisibility', 'off', ...
      'Parent', cax);
    
  ph.RMinorGrid = hh;
  
  clear px py hh
  
else
  
  ph.RMinorGrid = [];
  
end

%% Draw Major Circle Grid Lines -------------------------------------------

crad = RTicks;

% Don't draw grid circle at center or outer boundaries
id = (crad == 0) | ismember(crad, RLim);
crad(id) = [];
clear id

if ~isempty(crad)
  
  [xm,ym] = meshgrid(xunit,crad);
  px = xm .* ym;
  clear xm ym
  
  [xm,ym] = meshgrid(yunit,crad);
  py = xm .* ym;
  clear xm ym
  
  hh = line(px', py', ...
    'LineStyle', majorGridLineStyle, ...
    'Color',     majorGridColor, ...
    'LineWidth', majorGridLineWidth, ...
    'HandleVisibility', 'off', ...
    'Parent', cax);
  
  ph.RMajorGrid = hh;
  
  clear px py hh
  
else
  
  ph.RMajorGrid = [];
  
end

clear crad

%% Draw Outer Boundary-----------------------------------------------------

% Draw outer circle
ph.OuterBox = line(xunit * RLim(2), yunit * RLim(2), ...
  'LineStyle', outerBoxLineStyle, ...
  'Color',     outerBoxColor, ...
  'LineWidth', outerBoxLineWidth, ...
  'HandleVisibility', 'off', ...
  'Parent', cax);

% Draw inner circle
if RLim(1) > 0
  
  ph.OuterBox(end+1,1) = line(xunit * RLim(1), yunit * RLim(1), ...
    'LineStyle', outerBoxLineStyle, ...
    'Color',     outerBoxColor, ...
    'LineWidth', outerBoxLineWidth, ...
    'HandleVisibility', 'off', ...
    'Parent', cax);
  
end

% Draw sides if needed
if ~fullCircle
  
  ph.OuterBox(end+1,1) = line([RLim(1)*xunit(1), RLim(2)*xunit(1)], ...
    [RLim(1)*yunit(1), RLim(2)*yunit(1)], ...
    'LineStyle', outerBoxLineStyle,...
    'Color',     outerBoxColor,...
    'LineWidth', outerBoxLineWidth, ...
    'HandleVisibility', 'off',...
    'Parent', cax);
  
  ph.OuterBox(end+1,1) = line([RLim(1)*xunit(end), RLim(2)*xunit(end)], ...
    [RLim(1)*yunit(end), RLim(2)*yunit(end)], ...
    'LineStyle', outerBoxLineStyle,...
    'Color',     outerBoxColor,...
    'LineWidth', outerBoxLineWidth, ...
    'HandleVisibility', 'off',...
    'Parent', cax);
  
end

%% Label Spoke Ticks -------------------------------------------------------
for k = 1:length(ATicks)
  
  tickAngle = ATicks(k);
  axAngle   = axATicks(k);
  
  if axAngle == axRLabelAngle
    continue
  end
    
  switch ALabelScheme

    case 'normal'
      ha = annotateNormal(tickAngle, axAngle, RLim(2), ph);
      
    case 'wave1'
      ha = annotateWave1(tickAngle, axAngle, RLim(2), ph);
      
    case 'wave2'
      ha = annotateWave2(tickAngle, axAngle, RLim(2), ph);
      
    case 'wind1'
      ha = annotateWind1(tickAngle, axAngle, RLim(2), ph);
      
    case 'wind2'
      ha = annotateWind2(tickAngle, axAngle, RLim(2), ph);       
      
    case 'piA'
      ha = annotatePiA(tickAngle, axAngle, RLim(2), ph);           
      
    otherwise
      error(['unrecognized spokeLabelScheme: ',ALabelScheme]);
  end
  
  ph.ALabels(k) = ha;
    
  clear tickAngle axAngle ha
end
clear k

%% Label Radial Ticks ------------------------------------------------------

for r = 1:length(RTicks)
  
  thisRad = RTicks(r);
  
  switch RLabelScheme

    case 'none'
      hr = [];    
    
    case 'normal'
      hr = getRLabel_Normal(thisRad, ph);
      
    case 'outer'  
      
      hr = getRLabel_Outer(thisRad, ph);
            
    otherwise
      error(['unrecognized RLabelScheme: ',RLabelScheme]);
  end
      
  if ~isempty(hr)
    ph.RLabels(r) = hr;
  end
  clear radStr hr
  
end

fn = fieldnames(ph);
[~,id] = sort(lower(fn));
ph = orderfields(ph,fn(id));
clear fn id

end % function polar

%% function shift2radius -----------------------------------------------
function labHnd = shift2radius(labHnd, rclose, axAngle, angShiftFlag)
% shifts a text box so it the closest its extent box is rt from a circle of
% radius rt from the origin

if nargin<4
  angShiftFlag = false;
end

%chk = zeros(5,1);

rt = rclose;

for k = 1:5

b = labHnd.Extent;

p = [b(1), b(2);...
  b(1)+b(3)/2, b(2);...
  b(1)+b(3), b(2);...
  b(1)+b(3), b(2)+b(4)/2;...
  b(1)+b(3), b(2)+b(4);...
  b(1)+b(3)/2, b(2)+b(4);...
  b(1), b(2)+b(4);...
  b(1), b(2)+b(4)/2];

% Just checking these match
%pang = wrap360(atan2d(mean(p(:,2)),mean(p(:,1))));

[d,id] = min(sqrt(p(:,1).^2 + p(:,2).^2));

if k==1 && angShiftFlag
dtheta = wrap360(atan2d(p(id,2),p(id,1))) - wrap360(axAngle);
if abs(dtheta)>3 && abs(dtheta)<10
  axAngle = axAngle - dtheta/2;
end
end

rt = rclose*(rt/d);
labHnd.Position = [rt*cosd(axAngle), rt*sind(axAngle)];
  
%chk(k) = axTheta;

end

end % shift2radius

%% function annotateNormal -----------------------------------------------
function hr = getRLabel_Normal(thisRad, ph)

% dr is tiny shift to put the labels on
% on just the outside of each grid circle

hr = [];

if thisRad==0
  return;
end

RLim = ph.RLim;

dr = 1.005*RLim(2) - RLim(2);

if (thisRad == RLim(2)) && ~isempty(ph.RUnits)
  radStr = [sprintf(ph.RLabelFormat,thisRad),' ',ph.RUnits];
else
  radStr = sprintf(ph.RLabelFormat,thisRad);
end

% Positions for labels, not a slight shift
xr = (thisRad) * cosd(ph.axRLabelAngle);
yr = (thisRad) * sind(ph.axRLabelAngle);

hr = text(xr, yr, radStr, ...
  'VerticalAlignment',   'middle', ...
  'HorizontalAlignment', 'center', ...
  'HandleVisibility',    'off', ...
  'FontSize', ph.RFontSize, ...
  'Parent', ph.axHnd);


if thisRad == RLim(2)
  hr = shift2radius(hr, 1.01*RLim(2),  ph.axRLabelAngle, true);
else
  hr = shift2radius(hr, thisRad+dr, ph.axRLabelAngle, false);
end


end   % getRLabel_Normal

%% function getRLabel_Outer-----------------------------------------------
function hr = getRLabel_Outer(thisRad, ph)

% dr is tiny shift to put the labels on
% on just the outside of each grid circle

hr = [];

if thisRad==0 && ph.fullCircle
  return
end

RLim = ph.RLim;

dr = 1.04*RLim(2) - RLim(2);

radStr = sprintf(ph.RLabelFormat,thisRad);

% Positions for labels, not a slight shift
xr = (thisRad) * cosd(ph.axRLabelAngle);
yr = (thisRad) * sind(ph.axRLabelAngle);

xs = dr * cosd(90+ph.axRLabelAngle);
ys = dr * sind(90+ph.axRLabelAngle);

hr = text(xr-xs, yr-ys, radStr, ...
  'VerticalAlignment',   'middle', ...
  'HorizontalAlignment', 'center', ...
  'HandleVisibility',    'off', ...
  'Rotation', ph.axRLabelAngle, ...
  'FontSize', ph.RFontSize, ...
  'Parent', ph.axHnd);

if (thisRad == RLim(2))  && ~isempty(ph.RUnits)
  
  dr = 1.11*RLim(2) - RLim(2);
 
  xr = mean(RLim) * cosd(ph.axRLabelAngle);
  yr = mean(RLim) * sind(ph.axRLabelAngle);
  
  xs = dr * cosd(90+ph.axRLabelAngle);
  ys = dr * sind(90+ph.axRLabelAngle);
  
  hr = text(xr-xs, yr-ys, ph.RUnits, ...
    'VerticalAlignment',   'middle', ...
    'HorizontalAlignment', 'center', ...
    'HandleVisibility',    'off', ...
    'Rotation', ph.axRLabelAngle, ...
    'FontSize', ph.RFontSize, ...
    'Parent', ph.axHnd);
  
end
  


end   % getRLabel_Outer

%% function annotateNormal -----------------------------------------------
function spkHnd = annotateNormal(labAng, d, rmax, ph)

AUnits = ph.AUnits;

% Default distance from center for label
rt = 1.01 * rmax;
labStr = sprintf('%.0f%s', labAng, char(176));

if labAng == 0
  labStr = [' ',labStr];
end

if labAng == 0 && ~isempty(AUnits)
  
  if strcmpi(AUnits,'[deg T]')
    labStr = sprintf('%s\n%s','True North',labStr);
  elseif strcmpi(AUnits,'[deg M]')
    labStr = sprintf('%s\n%s','Magnetic North',labStr);
  elseif strcmpi(AUnits,'[deg R]')
    labStr = sprintf('%s\n%s','Relative Direction',labStr);
  else
    labStr = sprintf('%s\n%s',labStr,AUnits);
  end
  
end
  
spkHnd = text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', 'center', ...
  'VerticalAlignment', 'middle', ...
  'HandleVisibility', 'off',...
  'FontSize', ph.AFontSize,...
  'Parent', ph.axHnd);

spkHnd = shift2radius(spkHnd, rt, d);


end % annotateSpokes1

%% function annotateWave1 -----------------------------------------------
function spkHnd = annotateWave1(labAng, d, rmax, ph)

%            NOMINAL RELATIVE HEADINGS
%
%                      Head
%                    (180 Deg)
%
%                       /\                            Sea
%                      /  \                         Direction
%     Port Bow        /    \       Stbd Bow            |
%     (135 deg) \     |    |     / (225 deg)           |
%                 \   |    |   /                       |
%                   \ |    | /                         \/
%                     |    |
%   Port Beam  ---->  |    |   <----  Stbd Beam
%    (90 deg)         |    |           (270 deg)
%                   / |    | \
%                 /   |    |   \
%               /     |    |     \
%       Port Quarter  |    |   Stbd Quarter
%         (45 deg)    |    |    (315 deg)
%                     |    |
%                     ------
%
%                    Following
%                     (0 deg)

labStr=[int2str(labAng),char(176)];
rt = 1.01 * rmax;

mlabAng = wrap360(labAng);
if mlabAng==0
  labStr = sprintf('Following\nSeas');
elseif mlabAng==45
  labStr = sprintf('Port\nQuarter');
  rt = .98 * rmax;
elseif mlabAng==90
  labStr = sprintf('Port\nBeam');
elseif mlabAng==135
  labStr = sprintf('Port\nBow');
elseif mlabAng==180
  labStr = sprintf('Head\nSeas');
elseif mlabAng==225
  labStr = sprintf('Stbd\nBow');
elseif mlabAng==270
  labStr = sprintf('Stbd\nBeam');
elseif mlabAng==315
  labStr = sprintf('Stbd\nQuarter');
end

spkHnd = text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', 'center', ...
  'HandleVisibility', 'off',...
  'FontSize', ph.AFontSize,...
  'Parent', ph.axHnd);

spkHnd = shift2radius(spkHnd, rt, d);

end % annotateSpokes2

%% function annotateWave2 -------------------------------------------------
function spkHnd = annotateWave2(labAng, d, rmax, ph)

%            NOMINAL RELATIVE HEADINGS
%
%                      Head
%                    (180 Deg)
%
%                       /\                            Sea
%                      /  \                         Direction
%     Port Bow        /    \       Stbd Bow            |
%     (225 deg) \     |    |     / (135 deg)           |
%                 \   |    |   /                       |
%                   \ |    | /                         \/
%                     |    |
%   Port Beam  ---->  |    |   <----  Stbd Beam
%    (270 deg)         |    |           (90 deg)
%                   / |    | \
%                 /   |    |   \
%               /     |    |     \
%       Port Quarter  |    |   Stbd Quarter
%         (315 deg)    |    |    (45 deg)
%                     |    |
%                     ------
%
%                    Following
%                     (0 deg)

% Ian added Oct 2019 to use PRECAL convention

labStr=[int2str(labAng),char(176)];
rt = 1.01 * rmax;

mlabAng = wrap360(labAng);
if mlabAng==0
  labStr = sprintf('Following\nSeas');
elseif mlabAng==45
  labStr = sprintf('Stbd\nQuarter');
  rt = .98 * rmax;
elseif mlabAng==90
  labStr = sprintf('Stbd\nBeam');
elseif mlabAng==135
  labStr = sprintf('Stbd\nBow');
elseif mlabAng==180
  labStr = sprintf('Head\nSeas');
elseif mlabAng==225
  labStr = sprintf('Port\nBow');
elseif mlabAng==270
  labStr = sprintf('Port\nBeam');
elseif mlabAng==315
  labStr = sprintf('Port\nQuarter');
end

spkHnd = text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', 'center', ...
  'HandleVisibility', 'off',...
  'FontSize', ph.AFontSize,...
  'Parent', ph.axHnd);

spkHnd = shift2radius(spkHnd, rt, d);

end % annotateSpokes2

%% function annotateWind1 -----------------------------------------------
function spkHnd = annotateWind1(labAng, d, rmax, ph)

labAng  = wrap180(labAng);
mlabAng = wrap360(labAng);

rt = 1.005 * rmax;
HA = 'center';

if mlabAng==180
  labStr=sprintf('%.0f%s',labAng,char(176));
elseif mlabAng==0
  labStr=sprintf(' %.0f%s',labAng,char(176));
elseif mlabAng>180
  labStr=sprintf('R%.0f%s', -labAng,char(176));
else 
  labStr=sprintf('G%.0f%s',labAng,char(176));
end

spkHnd=text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', HA, ...
  'HandleVisibility', 'off', ...
  'FontSize', ph.AFontSize,...
  'Parent', ph.axHnd);

spkHnd = shift2radius(spkHnd, rt, d);

end % annotateWind1

%% function annotateWind2 -----------------------------------------------
function spkHnd = annotateWind2(labAng, d, rmax, ph)

labAng  = wrap180(labAng);
mlabAng = wrap360(labAng);

rt = 1.015 * rmax;
HA = 'center';

if mlabAng==180
  labStr=sprintf('Tailwinds\n%.0f%s',labAng,char(176));
elseif mlabAng==0
  labStr=sprintf('Headwinds\n %.0f%s',labAng,char(176));
elseif mlabAng==270
  labStr=sprintf('Port Beam\nWinds\nR%.0f%s',-labAng,char(176));
elseif mlabAng==90
  labStr=sprintf('Stbd. Beam\nWinds\nG%.0f%s',labAng,char(176));
elseif mlabAng>180
  labStr=sprintf('R%.0f%s', -labAng,char(176));
else 
  labStr=sprintf('G%.0f%s',labAng,char(176));
end

spkHnd=text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', HA, ...
  'HandleVisibility', 'off', ...
  'FontSize', ph.AFontSize,...
  'Parent', ph.axHnd);

if mlabAng >180 && mlabAng<360
  spkHnd.Color = 'r';
end
if mlabAng <180 && mlabAng>0
  spkHnd.Color = [0, 0.3906, 0];
end

spkHnd = shift2radius(spkHnd, rt, d);

end % annotateWind2

%% function annotatePiA -----------------------------------------------
function spkHnd = annotatePiA(labAng, d, rmax, ph)

labStr=[int2str(labAng),char(176)];
labStr='';
rt = 1.01 * rmax;

fs = ph.AFontSize;

mlabAng = wrap180(labAng);
if mlabAng==0
  labStr = '$0$';
  rt = 1.01*rt;
elseif mlabAng==15
  labStr = '$\displaystyle\frac{\pi}{12}$';  
elseif mlabAng==22.5
  labStr = '$\displaystyle\frac{\pi}{8}$';    
elseif mlabAng==30
  labStr = '$\displaystyle\frac{\pi}{6}$';    
elseif mlabAng==45
  labStr = '$\displaystyle\frac{\pi}{4}$';
elseif mlabAng==60
  labStr = '$\displaystyle\frac{\pi}{3}$';  
elseif mlabAng==67.5
  labStr = '$\displaystyle\frac{3\pi}{8}$';  
elseif mlabAng==75
  labStr = '$\displaystyle\frac{5\pi}{12}$';   
elseif mlabAng==90
  labStr = '$\displaystyle\frac{\pi}{2}$';
  rt = 1.01*rt;
elseif mlabAng==105
  labStr = '$\displaystyle\frac{7\pi}{12}$';  
elseif mlabAng==120
  labStr = '$\displaystyle\frac{2\pi}{3}$';    
elseif mlabAng==135
  labStr = '$\displaystyle\frac{3\pi}{4}$';
elseif mlabAng==150
  labStr = '$\displaystyle\frac{5\pi}{6}$';  
elseif mlabAng==165
  labStr = '$\displaystyle\frac{11\pi}{12}$';    
elseif mlabAng==180
  labStr = '$\pi$,-$\pi$';
  fs = round(1.5*fs);
  
elseif mlabAng==-15
  labStr = '$-\displaystyle\frac{\pi}{12}$';  
elseif mlabAng==-22.5
  labStr = '$-\displaystyle\frac{\pi}{8}$';    
elseif mlabAng==-30
  labStr = '$-\displaystyle\frac{\pi}{6}$';    
elseif mlabAng==-45
  labStr = '$-\displaystyle\frac{\pi}{4}$';
elseif mlabAng==-60
  labStr = '$-\displaystyle\frac{\pi}{3}$';  
elseif mlabAng==-67.5
  labStr = '$-\displaystyle\frac{3\pi}{8}$';  
elseif mlabAng==-75
  labStr = '$-\displaystyle\frac{5\pi}{12}$';   
elseif mlabAng==-90
  labStr = '$-\displaystyle\frac{\pi}{2}$';
  rt = 1.01*rt;
elseif mlabAng==-105
  labStr = '$-\displaystyle\frac{7\pi}{12}$';  
elseif mlabAng==-120
  labStr = '$-\displaystyle\frac{2\pi}{3}$';    
elseif mlabAng==-135
  labStr = '$-\displaystyle\frac{3\pi}{4}$';
elseif mlabAng==-150
  labStr = '$-\displaystyle\frac{5\pi}{6}$';  
elseif mlabAng==-165
  labStr = '$-\displaystyle\frac{11\pi}{12}$';    
end

spkHnd = text(rt*cosd(d), rt*sind(d), labStr,...
  'HorizontalAlignment', 'center', ...
  'HandleVisibility', 'off',...
  'FontSize', fs,...
  'interpreter','latex',...
  'Parent', ph.axHnd);

spkHnd = shift2radius(spkHnd, rt, d);

end % annotatePiA
