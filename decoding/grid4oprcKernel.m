% coded by Taro Tezuka on 16.987
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
function [evalResVec] = grid4oprcKernel(evalType, ks, multiSpikeTrainsBySampleID4optimization, depVar, allParamMat, elemKernelParam, regCoeff, stochRMSEtrialNum)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrainsBySampleID4optimization,1);
[channelNum] = size(multiSpikeTrainsBySampleID4optimization{1},1);
% disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum)]);

[gridPointNum] = length(allParamMat);
evalResVec = zeros(gridPointNum,1);

%-------------------
% compute the kernel matrix
kernelTensor = getKernelTensor(multiSpikeTrainsBySampleID4optimization, ks, elemKernelParam);

for gridPointID = 1:gridPointNum

    offDiag = allParamMat(gridPointID);
    weightMat = offDiag * ones(channelNum) + (1 - offDiag) * eye(channelNum);    
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor, weightMat) + (regCoeff * eye(sampleNum));
    % save temp.kernelMat.sum.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute vector alpha and the inverse of kernelMat invKVec
    % disp('now computing matrix inverse and cholesky decomposition');
    R = chol(kernelMat);
    alpha = R \ (R' \ depVar);

    %------------------
    % compute log likelhiood
    if strcmp(evalType, 'marginalized')                    
        invK = inv(R) * inv(R');
        evalRes = logMarginalizedLikelihoodFromKernelMat(depVar, R, invK);
    elseif strcmp(evalType, 'leaveOneOut')                    
        invKVec = diag(inv(R) * inv(R'));
        evalRes = logLeaveOneOutLikelihoodFromKernelMat(depVar, alpha, invKVec);        
    elseif strcmp(evalType, 'RMSE')        
        evalRes = stochRMSEFromKernelMat(depVar, kernelMat, stochRMSEtrialNum);
    end
    % disp(['gridPointID = ' num2str(gridPointID)])    
    % disp(['  elemKerneParams = ' num2str(elemKernelParams') ', regCoeff = ' num2str(regCoeff)])       
    % disp(['  evalRes = ' num2str(evalRes)]);
    
    evalResVec(gridPointID) = evalRes;
    
end