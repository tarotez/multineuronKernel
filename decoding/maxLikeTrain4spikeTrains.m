% coded by Taro Tezuka since 14.10.19
% based on:
% Chap21_MaxLikeTrain.m
%Chapter 16 - Matlab for Neuroscientists
%9-3-08
%This code trains a maximum likelihood algorithm
%i.e. it records the mean and st. dev of the firing rate 
%for each neuron in each direction.
% load Chapter13_CenterOutTrain
% 
% INPUT: 
%   train_spikeTrains: spike trains in trialID -> channelID
%   train_depVarByIDs: IDs of dependent variable y, as a sequence corresponding to elements of spikeTrains
%   train_depVarByIDs_domain_before_thinning: set of IDs appearing in depVarByIDs before thinning
% OUTPUT:
%   meanFRT: mean of spike counts
%   stdFRT: standard deviation of spike counts
%   spikeCountCell: numbers of spikes

function [meanFRT, stdFRT, spikeCountCell] = maxLikeTrain4spikeTrains(train_spikeTrains, train_depVarByIDs, depVarByID_domain_thinned, condNum_before_thinning)

smallNumber = 10^-5;

[spikeCountCell, channelNum] = spikeTrains2spikeCount(train_spikeTrains, train_depVarByIDs, condNum_before_thinning);

meanFRT = zeros(condNum_before_thinning, channelNum);
stdFRT = zeros(condNum_before_thinning, channelNum);

for condID = 1:condNum_before_thinning
    if ismember(condID, depVarByID_domain_thinned)
        for channelID = 1:channelNum            
            meanFRT(condID, channelID) = mean(spikeCountCell{condID, channelID});                                    
            stdFRT(condID, channelID) = std(spikeCountCell{condID, channelID});
        end
    else        
        for channelID = 1:channelNum
            % meanFRT(condID, channelID) = 0;   % no need because this is initialized as zero
            stdFRT(condID, channelID) = smallNumber;
        end
    end
end

% use firing rate rather than spike counts?
% meanFRT = meanFRT / timeLength;
% stdFRT = stdFRT / timeLength;

end