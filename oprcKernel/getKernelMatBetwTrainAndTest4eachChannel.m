% Coded by Taro Tezuka since 2014.9.20
% calculates {k(x^i, x^{new})}_{i} for each channel, so that it can be later mixed using weight matrix.
% 
% input:
%   train_xs: cell array
%   test_x: single test element
%   ks: kernel structure by spiketrainlib
%   weightMat: weight matrix for mixture kernel
%   kernelParam: parameters for the kernel
% output:
%   kernelTensorForTesting : [trainSampleNum,testSampleNum,componentNum,componentNum]
%
function kernelTensorForTesting = getKernelMatBetwTrainAndTest4eachChannel(train_xs, test_xs, ks, kernelParams)

trainSampleNum = size(train_xs,1);
testSampleNum = size(test_xs,1);

sample = train_xs{1};
componentNum = size(sample,1);

kernelTensorForTesting = zeros(trainSampleNum,testSampleNum,componentNum,componentNum);

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
        for s = 1:componentNum
            for t = 1:componentNum   
                kernelTensorForTesting(trainSampleID,testSampleID,s,t) = ks.kernel(ks, train_xs{trainSampleID}{s}, test_xs{testSampleID}{t}, kernelParams);
            end
        end

    end    
end      

end

