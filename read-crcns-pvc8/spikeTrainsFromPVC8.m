% Coded by Taro Tezuka since 2016.8.12
% raeds out pvc-8 data
% CRCNS pvc-8 data
% INPUT:
%   animalID:
%   targetImgs:
% OUTPUT: 
%   multiChannelSubtrains: condID -> trialID -> unitID

function [multivariateSpikeTrains, timeLength] = spikeTrainsFromPVC8(animalID, targetImgs)

%----
% show images in subplot
if animalID < 10
    animalIDstr = ['0' num2str(animalID)];
else
    animalIDstr = num2str(animalID);
end
load([animalIDstr '.mat'])

[unitNum, ~, trialNum, timeLength] = size(resp_train);

condNum = length(targetImgs);

multivariateSpikeTrains = cell(condNum,1);

for condID = 1:condNum
    multivariateSpikeTrains{condID} = cell(trialNum,1);
    imageID = targetImgs(condID);
    
    for trialID = 1:trialNum
        multivariateSpikeTrains{condID}{trialID} = cell(unitNum);
        % disp(['trialID = ' num2str(trialID)])
        for unitID = 1:unitNum
            recording = permute(resp_train(unitID, imageID, trialID, :), [4 1 2 3]);
            % disp(['unit ' num2str(unitID) ': ' num2str(recording')])
            indexVec = 1:timeLength;
            spikeTimes = indexVec(recording == 1);
            multivariateSpikeTrains{condID}{trialID}{unitID} = spikeTimes;
            if length(spikeTimes) > 0
               % disp(['non empty at {' num2str(condID) '}{' num2str(trialID) '}{' num2str(unitID) '}'])
            end
        end       
        % disp(' ')
    end

end

end

