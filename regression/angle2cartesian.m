% coded by Taro Tezuka since 14.10.24
% converts angle t to cartesian coordinates
%
function [h, v] = angle2cartesian(t, period)

h = cos(2 * pi * t / period);
v = sin(2 * pi * t / period);

end

