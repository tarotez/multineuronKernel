% coded by Taro Tezuka since 14.10.20
% based on:
% Chap21_MaxLikeTest.m
%Chapter 16 - Matlab for Neuroscientists
%9-3-08
%This code tests the maximum likelihood algorithm on novel data
%run this after running "Chap16_MaxLikeTrain.m"

function [est_depVarByIDs, logLikelihood] = maxLikeTest4spikeTrains(test_spikeTrains, meanFRT, stdFRT, distribution)

condNum = size(meanFRT,1);
testSampleNum = size(test_spikeTrains,1);
channelNum = size(test_spikeTrains{1},1);
est_depVarByIDs = zeros(testSampleNum,1);      % estimated dependent variable IDs
logLikelihood = zeros(testSampleNum,condNum);
probSpikes = zeros(channelNum, condNum);

for testSampleID = 1:testSampleNum
    
    spikeCount = zeros(1,channelNum);
    for channelID = 1:channelNum;
        spikeCount(channelID) = size(test_spikeTrains{testSampleID}{channelID},1);
    end
       
    for condID = 1:condNum                
        if strcmp(distribution, 'gaussian')
            % use Gaussian distribution
            probSpikes(:,condID) = normpdf(spikeCount, meanFRT(condID,:), stdFRT(condID,:));
        else if strcmp(distribution, 'poisson')                        
            % use Poisson distribution
            probSpikes(:,condID) = poisspdf(spikeCount, meanFRT(condID,:));
            else
                disp('distribution not implemented.');
                return
            end
        end

        index = find(~isnan(probSpikes(:,condID)));                
        temp = probSpikes(index,condID);
        
        if isempty(index)
           disp(['spikeCount = ' num2str(spikeCount)]);
           disp(['meanFRT = ' num2str(meanFRT(condID,:))]);
           disp(['stdFRT = ' num2str(stdFRT(condID,:))]);
           disp(['index = ' num2str(index)]);
           disp(['probSpikes = ' num2str(probSpikes(:,condID)')]);
        end
        
        % I want to sum logs to avoid multiplying small numbers
        % But I need to avoid NaNs, and zeros
        temp = temp + 10e-5;
        logLikelihood(testSampleID,condID) = sum(log(temp));
    end
    
    %maximimze the log-likelihood
    [~, est_depVarByIDs(testSampleID)] = max(logLikelihood(testSampleID,:));
    
end

end