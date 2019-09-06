% Coded by Taro Tezuka since 2014.9.17
% divide data to training part and test part
% offset should be set between 0 and (sampleNum - testSampleNum)
% setting trainRatio to 0 results in leave-one-out analysis
%
function [train_spikeTrains, train_depVarByIDs, test_spikeTrains, test_depVarByIDs] = divide2trainAndTest4globalSampleID(spikeTrains, depVarByIDs, trainRatio, offset4testPart, permutationInd)

sampleNum = size(spikeTrains,1);

% randInd = randperm(sampleNum);
% xs = xs(randInd);
% y = y(randInd);

if ~isempty(permutationInd)
    spikeTrains = spikeTrains(permutationInd);
    depVarByIDs = depVarByIDs(permutationInd);
end

if trainRatio == 0
    testSampleNum = 1;
else
    testSampleNum = sampleNum - round(sampleNum * trainRatio);
end

trainPartStart1 = 1;
trainPartEnd1 = offset4testPart;
testPartStart = trainPartEnd1 + 1;
testPartEnd = testPartStart + testSampleNum - 1;
trainPartStart2 = testPartEnd + 1;
trainPartEnd2 = sampleNum;

% disp(['original sample = 1:' num2str(sampleNum)]);
% disp(['training data = ' num2str(trainPartStart1) ':' num2str(trainPartEnd1) ' and ' num2str(trainPartStart2) ':' num2str(trainPartEnd2)]);
% disp(['test data = ' num2str(testPartStart) ':' num2str(testPartEnd)]);
% disp(['resulting train data ratio = ' num2str((sampleNum - (testPartEnd - testPartStart + 1)) / sampleNum)]);

train_spikeTrains = {spikeTrains{trainPartStart1:trainPartEnd1,1}, spikeTrains{trainPartStart2:trainPartEnd2,1}}.';
train_depVarByIDs = vertcat(depVarByIDs(trainPartStart1:trainPartEnd1), depVarByIDs(trainPartStart2:trainPartEnd2));

test_spikeTrains = {spikeTrains{testPartStart:testPartEnd,1}}.';
test_depVarByIDs = depVarByIDs(testPartStart:testPartEnd);

end

