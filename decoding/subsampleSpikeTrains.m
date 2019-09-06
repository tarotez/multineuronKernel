% INPUT:
%   allMultivariateSpikeTrains:
%   resampleTrialNum:
% OUTPUT:
%   resampledMultivariateSpikeTrains: 
function [subsampledSpikeTrainsBySampleID, subsampled_sampleID2condID, randomIndicesMat] = subsampleSpikeTrains(spikeTrainsBySampleIDs4bootstrap, depVarIDs4bootstrap, subsampleTrialNum, subsampleRatio)

sampleNum = length(depVarIDs4bootstrap);
% sampleNum = length(spikeTrainsBySampleIDs4bootstrap);
subsampleNum = ceil(sampleNum * subsampleRatio);
subsampledSpikeTrainsBySampleID = cell(subsampleTrialNum,1);
subsampled_sampleID2condID = cell(subsampleTrialNum,1);
randomIndicesMat = zeros(subsampleNum, subsampleTrialNum);

for subsampleTrialID = 1:subsampleTrialNum
    randOrder = randperm(sampleNum);
    randomIndices = randOrder(1:subsampleNum);
    subsampledSpikeTrainsBySampleID{subsampleTrialID} = spikeTrainsBySampleIDs4bootstrap(randomIndices);    
    subsampled_sampleID2condID{subsampleTrialID} = depVarIDs4bootstrap(randomIndices);        
    randomIndicesMat(:,subsampleTrialID) = randomIndices';
end

end
