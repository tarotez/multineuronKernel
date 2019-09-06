% coded by Taro Tezuka
% optimize hyperparameters of factor analysis kernel by marginalized and leave-one-out analysis likelihood
% Rasmussen and Williams, Gaussian Processes for Machine Learning, pg. 112 Section 5.4.1
% kernelTensor: sampleNum * sampleNum * channelNum * channelNum
% depVar: sampleNum
% lowRankMat: sampleNum * rankNum
% diagonalMatVec: sampleNum
% multivarSpikeTrains: {sampleNum}{channelNum}
% elemKernelParams: elemKernelParamNum
% mixture matrix: P = AA' + D;
% 
function [evalResVec] = grid4popSpikernel(evalGridType, ks, multiSpikeTrainsBySampleID4optimization, depVar, elemKernelParamMat, regCoeffVec, stochRMSEtrialNum)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrainsBySampleID4optimization,1);
% [channelNum] = size(multiSpikeTrainsBySampleID4optimization{1},1);
% disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum)]);

[elemKernelParamNum, gridPointNum] = size(elemKernelParamMat);
evalResVec = zeros(gridPointNum,1);

%--------------
% loop for grid search by parameters
oldElemKernelParams = -Inf * ones(elemKernelParamNum,1);
for gridPointID = 1:gridPointNum
    
    elemKernelParams = elemKernelParamMat(:, gridPointID);
    regCoeff = regCoeffVec(gridPointID);
    
    %-------------------
    % compute the kernel matrix   
    kernelMat = getKernelMatByPopSpikernel(multiSpikeTrainsBySampleID4optimization, ks, elemKernelParams) + (regCoeff * eye(sampleNum));    
    % save temp.kernelMat.sum.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute vector alpha and the inverse of kernelMat invKVec
    % disp('now computing matrix inverse and cholesky decomposition');
    if strcmp(evalGridType, 'marginalized') || strcmp(evalGridType, 'leaveOneOut')  
        R = chol(kernelMat);
        alpha = R \ (R' \ depVar);
    end

    %------------------
    % compute log likelhiood
    if strcmp(evalGridType, 'marginalized')                    
        invK = inv(R) * inv(R');
        evalRes = logMarginalizedLikelihoodFromKernelMat(depVar, R, invK);
    elseif strcmp(evalGridType, 'leaveOneOut')                    
        invKVec = diag(inv(R) * inv(R'));
        evalRes = logLeaveOneOutLikelihoodFromKernelMat(depVar, alpha, invKVec);        
    elseif strcmp(evalGridType, 'RMSE')        
        evalRes = stochRMSEFromKernelMat(depVar, kernelMat, stochRMSEtrialNum);
    end
    % disp(['gridPointID = ' num2str(gridPointID)])    
    % disp(['  elemKerneParams = ' num2str(elemKernelParams') ', regCoeff = ' num2str(regCoeff)])       
    % disp(['  evalRes = ' num2str(evalRes)]);
    
    evalResVec(gridPointID) = evalRes;
    
    oldElemKernelParams = elemKernelParams;

end