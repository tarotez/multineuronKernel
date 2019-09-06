% since 16.9.10
% 
function [mse_sumKernel, mse_OPRCKernel, est_depVar_sumKernel, est_depVar_OPRCKernel, test_depVar] = compareSumAndOPRCByRMSE(ks, multiSpikeTrainsBySampleID4testing, depVarID4testing, offDiags, elemKernelParams, regCoeffs, period, thinConditionsBy)

offDiagH = offDiags(1);
offDiagV = offDiags(2);
elemKernelParamsH = elemKernelParams(1);
elemKernelParamsV = elemKernelParams(2);
regCoeffH = regCoeffs(1);
regCoeffV = regCoeffs(2);

totalKernelTensorH = getKernelTensor(multiSpikeTrainsBySampleID4testing, ks, elemKernelParamsH);
totalKernelTensorV = getKernelTensor(multiSpikeTrainsBySampleID4testing, ks, elemKernelParamsV);

%-----
% evaluate sum kernel
channelNum = length(multiSpikeTrainsBySampleID4testing{1});
weightMatH = eye(channelNum);
weightMatV = eye(channelNum);
totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMatH);
totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMatV);
foldNum = 0;
[~, mse_sumKernel, est_depVar_sumKernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVarID4testing, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);

%-----
% evaluate OPRC kernel
weightMatH = ((1 - offDiagH) * eye(channelNum)) + (offDiagH * ones(channelNum));
weightMatV = ((1 - offDiagV) * eye(channelNum)) + (offDiagV * ones(channelNum));
totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMatH);
totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMatV);
foldNum = 0;
[~, mse_OPRCKernel, est_depVar_OPRCKernel] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVarID4testing, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);

end

