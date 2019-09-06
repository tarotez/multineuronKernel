
function [evalRes] = evalBySingleParams(evalType, ks, multiSpikeTrainsBySampleID, depVar, offDiag, elemKernelParams, regCoeff, stochRMSEtrialNum)

%-------------------
% compute the kernel matrix
channelNum = length(multiSpikeTrainsBySampleID{1});    
weightMat = (offDiag * ones(channelNum) + (1 - offDiag) * eye(channelNum);
    
kernelTensor = getKernelTensor(multiSpikeTrainsBySampleID, ks, elemKernelParams);

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
       
end

