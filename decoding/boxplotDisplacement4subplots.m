% coded by Taro Tezuka from 14.12.30
% presents figures showing displacements of values2 to values1
% INPUT:
%   origins: first values (vector)
%   targets: second values (vector)
%   period: period
%   figID: target figure ID
%   subplotPositionVector: location (coordinates) of subplot figure
%   subplotTitle: title of subplot
% OUTPUT:
%   target_by_origin: matrix showing distribution of targets belonging to each origin
%
function [target_by_origin] = boxplotDisplacement4subplots(origins, targets, period, figID, subplotPositionVector, subplotTitle, showTitle, showXlabel, showYlabel)
  
fontSize = 18;
figure(figID);
subplot('position', subplotPositionVector);

sampleNum = length(origins);
originTypes = unique(origins);
originTypeNum = length(originTypes);
quarterIdx = ceil(originTypeNum/4);
xticks = quarterIdx * (0:3) + 1;
xticklabels = originTypes(quarterIdx * (0:3) + 1);
sampleNum4eachStimType = floor(sampleNum / originTypeNum);
target_by_origin = zeros(originTypeNum, sampleNum4eachStimType);

for originIdx = 1:originTypeNum    
    originVal = originTypes(originIdx);
    cnt = 1;
    for targetIdx = 1:length(targets)
        if origins(targetIdx) == originVal
            target_by_origin(originIdx, cnt) = phaseDifference(originVal, targets(targetIdx), period);
            cnt = cnt + 1;
        end
    end
end

boxplot(target_by_origin');
axis square
ylim([-190 190]);

set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', fontSize, 'xTick', xticks, 'xTickLabel', xticklabels);
set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', fontSize, 'yTick', -180:90:180);

if showTitle
    title(subplotTitle, 'FontName', 'Helvetica', 'FontSize', fontSize)
end
if showXlabel
   % xlabel({'', 'correct direction'}, 'FontName', 'Helvetica', 'FontSize', fontSize);   % better not show this because it overlaps with x-axis
    xlabel('correct direction', 'FontName', 'Helvetica', 'FontSize', fontSize);   % better not show this because it overlaps with x-axis
else
    set(gca, 'xTick', [])
end
if showYlabel
    ylabel('decoding error', 'FontName', 'Helvetica', 'FontSize', fontSize);   % better not show this because it overlaps with y-axis
else
    set(gca, 'yTick', [])
end

end

