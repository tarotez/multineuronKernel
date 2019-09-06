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
function [leaveOneOutSquaredError] = getLeaveOneOutSquaredErrorOfKernelRegression(totalMixtureKernelMat, totalDepVar, regularizationCoeff, period, foldSize)

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
      
    trainMixtureKernelMat = totalMixtureKernelMat(trainSampleIDs,trainSampleIDs);
    testMixtureKernelMat = totalMixtureKernelMat(trainSampleIDs,testSampleIDs);
    trainDepVar = totalDepVar(trainSampleIDs);
    testDepVar = totalDepVar(testSampleIDs);

    error = periodicDiff(testDepVar, testMixtureKernelMat' * ((trainMixtureKernelMat + regularizationMat) \ trainDepVar), period);    
    % disp(['foldID = ' num2str(foldID) ', trainSampleIDs = ' num2str(trainSampleIDs) ', testSampleIDs = ' num2str(testSampleIDs) ', error = ' num2str(error')]);
        
    leaveOneOutSquaredError = leaveOneOutSquaredError + sum(power(error, 2));
end

end

