% coded by Taro Tezuka since 14.10.23
% calculates difference between periodic numbers, especially angles
% INPUT:
%   origin: 
%   target: 
%   period: period
%  OUTPUT
%   diff: phase difference
% 
function diff = phaseDifference(origin, target, period)

if period == 0
    diff = target - origin;    
else
    if abs(target - origin) <= abs(period - abs(target - origin))
        diff = target - origin;
    else                    
        if target > origin
            diff = - (origin + (period - target));
        else
            diff = target + (period - origin);
        end    
    end
end

end

