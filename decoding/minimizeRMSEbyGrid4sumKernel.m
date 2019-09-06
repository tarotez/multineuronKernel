
function [optimalElemKernelParams, optimalLogRegCoeff] = minimizeRMSEbyGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVar, evalType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum)

elemKernelParamVec = origElemKernelParamVec;
logRegCoeffVec = origLogRegCoeffVec;
optimalLogRegCoeff = mean(logRegCoeffVec);

for stepID = 1:stepNum
        
    % show param values
    disp(['stepID = ' num2str(stepID)])
    disp(['  elemKernelParamVec = ' num2str(elemKernelParamVec)])
    disp(['  logRegCoeffVec = ' num2str(logRegCoeffVec)])
    
    % optimize elemKernelParams            
    gridPointNum4elemKernelParamVec = length(elemKernelParamVec);
    % disp(['size(elemKernelParamVec = ' num2str(size(elemKernelParamVec)) ', size(allParamMat) = ' num2str(size(allParamMat))])
    constantRegCoeffVec = ones(1,gridPointNum4elemKernelParamVec) * exp(optimalLogRegCoeff);
    costVec4elemKernelParams = grid4sumKernel(evalType, ks, multiSpikeTrainsBySampleID4optimization, depVar, elemKernelParamVec, constantRegCoeffVec, stochRMSEtrialNum);               
    disp(['  RMSE after opt. elemKernel = ' num2str(min(costVec4elemKernelParams))])
    [elemKernelParamVec, optimalElemKernelParams] = setNewGridPoints(elemKernelParamVec, costVec4elemKernelParams, evalType, gridDivideNum);    
    
    % optimize regCoeff
    gridPointNum4logRegCoeffVec = length(logRegCoeffVec);
    % disp(['size(logRegCoeffVec = ' num2str(size(logRegCoeffVec)) ', size(allParamMat) = ' num2str(size(allParamMat))])
    constantElemKernelParamVec = ones(1,gridPointNum4logRegCoeffVec) * optimalElemKernelParams;   
    regCoeffVec = exp(logRegCoeffVec);    
    costVec4regCoeff = grid4sumKernel(evalType, ks, multiSpikeTrainsBySampleID4optimization, depVar, constantElemKernelParamVec, regCoeffVec, stochRMSEtrialNum);                   
    [logRegCoeffVec, optimalLogRegCoeff] = setNewGridPoints(logRegCoeffVec, costVec4regCoeff, evalType, gridDivideNum);
    disp(['  RMSE after opt. regCoeff = ' num2str(min(costVec4regCoeff)) ' with optimalElemKernelParam = ' num2str(optimalElemKernelParams) ', optimalLogRegCoeff = ' num2str(optimalLogRegCoeff)])
    
    save opt.params.mat optimalElemKernelParams optimalLogRegCoeff

end

% optimalParams = [optimalElemKernelParam; exp(optimalLogRegCoeff)];

end

