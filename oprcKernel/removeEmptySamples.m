% Coded by Taro Tezuka since 2014.9.16
% remove empty samples from multiChannelSubtrains
% i.e. removes a sample only if all of its channels have empty spike trains.
%
function slimMultiChannelSpikeTrains = removeEmptySamples(multiChannelSpikeTrains)

condNum = size(multiChannelSpikeTrains,1);
slimMultiChannelSpikeTrains = cell(condNum,1);

for condID = 1:condNum
   
    samples = multiChannelSpikeTrains{condID};    
    trialNum = size(samples,1);
    newSamples = [];    
    if trialNum > 0
        sample = samples{1};
        unitNum = size(sample,1);

        newTrialID = 1;
        for trialID = 1:trialNum
            sample = samples{trialID};
            thereIsASpike = 0;
            for unitID = 1:unitNum
                if length(sample{unitID}) > 0
                    thereIsASpike = 1;
                end
            end        
            if thereIsASpike == 1
                newSamples{newTrialID,1} = samples{trialID};
                newTrialID = newTrialID + 1;
            end        
        end
    end
    slimMultiChannelSpikeTrains{condID} = newSamples;
    
end

end

