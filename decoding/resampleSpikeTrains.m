% INPUT:
%   allMultivariateSpikeTrains:
%   resampleTrialNum:
% OUTPUT:
%   resampledMultivariateSpikeTrains: 
function [resampledSpikeTrainsBySampleID, resampled_sampleID2condID, randomIndicesMat] = resampleSpikeTrains(spikeTrainsBySampleIDs4bootstrap, depVarIDs4bootstrap, resampleTrialNum)

sampleNum = length(depVarIDs4bootstrap);
resampledSpikeTrainsBySampleID = cell(resampleTrialNum,1);
resampled_sampleID2condID = cell(resampleTrialNum,1);
randomIndicesMat = zeros(sampleNum, resampleTrialNum);

for resampleTrialID = 1:resampleTrialNum
    randomIndices = randi(sampleNum, sampleNum, 1);
    resampledSpikeTrainsBySampleID{resampleTrialID} = spikeTrainsBySampleIDs4bootstrap(randomIndices);    
    resampled_sampleID2condID{resampleTrialID} = depVarIDs4bootstrap(randomIndices);        
    randomIndicesMat(:, resampleTrialID) = randomIndices;
        
    %{
    for sampleID = 1:sampleNum        
        condID = depVarIDs4bootstrap(randomIndices(sampleID));
        if condID2trialNum(condID) == 0
            condID2trialNum(condID) = 1;
        else
            condID2trialNum(condID) = condID2trialNum(condID) + 1;
        end
    end
    resampledMultivariateSpikeTrains{resampleTrialID} = cell(condNum,1);
    for condID = 1:condNum
        resampledMultivariateSpikeTrains{resampleTrialID}{condID} = cell(condID2trialNum(condID),1);    
    end
    newTrialIDs = ones(condNum,1);
    for sampleID = 1:sampleNum
        condID = depVarIDs4bootstrap(randomIndices(sampleID));
        resampledMultivariateSpikeTrains{resampleTrialID}{condID}{newTrialIDs(condID)} = multiSpikeTrainsBySampleIDs4bootstrap{randomIndices(sampleID)};
        newTrialIDs(condID) = newTrialIDs(condID) + 1;
    end
    %}
end

end
