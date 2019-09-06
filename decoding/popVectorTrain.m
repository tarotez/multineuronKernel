% coded by Taro Tezuka since 14.10.20
% based on:
% Chap21_PopVectorTrain.m
%Chapter 16 - Matlab for Neuroscientists
%9-2-08
%This code trains a population vector algorithm
%i.e. it fits each neuron's firing rate to a tuning curve
% load Chapter13_CenterOutTrain
% load Chapter19_CenterOutTrain  % changed by Taro Tezuka, 14.10.19
% 
function [param, prefDir, spikeCountCell] = popVectorTrain(train_spikeTrains, train_depVarByIDs, condNum, maxRadian)

[spikeCountCell, channelNum] = spikeTrains2spikeCount(train_spikeTrains, train_depVarByIDs, condNum);

prefDir = zeros(channelNum,1);
param = zeros(channelNum,3);

for channelID = 1:channelNum

    spikeCount = zeros(1,condNum);
    for condID = 1:condNum
        % if sum(spikeCountCell{condID, channelID}) > 0
            spikeCount(1,condID) = mean(spikeCountCell{condID, channelID});
        % else
        %    spikeCount(1,condID) = 0;
        % end
    end
    
    % fit a cosine tuning curve to "spikeCount"
    % disp(['maxRadian = ' num2str(maxRadian)]);
    % disp(['condNum = ' num2str(condNum)]);
    ang = 0:(maxRadian/condNum):(maxRadian*(condNum-1)/condNum);
    mystring = 'p(1) + p(2) * cos( theta - p(3) )';
    myfun = inline(mystring,'p','theta');
    % disp(['ang = ' num2str(ang)])
    % disp(['skc = ' num2str(spikeCount)])
    % disp(['size(ang) = ' num2str(size(ang))])
    % disp(['size(skc) = ' num2str(size(spikeCount))])
    if sum(spikeCount) == 0
        param(channelID,:) = zeros(1,3);
    else
        param(channelID,:) = nlinfit(ang, spikeCount, myfun, [1 1 0])';
    end
    % disp(['param(' num2str(channelID) ',:) = ' num2str(param(channelID,:))]);
    
    % draws a function myfun by using sampling points indicated by ang2
    % ang2 = 0:.001:2*pi;
    ang2 = 0:.001:maxRadian;
    fit = myfun(param(channelID,:), ang2);
    
    % easiest to pick preferred cueTypes (in degrees) from fit data
    % finds the peak of the function myfun
    [~, prefDirInd] = max(fit);
    prefDir(channelID) = ang2(prefDirInd);
    
end

end