% coded by Taro Tezuka since 2014.9.20
% visualize the correlation in a single holdout between test_y and est_y using scatter plot 
%
function [error, est_y, test_y] = scatterSingleFold(totalKernelTensor, y, trainIndices, testIndices, regLambda, offDiagComponent, period)
    
    % presentTime = fix(clock);    
    % disp(['paramID = ' num2str(paramID) ' starting at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
    componentNum = size(totalKernelTensor, 3);
    diagComponent = 1;

    weightMat = ((diagComponent - offDiagComponent) * eye(componentNum)) + (offDiagComponent * ones(componentNum));

    totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
    trainKernelMat = totalKernelMat(trainIndices, trainIndices);
    testKernelMat = totalKernelMat(trainIndices, testIndices);
    train_y = y(trainIndices);
    test_y = y(testIndices);

    if period == 0
        % not angular y
        alpha = kernelRegression(trainKernelMat, train_y, regLambda);
        est_y = predictByAlpha(testKernelMat, alpha);
    else
        % angular y
        [train_h, train_v] = angle2cartesian(train_y, period);
        alpha_h = kernelRegression(trainKernelMat, train_h, regLambda);        
        est_h = predictByAlpha(testKernelMat, alpha_h);
        alpha_v = kernelRegression(trainKernelMat, train_v, regLambda);        
        est_v = predictByAlpha(testKernelMat, alpha_v);
        est_y = cartesian2angle(est_h, est_v, period);        
    end

    scatter(test_y, est_y);
    % xlim([0 160]);
    % ylim([0 max(est_y)]);
    % xlabel('correct orientation', 'FontName','Times','FontSize', 18);
    % ylabel('estimated orientation', 'FontName','Times','FontSize', 18);
    % set(gca, 'FontName', 'Times', 'FontSize', 18);
    
    error = abs(est_y - test_y);
    
end

