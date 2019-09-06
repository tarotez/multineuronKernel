% coded by Taro Tezuka since 14.10.24
% bins a continuous value on a circle. binID starts with 1.
% 

function [binnedValues, binIDs] = binPeriodic(origValues, increment, period)

binIDs = round(origValues / increment) + 1;

binnedValues = (binIDs - 1) * increment;

for i = 1:length(origValues)
    if origValues(i) - binnedValues(i) > period - origValues(i) || binnedValues(i) == period
        binIDs(i) = 1;
        binnedValues(i) = 0;
    end
end

end

