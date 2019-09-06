% Coded by Taro Tezuka since 2014.9.15
% count the total number of spikes in multiChannelSubtrains for checking the method
% CRCNS pvc-3 data (crcns_pvc3_cat_recordings)

function [origSpikeNums, mcSpikeNums]  = countTotalSpikeNum(subtrainsArray, spikesBeforeAnyStimArray)

% count original spike nums

spikeFileIdentifiers = {'00', '02', '04', '08', '10', '18', '23', '25', '26', '27'};

stimFileName = 'crcns_pvc3_cat_recordings/drifting_bar/stimulus_data/drifting_bar.din';

disp('stimFileName = ');
disp(stimFileName);

stimFileID = fopen(stimFileName);
stimData = fread(stimFileID,inf,'uint64');

stimMat = [stimData(1:2:end), stimData(2:2:end)];

spikeFileDir = 'crcns_pvc3_cat_recordings/drifting_bar/spike_data/';

spikeFileNum = length(spikeFileIdentifiers);

origSpikeNums = zeros(spikeFileNum, 1);

spikeFileNames = cell(spikeFileNum,1);

for spikeFileID = 1:spikeFileNum

    spikeFileNames{spikeFileID} = strcat('t', spikeFileIdentifiers{spikeFileID}, '.spk');
    
    spikeFilePath = strcat(spikeFileDir, spikeFileNames{spikeFileID});
    
    disp('spikeFilePath = ')
    disp(spikeFilePath);
    
    spikeFilePointer = fopen(spikeFilePath);
    
    spikeTimes = fread(spikeFilePointer,inf,'uint64');
    
    origSpikeNums(spikeFileID) = size(spikeTimes,1); 
    
end

% count spike nums in multichannel subtrains

[stimTypeNum, spikeFileNum] = size(subtrainsArray);

mcSpikeNums = zeros(spikeFileNum,1);

for spikeFileID = 1:spikeFileNum    
    
    mcSpikeNums(spikeFileID) = size(spikesBeforeAnyStimArray{spikeFileID},1);
    for stimTypeID = 1:stimTypeNum
        subtrains = subtrainsArray{stimTypeID, spikeFileID};
        subtrainNum = size(subtrains,2);
        for subtrainID = 1:subtrainNum
            subtrain = subtrains{subtrainID};
            mcSpikeNums(spikeFileID) = mcSpikeNums(spikeFileID) + size(subtrain,1);
        end
    end
    
end
    

end

