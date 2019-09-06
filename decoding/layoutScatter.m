% coded by Taro Tezuka from 14.11.6
% 
function layoutScatter(figIDs)

figNum = length(figIDs);

for figCnt = 1:figNum
    
    figure(figIDs(figCnt))    
    xlim([0 330]);
    ylim([0 330]);
    xlabel('correct orientation', 'FontName', 'Helvetica', 'FontSize', 18);
    ylabel('estimated orientation', 'FontName', 'Helvetica', 'FontSize', 18);
    set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', 18, 'xTick', 0:90:270, 'yTick', 0:90:270);
    axis square
    
end

end

