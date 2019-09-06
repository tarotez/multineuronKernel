% coded by Taro Tezuka since 14.10.18
% obtains rates of spikes around presentation of instruction (orientation) and go signal
%
function [ rates ] = ratesByCues(spikeTrain, cueTypes, cueTimes, offsetBefore, offsetAfter)

cueNum = size(cueTimes,1);
cueTypeNum = size(unique(cueTypes),1);
counterByType = ones(cueTypeNum,1);

rates = cell(cueTypeNum,1);

for cueType = 1:cueTypeNum
    
    stimNum = sum(cueTypes == cueType);
    rates{cueType} = zeros(stimNum, 1);
    
end

for cueID = 1:cueNum
    
    cueTime = cueTimes(cueID);
    cueType = cueTypes(cueID);
    
    rates{cueType}(counterByType(cueType)) = getRate(spikeTrain, cueTime - offsetBefore, cueTime - offsetAfter);
    
    counterByType(cueType) = counterByType(cueType) + 1;

end

end

