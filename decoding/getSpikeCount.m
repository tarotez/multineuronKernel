% by Taro Tezuka since 15.1.3
% counts spikes within binRange
% INPUT:
%   spikeTrain: single channel spike train
%   binRange: target time range [startTime endTime]
% OUTPUT:
%   spikeCount: the number of spikes in the target time range
%
function spikeCount = getSpikeCount(spikeTrain, binRange)
    
    latterPart = spikeTrain(binRange(1) <= spikeTrain);        
    spikeCount = length(latterPart(latterPart < binRange(2)));
    
    %{
    if spikeCount > 0
        disp(['in getSpikeCount, spikeTrain = ' num2str(spikeTrain')]);
        disp(['in getSpikeCount, binRange = ' num2str(binRange)]);
        disp(['in getSpikeCount, spikeCount = ' num2str(spikeCount)]);
    end
    %}
    
end
