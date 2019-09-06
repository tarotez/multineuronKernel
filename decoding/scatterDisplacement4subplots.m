% coded by Taro Tezuka from 14.12.29
% presents figures showing decoding errors of values2 to values1
% INPUT:
%   figID: target figure ID
%   origins: first values (vector)
%   targets: second values (vector)
%   period: period
%   figID: figure ID
%   subplotPositionVector: location (coordinates) of subplot figure
%   subplotTitle: title of subplot
% 
function scatterDisplacement4subplots(origins, targets, originLabels, period, figID, subplotPositionVector, subplotTitle, showTitle, showXlabel, showYlabel)
  
figure(figID);
subplot('position', subplotPositionVector);
originTypeNum = length(origins);

originLabelTypes = unique(originLabels);
originLabelTypeNum = length(originLabelTypes);
quarterIdx = ceil(originLabelTypeNum / 4);
xticks = originLabelTypes(quarterIdx * (0:3) + 1);
xticklabels = xticks;

displacements = zeros(size(origins));
for originIdx = 1:originTypeNum
    displacements(originIdx) = phaseDifference(origins(originIdx), targets(originIdx), period);
end

hold off
scatter(origins, displacements, '.');
hold on
horizontalLineDotNum = 200;
plot(linspace(0, 360, horizontalLineDotNum), zeros(horizontalLineDotNum, 1));
hold off

axis square
xlim([0 330]);
ylim([-190 190]);

if showTitle
    title(subplotTitle, 'FontName', 'Helvetica', 'FontSize', 12)
end
if showXlabel
    xlabel('correct direction', 'FontName', 'Helvetica', 'FontSize', 12);
end
if showYlabel
    ylabel('decoding error', 'FontName', 'Helvetica', 'FontSize', 12);
else
    set(gca,'yticklabel',{[]}) 
end
set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', 12, 'xTick', xticks, 'xTickLabel', xticklabels);
set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', 12, 'yTick', -180:90:180);

end

