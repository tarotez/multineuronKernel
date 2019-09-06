% Coded by Taro Tezuka since 2014.9.23
% randomize the order of a cell array and indices vector
%
function [xs, stimIDs, randIndices] = randomizeOrder(xs, stimIDs)

sampleNum = size(xs,1);

randIndices = randperm(sampleNum);
xs = xs(randIndices);
stimIDs = stimIDs(randIndices);

end

