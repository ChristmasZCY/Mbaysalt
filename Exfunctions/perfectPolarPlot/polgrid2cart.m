function [px,py] = polgrid2cart(angleData, rData, ph, varargin)
%  [px,py] = polgrid2cart(labAng, rData, varargin)
%        Converts polar coordinate data into cartesian data for plotting on
%        polar grids created by makePolarGrid.m
%
%  angleData, is an angle or vector of angles in the desired polar coordinate
%             format of the plot as generated with makePolarGrid.
%
%  rData, is the corresponding radial data that goes with labAng
%
%  ph, is the output of makePolarGrid.m after making the grid.
%
%  optional arguments:
%  'trimToPlotLimits'  (default = false). This option will assign NaN to 
%                      any angleData or rData that is outside the plot
%                      ranges defined in ph
%
%  Example:
%     ph = makePolarGrid('RTicks', 0:1:10, 'ALabelScheme', 'wind1');
%     [px,py] = labelpol2cart(windDirection, windSpeed, ph);
%     plot(px,py,'.');
%     hold all
%     [pxB,pyB] = labelpol2cart(windDirection, windSpeed, ph, ...
%                 'trimToPlotLimits', true);
%     plot(pxB,pyB,'.');
%
%  Eric Thornhill, November 2019

%% Extract Function Arguments
% Default values, unless over-ridden in varagin
inputArgs        = who;    % This is required by assignFunctionArgs.m
trimToPlotLimits = false;  % assign NaN to any data outside plot limits

% Cannot use input names : 'inputArgs', 'kArg', 'xArg', 'tempArg', 'defArgs'
% See comments in assignFunctionArgs.m for instructions how to use.
assignFunctionArgs;

%% Begin Function

if trimToPlotLimits
  
  id = (rData < ph.RLim(1)) | (rData > ph.RLim(2));
  
  if ~ph.fullCircle
    
    ALim = wrap360(ph.ALim);
    angleData = wrap360(angleData);
    
    if ALim(1) > ALim(2)
      % e.g. range from 330 to 30 (the short way through 0)
      id = id | ((angleData < ALim(1)) & (angleData > ALim(2)));
    else
      % e.g. range from 30 to 330 (goes the long way through 180)
      id = id | ((angleData < ALim(1)) | (angleData > ALim(2)));
    end
    clear ALim
    
  end
    
  angleData(id) = NaN;
  rData(id)  = NaN;  
    
  clear id
end

% Get angles in pol2cart convention (ph is the output from makePolarGrid.m)
axAng = convertToStdPolarAngle(angleData, ph);

% pol2cart uses radians, so don't forget the conversion there. 
try
  [px,py] = pol2cart(axAng*pi/180, rData);
catch
  disp('why!')
end

end % Main funciton