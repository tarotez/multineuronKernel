% by Taro Tezuka since 14.12.29
% reduces the number of channels for multineuron spike trains
% 
function [ lessChannelSubtrains ] = reduceChannels( multiChannelSubtrains, newChannelNum )

condNum = length(multiChannelSubtrains);
lessChannelSubtrains = cell(condNum,1);

for condID = 1:condNum   
    trialNum = length(multiChannelSubtrains{condID});    
    setOfTrials = cell(trialNum,1);    
    for trialID = 1:trialNum               
        if newChannelNum == 0
            newChannelNum = length(multiChannelSubtrains{condID}{trialID});
        end
        multichannel = cell(newChannelNum,1);
        for channelID = 1:newChannelNum
            multichannel{channelID} = multiChannelSubtrains{condID}{trialID}{channelID};
        end       
        setOfTrials{trialID} = multichannel;
    end
    lessChannelSubtrains{condID} = setOfTrials;    
end


end

