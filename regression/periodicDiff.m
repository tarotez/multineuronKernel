% coded by Taro Tezuka since 14.10.23
% calculates difference between periodic numbers, especially angles
% 
function diff = periodicDiff(value1, value2, period)

if period == 0
    diff = abs(value1 - value2);
else
    diff = min(abs(value1 - value2), abs(period - abs(value1 - value2)));
end

end

