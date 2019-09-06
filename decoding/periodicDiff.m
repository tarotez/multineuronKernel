% coded by Taro Tezuka since 14.10.23
% calculates difference between periodic numbers, especially angles
% INPUT:
%   origin:
%   target:
%   period
% OUTPUT:
%   diff:
% 
function diff = periodicDiff(origin, target, period)

if period == 0
    diff = abs(target - origin);
else
    diff = min(abs(target - origin), abs(period - abs(target - origin)));
end

end

