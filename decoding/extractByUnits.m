% Coded by Taro Tezuka since 2014.9.20
% extract channels
%
function [reducedUnitsSubtrains] = extractByUnits(multiSpikeTrainsBySampleIDs, targetUnits)

if isempty(targetUnits)
    reducedUnitsSubtrains = multiSpikeTrainsBySampleIDs;
else    
    globalSampleNum = size(multiSpikeTrainsBySampleIDs,1);
    reducedUnitsSubtrains = cell(globalSampleNum,1);
    for globalSampleID = 1:globalSampleNum
        sample = multiSpikeTrainsBySampleIDs{globalSampleID};
        % showSample = sample
        reducedUnitsSubtrains{globalSampleID} = sample(targetUnits);
    end
end

end

