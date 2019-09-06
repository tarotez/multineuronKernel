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
%   prefAngles: preferred condition for each unit

function [multivariateSpikeTrains, prefAngles] = spikeTrainsFromPoissonCosineTuningMoreRandomized(syn)

condNum = syn.condNum;
trialNum = syn.trialNum;
unitNum = syn.unitNum;
timeLength = syn.timeLength;
high_intensity = syn.high_intensity;
low_intensity = syn.low_intensity;

prefAngles = zeros(unitNum, 1);
for unitID = 1:unitNum    
    prefAngles(unitID) = 2 * pi * rand(1);
end

stimAngles = zeros(condNum, 1);
for condID = 1:condNum
    stimAngles(condID) = 2 * pi * condID / condNum;
end

multivariateSpikeTrains = cell(condNum,1);
for condID = 1:condNum    
    multivariateSpikeTrainSamples = cell(trialNum,1);    
    
    for trialID = 1:trialNum
         multivariateSpikeTrain = cell(unitNum,1);        
         for unitID = 1:unitNum
             % prefAngle = 2 * pi * abs(prefConds(unitID) - condID) / condNum;
             % prefAngle = prefAngleat(unitID, condID);
             lambda = low_intensity + ((high_intensity - low_intensity) * ((cos(prefAngles(unitID) - stimAngles(condID)) + 1) / 2));
             % disp(['for condID = ' num2str(condID) ' and unitID = ' num2str(unitID) ' and prefAngle = ' num2str(prefAngle) ' and lambda = ' num2str(lambda)]);
             multivariateSpikeTrain{unitID} = poissonProcess(lambda, timeLength);
         end
        multivariateSpikeTrainSamples{trialID} = multivariateSpikeTrain;
    end    
    multivariateSpikeTrains{condID} = multivariateSpikeTrainSamples;       
end

end

