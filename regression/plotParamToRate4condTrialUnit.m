% coded by Taro Tezuka since 14.9.16
% visually shows correlation between param and rate
% for pvc-3 data in crcns
% 
function [meanRates] = plotParamToRate4condTrialUnit(multivariateSpikeTrains, timeLength)

%-----
% calculate mean rates for each condition

condNum = length(multivariateSpikeTrains);
trialNum = length(multivariateSpikeTrains{1});
unitNum = length(multivariateSpikeTrains{1}{1});

rates = zeros(condNum,trialNum,unitNum);
for condID = 1:condNum
    for trialID = 1:trialNum
        for unitID = 1:unitNum
            subtrain = multivariateSpikeTrains{condID}{trialID}{unitID};
            rates(condID,trialID,unitID) = length(subtrain) / timeLength;
        end        
    end
end

meanRates = permute(mean(rates,2),[1 3 2]);

% plot(meanRates);

%-------
% set up for line looks
lineStyles = {'-', ':', '--', '-', ':', '--', '-', ':', '--', '-', ':', '--'};
lineColors ={'b', 'g', 'r', 'm', 'k', 'b', 'g', 'r', 'm', 'k', 'b', 'g'};
lineTypeNum = length(lineColors);

figure
hold on;
for unitID = 1:unitNum
    p = plot(meanRates(:,unitID));
    lineID = rem(unitID, lineTypeNum) + 1;
    set(p, 'LineStyle', lineStyles{lineID}, 'LineWidth', 2, 'Color', lineColors{lineID});
end
hold off;

end

