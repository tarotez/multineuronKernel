% Coded by Taro Tezuka since 2014.9.21
% splits kernel matrix to training kernel matrix and train-to-test kernel matrix
%
function [trainKernelMat, testKernelMat] = splitKernelMat(totalKernelMat, testIndices, trainIndices)

trainKernelMat = totalKernelMat(trainIndices, trainIndices);
testKernelMat = totalKernelMat(trainIndices, testIndices);

end

