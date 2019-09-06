% Coded by Taro Tezuka since 14.9.19
% extract a single channel from multichannel spike train data xs.
% 
function sts = extractSingleChannel(xs, reducedSampleNum, targetChannel)

origSampleNum = size(xs,1);

if reducedSampleNum == 0
    reducedSampleNum = origSampleNum;
end

sts = cell(reducedSampleNum,1);

for sampleID = 1:reducedSampleNum
   
    multiChannelSpikeTrain = xs{sampleID};
    sts{sampleID} = multiChannelSpikeTrain{targetChannel};
    
end

end

