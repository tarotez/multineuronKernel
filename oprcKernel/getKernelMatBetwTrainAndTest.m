% Coded by Taro Tezuka since 2014.9.18
% calculates vector {k(x^i, x^{new})}_{i}
% train_xs: cell array
% test_x: single test element
% ks: kernel structure by spiketrainlib
% weightMat: weight matrix for mixture kernel
% kernelParam: parameters for the kernel
%
function kernelMatForTestData = getKernelMatBetwTrainAndTest(train_xs, test_xs, ks, weightMat, kernelParams, polyDim, tradeOff)

trainSampleNum = size(train_xs,1);
testSampleNum = size(test_xs,1);
kernelMatForTestData = zeros(trainSampleNum,testSampleNum);

indicatorLength = 50;
indicatorDisplayThresh = round(trainSampleNum / indicatorLength);

disp(['starting getKernelMatBetwTrainAndTest']);

for trainSampleID = 1:trainSampleNum
    if mod(trainSampleID, indicatorDisplayThresh) == 0
        amountDoneSoFar = trainSampleID / indicatorDisplayThresh;
        presentTime = fix(clock);
        disp([num2str(amountDoneSoFar) '/' num2str(indicatorLength) ' done at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
        % save tempKernelMat.mat kernelMat    
    end
    for testSampleID = 1:testSampleNum
        kernelMatForTestData(trainSampleID,testSampleID) = (mixtureKernel(ks, train_xs{trainSampleID}, test_xs{testSampleID}, weightMat, kernelParams) + tradeOff)^polyDim;
    end    
end      

end

