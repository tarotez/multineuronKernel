% by Taro Tezuka since 14.12.29
% compares decoding methods
% INPUT:
%   multiChannelSubtrains: condNum -> trialNum -> unitNum
%   timeLength: length of time
%   thinConditionsBy: ratio of thinning conditions
%   ksize: kernel size (in milliseconds)
%   offDiag: off diagonal entry for the mixture kernel
%   reg: regularization parameter for kernel ridge regresion
%   figID: ID for figure
% OUTPUT:
%   mse_popSpikernel:
%   mse_mixSpikernel: 

% function [mses, test_depVar, est_depVar_popSpikernel, est_depVar_oprcSpikernel] = compareSpikernelByDisplacement(multiSpikeTrainsBySampleID, timeLength, thinConditionsBy, kernelParamsH, kernelParamsV, offDiagH, offDiagV, regCoeffH, regCoeffV, period, foldNum, figID)
function [mses, test_depVar, est_depVars] = compareSpikernelByDisplacement(spikeTrainsBySampleID, sampleID2condID, condNum, timeLength, thinConditionsBy, kernelParamsH, kernelParamsV, offDiagH, offDiagV, regCoeffH, regCoeffV, period, foldNum, figID)

depVarTypes = ((period/condNum):(period/condNum):period) - (period/condNum);
depVars = indices2valuesByCellArray(depVarTypes, sampleID2condID);

%----
% population rate spikernel
% method = 'popSpikernel';
% if sum(strcmp(evalTargets, method))
kernelType = 'spikernel';
kernelSpecification = '';
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
% save temp.mat ks
% the line below may take some time
totalKernelMatH = getKernelMatByPopSpikernel(spikeTrainsBySampleID, ks, kernelParamsH);
totalKernelMatV = getKernelMatByPopSpikernel(spikeTrainsBySampleID, ks, kernelParamsV);
[~, mse_popSpikernel, est_depVar_popSpikernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);
% RMSE_kernel = sqrt(mean(meanSquaredErrors));
subplotTitle = 'population rate';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_popSpikernel;
targets4scatter = targets;
positionVector4subplotScatter = [0.05, 0.125, 0.18, 0.9];
positionVector4subplotBoxplot = [0.3, 0.15, 0.18, 0.85];
showTitle = 1; showXlabel = 1; showYlabel = 1;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel) 
boxplotDisplacement4subplots(origins, targets, period, figID, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)
% end

%----
% oprc
% method = 'oprc';
% if sum(strcmp(evalTargets, method))
unitNum = size(spikeTrainsBySampleID{1},1);
diagComponent = 1;
totalKernelTensorH = getKernelTensor(spikeTrainsBySampleID, ks, kernelParamsH);
totalKernelTensorV = getKernelTensor(spikeTrainsBySampleID, ks, kernelParamsV);
weightMatH = ((diagComponent - offDiagH) * eye(unitNum)) + (offDiagH * ones(unitNum));
weightMatV = ((diagComponent - offDiagV) * eye(unitNum)) + (offDiagV * ones(unitNum));
totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMatH);
totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMatV);
[~, mse_oprcSpikernel, est_depVar_oprcSpikernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);
% RMSE_kernel = sqrt(mean(meanSquaredErrors));
subplotTitle = 'OPRC';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_oprcSpikernel;
targets4scatter = targets;
positionVector4subplotScatter = [0.55, 0.125, 0.18, 0.9];
positionVector4subplotBoxplot = [0.8, 0.15, 0.18, 0.85];
showTitle = 1; showXlabel = 1; showYlabel = 1;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID, positionVector4subplotBoxplot, subplotTitle, showXlabel, showTitle, showYlabel)
% end

mses.popSpikernel = mse_popSpikernel;
mses.oprcSpikernel = mse_oprcSpikernel;
est_depVars.popSpikernel = est_depVar_popSpikernel;
est_depVars.oprcSpikernel = est_depVar_oprcSpikernel;

end

