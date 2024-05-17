function x = wrap180(x)
% wrap180 wraps angles in degrees to the interval [-179.99..., 180]
%
%   x = wrap180(x) wraps the input angles in x, in degrees, to 
%   the interval [-179.99..., 180] such that multiples of 180 or
%   -180 map to 180.
%

x = mod(x, 360);
k = x > 180;
x(k) = x(k) - 360;

end % function wrap180