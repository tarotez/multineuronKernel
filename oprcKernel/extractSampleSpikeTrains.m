% Coded by Taro Tezuka since 2015.4.26
% select samples using targetSampleIDs
% i.e. removes a sample only if all of its channels have empty spike trains.
% INPUT
%   multivariateSpikeTrains: condNum x sampleNum x unitNum
%   targetCond
%   targetSampleIDs: dimension is targetSampleNum
% OUTPUT
%   targetSpikeTrains: condNum x targetSampleNum x unitNum
%
function targetSpikeTrains = extractSampleSpikeTrains(multivariateSpikeTrains, targetCondIDs, targetSampleIDs)

condNum = size(multivariateSpikeTrains,1);
targetSpikeTrains = cell(condNum,1);
targetSampleNum = length(targetSampleIDs);

for condCnt = 1:length(targetCondIDs)    
    samples = multivariateSpikeTrains{targetCondIDs(condCnt)};
    targetSamples = cell(targetSampleNum,1);
    for targetSampleCnt = 1:targetSampleNum               
        targetSamples{targetSampleCnt} = samples{targetSampleIDs(targetSampleCnt)};        
    end    
    targetSpikeTrains{targetCondIDs(condCnt)} = targetSamples;    
end

end

