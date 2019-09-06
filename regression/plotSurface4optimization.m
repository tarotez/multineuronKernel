% by Taro Tezuka since 14.12.30
% 

function plotSurface4optimization(heightMat, xlabelStr, ylabelStr, zlabelStr, xticks, yticks, subplotTitle)

surface(heightMat)
xlabel(xlabelStr, 'FontName', 'Helvetica', 'FontSize', 12);
ylabel(ylabelStr, 'FontName', 'Helvetica', 'FontSize', 12);
zlabel(zlabelStr, 'FontName', 'Helvetica', 'FontSize', 12);
xlim([1 length(xticks)])
ylim([1 length(yticks)])
set(gca, 'TickDir', 'out', 'XTickLabel', xticks(2:4:numel(xticks)), 'XTick', 2:4:numel(xticks), 'FontName', 'Helvetica', 'FontSize', 12)
set(gca, 'TickDir', 'out', 'YTickLabel', yticks(2:4:numel(yticks)), 'YTick', 2:4:numel(yticks), 'FontName', 'Helvetica', 'FontSize', 12)
title(subplotTitle, 'FontName', 'Helvetica', 'FontSize', 12)

end

