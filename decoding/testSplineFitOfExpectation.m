% by Taro Tezuka since 15.1.3
% tests spline fit to expectation using Poisson regression
% 
load Chapter19_CenterOutTrain
multiChannelSubtrains = spikeTrainsFromCenterOut(unit, direction, instruction, go);
binSize = 10;
targetCondID = 1;
timeLength = 580;
for targetChannel = 1:10    
    [beta, spikeCounts] = getBeta4poissonRegression(multiChannelSubtrains{targetCondID}, targetChannel, [], zeros(5,1), binSize);
    disp(['targetChannel = ' num2str(targetChannel) ', total spike num = ' num2str(sum(spikeCounts)) ', beta = ' num2str(beta')]);
    expectation = plotExpectation(beta,binSize);
    [totalSpikeCount] = spikeCountsByTimeBins(multiChannelSubtrains{targetCondID}, targetChannel, binSize, timeLength);
    figure
    hold on;
    bar(totalSpikeCount)
    plot(expectation, 'color', 'r')
    plot(expectation * mean(totalSpikeCount) / mean(expectation), 'color', 'b')
    hold off;
    pause
    close
end
