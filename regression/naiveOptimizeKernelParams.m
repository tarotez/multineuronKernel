% Coded by Taro Tezuka since 14.9.25
% optimizes kernel parameters such as smoothing and scaling
% 
function [scores, errorsByKernelParams] = naiveOptimizeKernelParams(spikeTrains, y, foldNum, ks, regLambda, weightMat, kernelParams, period, thinConditionsBy)

paramNum = length(kernelParams);
errorsByKernelParams = zeros(paramNum,1);
scores = zeros(paramNum,1);

for paramID = 1:paramNum
                
    totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams{paramID});
    
    [totalKernelMat] = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
    
    [meanAbsErrors] = crossValidateKernelWithThinning(totalKernelMat, y, foldNum, regLambda, period, thinConditionsBy);

    disp(['meanAbsErrors for paramID = ' num2str(paramID) ' is ' num2str(meanAbsErrors')]);

    errorsByKernelParams(paramID,1) = mean(meanAbsErrors);
    
    scores(paramID,1) = errorsByKernelParams(paramID,1) / 1;
    
    presentTime = fix(clock);    
    disp(['paramID = ' num2str(paramID) ', kernelParams = ' num2str(kernelParams{paramID}) ', finished at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6)) ', mean(errorsByFolds) = ' num2str(mean(meanAbsErrors))]);
    
    save res.optimizeKernelParams.mat scores errorsByKernelParams kernelParams
end

end

