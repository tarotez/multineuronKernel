% Coded by Taro Tezuka since 2014.9.21
% splits kernel matrix to training kernel matrix and train-to-test kernel matrix
%
function [testIndices, trainIndices] = offset2indices(sampleNum, trainRatio, offset4testPart)

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

testIndices = testPartStart:testPartEnd;
trainIndices = [trainPartStart1:trainPartEnd1, trainPartStart2:trainPartEnd2];

end

