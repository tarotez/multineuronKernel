% Coded by Taro Tezuka since 2016.6.4
% extract spike trains from multiChannelSubtrains by specified targetTrialIDS.
%
function extractedMultiSpikeTrains = filterByTrialIDs(multiSpikeTrains, targetTrialIDs)

condNum = size(multiSpikeTrains,1);
extractedMultiSpikeTrains = cell(condNum,1);

for condID = 1:condNum   
    samples = multiSpikeTrains{condID};
    extractedMultiSpikeTrains{condID} = samples(targetTrialIDs);
end

end

