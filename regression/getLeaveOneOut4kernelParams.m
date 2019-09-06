% coded by Taro Tezuka since 15.4.25
% get total squared error for leave-one-out analysis of kernel regression
% for a specific set of parameters by fmincon
% INPUT
%   params: parameter vector
%   totalKernelTensor: sampleNum x sampleNum x unitNum x unitNum
%   totalDepVar: values of the dependent variable
%   period: period of the circular values. (set to 0 if not circular)
% OUTPUT
%   leaveOneOutSquaredError: sum of squared errors for kernel regression using kernel ridge regression
%   
function [leaveOneOutSquaredError] = getLeaveOneOut4kernelParams(totalMixtureKernelMat, totalDepVarX, totalDepVarY, regularizationCoeff, period, foldSize)

%----------
% cross-fold validation
sampleNum = size(totalMixtureKernelMat,1);
leaveOneOutSquaredError = 0;

regularizationMat = regularizationCoeff * diag(ones(sampleNum - foldSize,1));

foldNum = floor(sampleNum / foldSize);

for foldID = 1:foldNum
    
    %----------
    % separate mixtureKernelMat to train and test parts
    %{
    testSampleIDstart = foldSize * (foldID - 1) + 1;
    testSampleIDend = foldSize * foldID;    
    trainSampleIDs = [1:testSampleIDstart-1, testSampleIDend+1:sampleNum];
    testSampleIDs = testSampleIDstart:testSampleIDend;
    %}
    
    testSampleIDs = foldID:foldNum:(foldSize * foldNum);
    trainSampleIDs = 1:sampleNum;
    trainSampleIDs(testSampleIDs) = [];
    % disp(['foldID = ' num2str(foldID) ', trainSampleIDs = ' num2str(trainSampleIDs) ', testSampleIDs = ' num2str(testSampleIDs)]);
      
    trainMixtureKernelMat = totalMixtureKernelMat(trainSampleIDs,trainSampleIDs);
    testMixtureKernelMat = totalMixtureKernelMat(trainSampleIDs,testSampleIDs);
    trainDepVarX = totalDepVarX(trainSampleIDs);
    trainDepVarY = totalDepVarY(trainSampleIDs);
    testDepVarX = totalDepVarX(testSampleIDs);
    testDepVarY = totalDepVarY(testSampleIDs);

    errorX = periodicDiff(testDepVarX, testMixtureKernelMat' * ((trainMixtureKernelMat + regularizationMat) \ trainDepVarX), period);
    errorY = periodicDiff(testDepVarY, testMixtureKernelMat' * ((trainMixtureKernelMat + regularizationMat) \ trainDepVarY), period);
    % disp(['error = ' num2str(error')]);
        
    leaveOneOutSquaredError = leaveOneOutSquaredError + sum(power(errorX, 2)) + sum(power(errorY, 2));
end

end

