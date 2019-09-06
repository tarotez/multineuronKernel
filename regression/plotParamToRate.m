% coded by Taro Tezuka since 14.9.16
% visually shows correlation between param and rate
% for pvc-3 data in crcns
% 
function [meanRates] = plotParamToRate(subtrainsArray, timeLengthOfEachSubtrain)

%-----
% calculate mean rates for each condition

[condNum, channelNum] = size(subtrainsArray);

meanRates = zeros(condNum,channelNum);

for condID = 1:condNum

    for channelID = 1:channelNum
    
    subtrains = subtrainsArray{condID, channelID};
    
    sampleNum = length(subtrains);
    rates = zeros(sampleNum,1);
    for sampleID = 1:sampleNum
        subtrain = subtrains{sampleID};
        disp(['length(subtrain) = ' num2str(length(subtrain))]);
        rates(sampleID) = length(subtrain) / timeLengthOfEachSubtrain;
    end
    
    meanRates(condID, channelID) = mean(rates);
    
    end
end

% plot(meanRates);

%-------
% set up for line looks
lineStyles = {'-', ':', '--', '-', ':', '--', '-', ':', '--', '-', ':', '--'};
lineColors ={'b', 'g', 'r', 'm', 'k', 'b', 'g', 'r', 'm', 'k', 'b', 'g', 'r', 'm', 'k'};

hold on;
for channelID = 1:channelNum
    p = plot(meanRates(:,channelID));
    set(p, 'LineStyle', lineStyles{channelID}, 'LineWidth', 2, 'Color', lineColors{channelID});
end
hold off;

end

