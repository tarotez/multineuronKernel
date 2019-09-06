% raeds out pvc-3 data and divides a multichannel long recording of spike train using stimulus presentation timing
% CRCNS pvc-3 data (crcns_pvc3_cat_recordings)
% INPUT:
%   condNum: number of conditions
%   trialNum: number of trials for each condition
%   unitNum: number of units
%   timeLength: in milliseconds
%   high_intensity: high intensity for poisson process, in spikes / millisec.
%   low_intensity: low intensity for poisson process, in spikes / mllisec.
% OUTPUT: 
%   multiChannelSubtrains: stimTypeNum -> sampleNum -> channelNum
%   prefConds: preferred condition

function [multiChannelSubtrains, prefConds] = spikeTrainsFromPoisson(condNum, trialNum, unitNum, timeLength, high_intensity, low_intensity)

prefConds = zeros(unitNum,1);
condID = 1;
for unitID = 1:unitNum
    prefConds(unitID) = condID;
    condID = condID + 1;
    if condID > condNum
       condID = 1; 
    end
end

multiChannelSubtrains = cell(condNum,1);
for condID = 1:condNum    
    multiChannelSubtrainSamples = cell(trialNum,1);    
    for trialID = 1:trialNum
         multiChannelSubtrain = cell(unitNum,1);        
         for unitID = 1:unitNum
             if prefConds(unitID) == condID      
                 lambda = high_intensity;
             else
                 lambda = low_intensity;
             end             
             multiChannelSubtrain{unitID} = poissonProcess(lambda, timeLength);
         end       
        multiChannelSubtrainSamples{trialID} = multiChannelSubtrain;        
    end    
    multiChannelSubtrains{condID} = multiChannelSubtrainSamples;       
end

end

