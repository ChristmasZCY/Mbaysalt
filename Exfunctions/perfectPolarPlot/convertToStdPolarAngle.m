function axAng = convertToStdPolarAngle(angleData, ph)
% axAng = convertToStdPolar(angleData, ph)
%           (where ph is output from makePolarGrid.m)
%
%  NOTE: Input angleData must be in degrees.
%  NOTE: Output axAng are in degrees wrapped to [0-359.999].
%
% The purpose of makePolarGrid.m is to generate polar plots with custom
% appearance such as whether angles increase clockwise or count-clockwise,
% and where 0 degrees is (e.g. at the top like a compass, or anywhere
% else). This is done by converting between the desired plot angle conventions
% and the standard system used in matlab - where angles increase
% counter-clockwise and begin at 0 at the positive cartersian x-axis.
%
% So if for example you were generating a compass-type polar plot where
% north 0deg is at the top of the plot. Then this 0deg in the compass plot
% coordinates would be 90deg in the standard polar system. Likewise south
% at 180deg in plot coordinates would be either -90deg or 270deg in the
% standard polar system.
%
% Examples:
%
%     % This does nothing really because the standard polar system is
%     % already 'ccw','right'
%     axAng = labelAngle2plotAngle(0, 'ccw', 'right', 0) % = 0
%
%     % If we apply a rotation, it will rotate ccw, i.e. in the direction
%     % of the % ADir input.
%     axAng = labelAngle2plotAngle(0, 'ccw', 'right', 30)% = 30
%
%     % If we apply a rotation, it will rotate ccw, i.e. in the direction of the
%     % ADir input. Notice these give the same result by using a negative
%     % angle or changing ADir from 'ccw' to 'cw'
%     axAng = labelAngle2plotAngle(0, 'ccw', 'right', -30)  % = 330
%     axAng = labelAngle2plotAngle(0, 'cw',  'right',  30)  % = 330
%
%     % Now switch the zero position to the top
%     axAng = labelAngle2plotAngle(0, 'ccw', 'top', 0)   % = 90
%
%     % Now switch the zero position to the bottom
%     axAng = labelAngle2plotAngle(0, 'cw', 'bottom', 0)   % = 270
%
%     % Top zero position with a 20 deg ccw rotation
%     axAng = labelAngle2plotAngle(0, 'ccw', 'top', 20)  % = 110
%
%     % Top zero position with a 20 deg cw rotation
%     axAng = labelAngle2plotAngle(0, 'ccw', 'top', -20)   % = 70
%
% Alternative input method using makePolarGrid.m which makes it easy
% to keep track of the orientation used by the figure when plotting
% multiple data sets.
%
% For example, if you had wind direction speed and direction data and were
% using the makePolarGrid with ALabelScheme = 'wind1', then the angles would
% increase clockwise (like a compass) and zero would be at the top of the
% circle. To plot the wind data you would do the following. Take the output
% from makePolarGrid as input to this function, such that:
%
%      ph = makePolarGrid('RLim',[0 50], 'ALabelScheme', 'wind1');
%      axWindAng = labelAngle2plotAngle(windAngles, ph);
%      % Don't forget to convert angles to radians for pol2cart
%      [px,py] = pol2cart(axWindAng*pi/180, windSpd);
%      plot(px,py,'.k');
%
%      % Now include another data set to the plot.
%      axWindAng2 = labelAngle2plotAngle(windAngles2, ph);
%      [px2,py2] = pol2cart(axWindAng2*pi/180, windSpd2);
%      plot(px2,py2,'.b');
%
% Eric Thornhill, January 2019

if ~isfield(ph, 'rotateGrid')
  ph.rotateGrid = 0;
end

ADir       = ph.ADir;
AZeroPos   = ph.AZeroPos;
rotateGrid = ph.rotateGrid;


% Get proper angle direction
switch lower(ADir)
  case {'clockwise','cw'}
    axAng = -angleData - rotateGrid;
  case {'counterclockwise','counter-clockware','ccw'}
    axAng = angleData + rotateGrid;
  otherwise
    error(['unrecognized angleDir: ',ADir]);
end

% Get proper position for zero angle position
switch lower(AZeroPos)
  case {'right','r'}
    axAng = axAng + 0;
  case {'top','t'}
    axAng = axAng + 90;
  case {'left','l'}
    axAng = axAng + 180;
  case {'bottom','b'}
    axAng = axAng - 90;
  otherwise
    error(['unrecognized zeroPos: ',AZeroPos]);
end

axAng = mod(axAng,360);

end % function