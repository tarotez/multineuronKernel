% Coded by Taro Tezuka since 2014.9.20
% extract channels
%
function [reducedChannelSubtrains] = extractChannels(multiChannelSubtrains, targetChannels)

if isempty(targetChannels)

    reducedChannelSubtrains = multiChannelSubtrains;

else
    
    stimTypeNum = size(multiChannelSubtrains,1);
    reducedChannelSubtrains = cell(stimTypeNum,1);

    for stimTypeID = 1:stimTypeNum

        samples = multiChannelSubtrains{stimTypeID};    
        sampleNum = size(samples,1);
        newSamples = cell(sampleNum,1);

        for sampleID = 1:sampleNum
            sample = samples{sampleID};

            newSamples{sampleID} = sample(targetChannels);

        end

        reducedChannelSubtrains{stimTypeID} = newSamples;

    end

end

end

