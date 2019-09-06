% get total spike num for each animal

animalNum = 10;

for animalID = 1:animalNum
   
    [allMultiSpikeTrains, timeLength] = spikeTrainsFromPVC8_tiltingbars(animalID);
    
    totalSpikeNum = 0;
    for condID = 1:length(allMultiSpikeTrains)        
        spikeTrainTrials = allMultiSpikeTrains{condID};
        for trialID = 1:length(spikeTrainTrials)
           multiSpikeTrain = spikeTrainTrials{trialID};
           for unitID = 1:length(multiSpikeTrain)               
               totalSpikeNum = totalSpikeNum + length(multiSpikeTrain{unitID});
           end
        end
    end

    disp(['animalID = ' num2str(animalID) ', total spikeNum = ' num2str(totalSpikeNum)])
    
end


