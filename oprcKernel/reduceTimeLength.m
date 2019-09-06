% Coded by Taro Tezuka since 2014.9.21
% reduce time lengths of spike trains
%
function [shorterSpikeTrainsArray] = reduceTimeLength(spikeTrains, startTime, newTimeLength)

sampleNum = size(spikeTrains,1);
shorterSpikeTrainsArray = cell(sampleNum,1);
channelNum = size(spikeTrains{1},1);

for sampleID = 1:sampleNum

    shorterSpikeTrains = cell(channelNum,1);
    for channelID = 1:channelNum
        spikeTrain = spikeTrains{sampleID}{channelID};
        % disp(['size(singleChannelSpikeTrain) = ' num2str(size(singleChannelSpikeTrain))]);
        spikeTrain = spikeTrain(spikeTrain > startTime);
        spikeTrain = spikeTrain(spikeTrain < startTime + newTimeLength);
        shorterSpikeTrains{channelID} = spikeTrain - startTime;
    end

    % disp(['size(shorterSpikeTrains) = ' num2str(size(shorterSpikeTrains))]);
            
    shorterSpikeTrainsArray{sampleID} = shorterSpikeTrains;
    
    
end

end

