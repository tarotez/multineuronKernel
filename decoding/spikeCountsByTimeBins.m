% by Taro Tezuka since 15.1.3
% counts number of spikes in each time bin over multiple samples, in order to draw a histogram
% INPUT:
%   spikeTrains4oneConditions: multivariate spike trains. trialID -> channelID
%   targetChannel: channel to look at.
% OUTPUT:
%   totalSpikeCount: binned spike count vector (bin size: 10ms, time length: 580 ms)
% 
function [totalSpikeCount] = spikeCountsByTimeBins(spikeTrains4oneCondition, targetChannel, binSize, timeLength)

%-----
% set parameters

binNum = ceil(timeLength/binSize);
[spikeTrainNum, ~] = size(spikeTrains4oneCondition);
totalSpikeCount = zeros(binNum,1);

for spikeTrainID = 1:spikeTrainNum    
    for binID = 1:binNum
        binRange = [(binID - 1) * binSize, binID * binSize];       
        % disp(['spikeTrain = ' num2str(spikeTrains4oneCondition{spikeTrainID}{targetChannel}')]);
        % disp(['binRange = ' num2str(binRange)]);
        % spikeCount = getSpikeCount(spikeTrains4oneCondition{spikeTrainID}{targetChannel}, binRange);
        % disp(['for spikeTrainID = ' num2str(spikeTrainID) ', binID = ' num2str(binID) ', spike count = ' num2str(spikeCount)]);
        totalSpikeCount(binID) = totalSpikeCount(binID) + getSpikeCount(spikeTrains4oneCondition{spikeTrainID}{targetChannel}, binRange);
    end
end

end

