% coded by Taro Tezuka from 14.11.11
% 
function layoutScatter4subplots(figID, xVec, yVec, positionVector, subplotTitle)
  
figure(figID);
subplot('position', positionVector);
scatter(xVec, yVec, 10);
xlim([0 330]);
ylim([0 330]);
xlabel('correct direction', 'FontName', 'Helvetica', 'FontSize', 12);
ylabel('estimated direction', 'FontName', 'Helvetica', 'FontSize', 12);
set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', 12, 'xTick', 0:90:270, 'yTick', 0:90:270);
axis square
title(subplotTitle, 'FontName', 'Helvetica', 'FontSize', 12)

end

