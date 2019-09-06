% Coded by Taro Tezuka since 2014.9.25
% divide spike trains into shorter ones, so that more spike trains are obtained
%
function shorterSubtrains  = divideByTimeLength(multivariateSpikeTrains, segmentLength, segmentNum)

condNum = size(multivariateSpikeTrains,1);
shorterSubtrains = cell(condNum,1);

for condID = 1:condNum
   
    samples = multivariateSpikeTrains{condID};
    trialNum = size(samples,1);
        
    newSamples = cell(segmentNum * trialNum,1);

    newSampleID = 1;

    if ~isempty(samples)
        unitNum = size(samples{1},1);

        for trialID = 1:trialNum
            sample = samples{trialID};   

                for segmentID = 1:segmentNum

                    startTime = segmentLength * (segmentID - 1);
                    endTime = segmentLength * segmentID;        

                    shorterSpikeTrains = cell(unitNum,1);
                    for unitID = 1:unitNum
                        spikeTrain = sample{unitID};
                        % disp(['size(singleChannelSpikeTrain) = ' num2str(size(singleChannelSpikeTrain))]);
                        spikeTrain = spikeTrain(spikeTrain >= startTime);
                        spikeTrain = spikeTrain(spikeTrain < endTime);
                        shorterSpikeTrains{unitID} = spikeTrain - startTime;
                    end                        
                    newSamples{newSampleID} = shorterSpikeTrains;
                    newSampleID = newSampleID + 1;
                end
        end
    else
        newSamples = [];    
    end           
    shorterSubtrains{condID} = newSamples;    
end

end

