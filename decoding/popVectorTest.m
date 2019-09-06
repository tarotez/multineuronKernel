% coded by Taro Tezuka since 14.10.20
% based on:
% Chap21_PopVectorTest.m
% Chapter 16 - Matlab for Neuroscientists (1st edition)
% Chapter 21 - Matlab for Neuroscientists (2nd edition)
%9-2-08
%This code tests the population vector algorithm on novel data
%run this after running "Chap16_PopVectorTrain.m"
% INPUT:
%   testSpikeTrains: spike trains in trialID -> channelID
% OUTPUT:
%   neuralDir: neural direction
%
function neuralDir = popVectorTest(test_spikeTrains, param, prefDir, type)

testSampleNum = length(test_spikeTrains);
channelNum = length(test_spikeTrains{1});

% compute x and y components of the preferred cueTypess
popX = zeros(channelNum,1);
popY = zeros(channelNum,1);
for channelID = 1:channelNum
    popX(channelID) = cos(prefDir(channelID)); % prefDir is in radians
    popY(channelID) = sin(prefDir(channelID));
end

% compute spike counts for all trials, all neurons

spikeCount = zeros(testSampleNum,1);
w = zeros(channelNum,testSampleNum);

for channelID = 1:channelNum    
    for testSampleID = 1:testSampleNum
        spikeCount(testSampleID) =  size(test_spikeTrains{testSampleID}{channelID},1);
    end    
    if strcmp(type, 'original')
        w(channelID,:) = spikeCount';   % weighting as described in chapter 16 (1st edition) -> chapter 21 (2nd edition).
    else if strcmp(type, 'subtractBaseline')
            % subtracts baseline firing rate. param(channelID,1) is the mean of the fitted cosine function, which means baseline firing rate.
            w(channelID,:) = spikeCount' - repmat(param(channelID,1),1,testSampleNum);  % weighting for Exercise 16.2.2 (1st edition) -> Exercise 21.2.2 (2nd edition) (pg.335).
        else
            disp('type not implemented.');
            return
        end
    end
end

%compute predicted cueTypes X and Y components
neuralX = zeros(testSampleNum,1);
neuralY = zeros(testSampleNum,1);
for testSampleID = 1:testSampleNum
    neuralX(testSampleID) = popX' * w(:,testSampleID); % compute sum over combinations of w*popX
    neuralY(testSampleID) = popY' * w(:,testSampleID); % compute sum over combinations of w*popY
end

%convert to a cueTypes in degrees
neuralDir = mod(atan2(neuralY,neuralX)/pi*180,360);

%{
% bin cueTypes into one of eight targets
neuralBinned = zeros(testSampleNum,1) + nan;
% the degrees wrap around for cueTypes 1
index = find(neuralDir >337.5 | neuralDir <=22.5); 
neuralBinned(index) = 1;
angles = 0:45:315;
for i = 2:8
    index = find (neuralDir >angles(i)-22.5 & neuralDir <=angles(i)+22.5);
    neuralBinned(index) = i;
end
%}

end
