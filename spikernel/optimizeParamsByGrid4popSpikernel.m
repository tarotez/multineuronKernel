
function [optimalElemKernelParamsVec, optimalLogRegCoeff] = optimizeParamsByGrid4popSpikernel(ks, multiSpikeTrainsBySampleID4optimization, depVar, evalGridType, stepNum, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum, op)

elemKernelParamCellArray = ks.autoParam(ks, multiSpikeTrainsBySampleID4optimization);
gridPointNum4elemKernelParamVec = length(elemKernelParamCellArray);
elemKernelParamNum = size(elemKernelParamCellArray{1},2);
elemKernelParamMat = zeros(elemKernelParamNum, gridPointNum4elemKernelParamVec);
medianGridIdx = round((max(gridPointNum4elemKernelParamVec))/2);
optimalElemKernelParamsVec = elemKernelParamMat(:,medianGridIdx);

for gridID = 1:gridPointNum4elemKernelParamVec
   elemKernelParamMat(:,gridID) =  elemKernelParamCellArray{gridID}';
end

logRegCoeffVec = origLogRegCoeffVec;
optimalLogRegCoeff = mean(logRegCoeffVec);

if op.visualize == 3
    figure
end
for stepID = 1:stepNum

    % show param values
    disp(['stepID = ' num2str(stepID)])
    % disp(['  elemKernelParamVec = ' num2str(elemKernelParamVec)])
    disp(['  logRegCoeffVec = ' num2str(logRegCoeffVec)])
        
    %----
    % optimize elemKernelParams            
    % gridPointNum4elemKernelParamVec = length(elemKernelParamVec);
    % disp(['size(elemKernelParamVec = ' num2str(size(elemKernelParamVec)) ', size(allParamMat) = ' num2str(size(allParamMat))])
    constantRegCoeffVec = ones(1,gridPointNum4elemKernelParamVec) * exp(optimalLogRegCoeff);
    evalRes4elemKernelParams = grid4popSpikernel(evalGridType, ks, multiSpikeTrainsBySampleID4optimization, depVar, elemKernelParamMat, constantRegCoeffVec, stochRMSEtrialNum);               
    disp(['  after optimizing elemKernel, evalRes = ' num2str(min(evalRes4elemKernelParams))])
    [~,minGridIdx] = min(evalRes4elemKernelParams);
    optimalElemKernelParamsVec = elemKernelParamMat(:,minGridIdx);
    
    %-----
    % optimize regCoeff
    gridPointNum4logRegCoeffVec = length(logRegCoeffVec);
    % disp(['size(logRegCoeffVec = ' num2str(size(logRegCoeffVec)) ', size(allParamMat) = ' num2str(size(allParamMat))])    
    constantElemKernelParamMat = optimalElemKernelParamsVec * ones(1,gridPointNum4logRegCoeffVec);
    
    regCoeffVec = exp(logRegCoeffVec);
        
    evalRes4regCoeff = grid4popSpikernel(evalGridType, ks, multiSpikeTrainsBySampleID4optimization, depVar, constantElemKernelParamMat, regCoeffVec, stochRMSEtrialNum);                   
    
    if op.visualize == 3
        subplot(stepNum,1,stepID)
        plot(evalRes4regCoeff)
        title(['stepID = ' num2str(stepID)])        
        set(gca, 'TickDir', 'out', 'FontName', 'Helvetica', 'FontSize', 18, 'XTickLabel', logRegCoeffVec, 'XTick', 1:length(logRegCoeffVec))
        disp(['  stepID = ' num2str(stepID)])
        disp(['    logRegCoeffVec = ' num2str(logRegCoeffVec)])
        disp(['    evalRes4regCoeff = ' num2str(evalRes4regCoeff')])
        [minVal,optIdx] = min(evalRes4regCoeff);        
        disp(['    minVal = ' num2str(minVal) ' at logRegCoeff = ' num2str(logRegCoeffVec(optIdx))])
    end
    
    [logRegCoeffVec, optimalLogRegCoeff] = setNewGridPoints(evalGridType, logRegCoeffVec, evalRes4regCoeff, gridDivideNum);
    disp(['  after optimizing regCoeff, evalRes = ' num2str(min(evalRes4regCoeff)) ' with optimalElemKernelParamsVec = ' num2str(optimalElemKernelParamsVec') ', optimalLogRegCoeff = ' num2str(optimalLogRegCoeff)])
    
    % save opt.params.mat optimalElemKernelParams optimalLogRegCoeff

end

% optimalParams = [optimalElemKernelParam; exp(optimalLogRegCoeff)];

end

