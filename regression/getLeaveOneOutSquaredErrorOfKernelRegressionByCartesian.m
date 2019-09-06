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
function errors = getLeaveOneOutSquaredErrorOfKernelRegressionByCartesian(testTotalMixtureKernelMatX, testTotalMixtureKernelMatY, testTotalDepVar, regularizationCoeffX, regularizationCoeffY, period)

%----------
% leave-one-out analysis

testSampleNum = size(testTotalDepVar,1);
disp(['size(testTotalMixtureKernelMatX) = ' num2str(size(testTotalMixtureKernelMatX))]);
disp(['testTotalDepVar = ' num2str(testTotalDepVar')]);
disp(['testSampleNum = ' num2str(testSampleNum)]);
errors = zeros(testSampleNum,1);

regularizationMatX = regularizationCoeffX * diag(ones(testSampleNum-1,1));
regularizationMatY = regularizationCoeffY * diag(ones(testSampleNum-1,1));

for testSampleID = 1:testSampleNum
    %----------
    % separate mixtureKernelMat to train and test parts    
    trainSampleIDs = [1:testSampleID-1, testSampleID+1:testSampleNum];    
    trainMixtureKernelMatX = testTotalMixtureKernelMatX(trainSampleIDs,trainSampleIDs);
    trainMixtureKernelMatY = testTotalMixtureKernelMatY(trainSampleIDs,trainSampleIDs);
    testMixtureKernelMatX = testTotalMixtureKernelMatX(trainSampleIDs,testSampleID);
    testMixtureKernelMatY = testTotalMixtureKernelMatY(trainSampleIDs,testSampleID);
    trainDepVar = testTotalDepVar(trainSampleIDs);
    trainDepVarX = cos(trainDepVar * 2 * pi / period);
    trainDepVarY = sin(trainDepVar * 2 * pi / period);
    testDepVar = testTotalDepVar(testSampleID);

    % disp(['size(trainMixtureKernelMatX) = ' num2str(size(trainMixtureKernelMatX))]);
    % disp(['size(trainDepVarX) = ' num2str(size(trainDepVarX))]);
        
    estimatedDepVarX = testMixtureKernelMatX' * ((trainMixtureKernelMatX + regularizationMatX) \ trainDepVarX);
    estimatedDepVarY = testMixtureKernelMatY' * ((trainMixtureKernelMatY + regularizationMatY) \ trainDepVarY);

    estimatedDepVar = xyRatioToAngle(estimatedDepVarX, estimatedDepVarY, period);
   
    errors(testSampleID) = periodicDiff(testDepVar, estimatedDepVar, period);
            
    % disp(['testSampleID = ' num2str(testSampleID) ', testDepVar = ' num2str(testDepVar) ', estimatedDepVarX = ' num2str(estimatedDepVarX) ', estimatedDepVarY = ' num2str(estimatedDepVarY) ', estimatedDepVar = ' num2str(estimatedDepVar) ', error = ' num2str(errors(testSampleID))]);
    
end

end

