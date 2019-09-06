% Coded by Taro Tezuka since 14.9.18
% cross validation for kernel regression
% 
function [meanAbsErrors, meanSquaredErrors, est_depVar_vec, test_depVar_vec] = crossValidateKernelWithThinningCartesian(totalKernelMat, depVar, foldNum, regLambda, period, thinConditionsBy)

sampleNum = size(totalKernelMat,1);

depVar_types = unique(depVar);
condNum = size(depVar_types,1);

if foldNum == 0
    trainRatio = 0;
    foldNum = sampleNum;
    testSampleSize = 1;
else
    testRatio = 1 / foldNum;
    trainRatio = 1 - testRatio;
    testSampleSize = round(sampleNum * testRatio);
end

% errors = zeros(foldNum, testSampleNumInAFold);
meanAbsErrors = zeros(foldNum, 1);
meanSquaredErrors = zeros(foldNum, 1);
counter = 1;

for foldID = 1:foldNum

    %%% disp(' ');
    %%% disp(['now on foldID = ' num2str(foldID) ' / ' num2str(foldNum)]);
    
    offset4testPart = testSampleSize * (foldID - 1);
    
    [testIndices, trainIndices] = offset2indices(sampleNum, trainRatio, offset4testPart);
    % disp(['testIndices = ' num2str(testIndices)]);
    % disp(['trainIndices = ' num2str(trainIndices)]);

    %-----
    % thin data    
    depVarIDs_types_thinned = 1:thinConditionsBy:condNum;
    depVar_types_thinned = depVar_types(depVarIDs_types_thinned);
    %%% disp(['yIDs_types_thinned = ' num2str(yIDs_types_thinned)]);
        
    train_depVar = depVar(trainIndices);
    % disp(['size(train_y) = ' num2str(size(train_y))]);
    trainIndices_thinned_binaryVec = (ismember(train_depVar, depVar_types_thinned) == 1);    
    % disp(['trainIndices_thinned_binaryVec = ' num2str(trainIndices_thinned_binaryVec')]);
    % disp(['sum(trainIndices_thinned_binaryVec) = ' num2str(sum(trainIndices_thinned_binaryVec))]);
    
    trainIndices_thinned = trainIndices(trainIndices_thinned_binaryVec);
    % disp(['trainIndices = ' num2str(trainIndices)]);
    % disp(['trainIndices_thinned = ' num2str(trainIndices_thinned)]);
    
    % disp(['size(trainIndices,2) = ' num2str(size(trainIndices,2))]);
    %%% disp(['size(trainIndices_thinned,2) = ' num2str(size(trainIndices_thinned,2))]);
    
    % disp(['train_y = ' num2str(train_y')]);
    % disp(['train_y_thinned = ' num2str(train_y(trainIndices_thinned)')]);
    % disp(['size(train_y,1) = ' num2str(size(train_y,1))])
    
    trainKernelMat = totalKernelMat(trainIndices_thinned, trainIndices_thinned);
    testKernelMat = totalKernelMat(trainIndices_thinned, testIndices);
        
    %%% disp(['size(trainKernelMat) = ' num2str(size(trainKernelMat)) ', size(testKernelMat) = ' num2str(size(testKernelMat))]);
    
    train_depVar = depVar(trainIndices_thinned);
    test_depVar = depVar(testIndices);
    % disp(['test_y = ' num2str(test_y')]);
    % disp(['train_y = ' num2str(train_y')]);
    
    if period == 0
        % not angular y
        alpha = kernelRegression(trainKernelMat, train_depVar, regLambda);
        est_depVar = predictByAlpha(testKernelMat, alpha);
    else
        % angular y
        [train_h, train_v] = angle2cartesian(train_depVar, period);
        alpha_h = kernelRegression(trainKernelMat, train_h, regLambda);        
        est_h = predictByAlpha(testKernelMat, alpha_h);
        alpha_v = kernelRegression(trainKernelMat, train_v, regLambda);        
        est_v = predictByAlpha(testKernelMat, alpha_v);
        est_depVar = cartesian2angle(est_h, est_v, period);
    end
    
    % create test_y_vec and est_y_vec used in boxplot
    test_depVar_vec(counter:counter + testSampleSize - 1) = test_depVar;
    est_depVar_vec(counter:counter + testSampleSize - 1) = est_depVar;
    counter = counter + testSampleSize;
    
    % calculate mean aboslute error and mean squared error    
    meanAbsErrors(foldID) = nanmean(periodicDiff(test_depVar, est_depVar, period));
    meanSquaredErrors(foldID) = nanmean(power(periodicDiff(est_depVar, test_depVar, period), 2));    

end

end

