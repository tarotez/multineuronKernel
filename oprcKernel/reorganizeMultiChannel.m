% Coded by Taro Tezuka since 2014.9.15
% reorganizes the array structure of the spike subtrain data
% CRCNS pvc-3 data (crcns_pvc3_cat_recordings)
% input: 
%   subtrainsArray : [stimTypeNum, channelNum]
% output:
%   multiChannelSubtrains : stimTypeNum -> sampleNum

function [multiChannelSubtrains]  = reorganizeMultiChannel(subtrainsArray)

% convert to a form where the fundamental elements are multichannel subtrains (cell array of single channel subtrains).

[stimTypeNum, channelNum] = size(subtrainsArray);

multiChannelSubtrains = cell(stimTypeNum,1);
for stimTypeID = 1:stimTypeNum
    sampleNum = length(subtrainsArray{stimTypeID,1});
    multiChannelSubtrainSamples = cell(sampleNum,1);    
    
    for sampleID = 1:sampleNum
         multiChannelSubtrain = cell(channelNum,1);        

         for channelID = 1:channelNum
            subtrainSamples = subtrainsArray{stimTypeID, channelID};
            multiChannelSubtrain{channelID} = subtrainSamples{sampleID};
            
         end
        
        multiChannelSubtrainSamples{sampleID} = multiChannelSubtrain;
        
    end
    
    multiChannelSubtrains{stimTypeID} = multiChannelSubtrainSamples;   
    
end

end

