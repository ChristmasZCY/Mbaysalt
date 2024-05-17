function x = wrap360(x)
% wrap360 wraps angles in degrees to the interval [0, 359.99...]
%
%   x = wrap360(x) wraps the input angles x, in degrees, to the
%   interval [0, 359.99...] such that zero maps to zero and 
%   multiples of 360 or -360 are also mapped to zero.
%

x = mod(x, 360);

end % function wrap360