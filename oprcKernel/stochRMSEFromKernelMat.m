% coded since 16.9.8

function [RMSE] = stochRMSEFromKernelMat(depVar, kernelMat, trialNum)

sampleNum = size(kernelMat,1);
errorVec = zeros(trialNum,1);
randomize = 1;

if trialNum == 0
    trialNum = sampleNum;
    randomize = 0;
end
    
for trialID = 1:trialNum
    if randomize
        testID = randi(sampleNum);
    else
        testID = trialID;
    end
    trainIDs = 1:sampleNum;
    trainIDs(testID) = [];

    testKernelVec = kernelMat(testID,trainIDs);
    trainKernelMat = kernelMat(trainIDs,trainIDs);
    testDepVar = depVar(testID);
    trainDepVar = depVar(trainIDs);
    
    U = chol(trainKernelMat);
    alpha = U \ (U' \ trainDepVar);
    estDepVar = testKernelVec * alpha;       
    
    % disp(['testDepVar = ' num2str(testDepVar) ', estDepVar = ' num2str(estDepVar) ', testID = ' num2str(testID)]);

    errorVec(trialID) = estDepVar - testDepVar;    

end

RMSE = sqrt(mean(power(errorVec,2)));

end

