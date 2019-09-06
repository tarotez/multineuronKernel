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

function plotOnly_compareSpikernelByDisplacementHorizontal(test_depVar, est_depVar_popSpikernel, est_depVar_mixSpikernel, figID)

% figure('Color', [1, 1, 1], 'Position', [100 100 1000 1000], 'Resize', 'off');

mse_popSpikernel = [];
mse_mixSpikernel = [];

%{
orig_condNum = size(multiChannelSubtrains,1);
segmentNum = 1;
shorterSubtrains = divideByTimeLength(multiChannelSubtrains, timeLength, segmentNum);
% targetChannels = [];
reducedChannelSubtrains = extractChannels(shorterSubtrains, targetChannels);
nonEmptySubtrains = removeEmptySamples(reducedChannelSubtrains);
[spikeTrains, depVarByIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
%}
period = 360;
%{
foldNum = 0;
%}

%----
% population rate spikernel
%{
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
% the line below may take some time
totalKernelMat = getKernelMatByPopSpikernel(spikeTrains, ks, kernelParams);
orig_depVarTypes = ((360/orig_condNum):(360/orig_condNum):360) - (360/orig_condNum);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarByIDs);
[~, mse_popSpikernel, est_depVar_popSpikernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMat, depVars, foldNum, reg, period, thinConditionsBy);
% RMSE_kernel = sqrt(mean(meanSquaredErrors));
%}

subplotTitle = 'population Spikernel';
origins = test_depVar;
% origins4scatter = origins;
targets = est_depVar_popSpikernel;
% targets4scatter = targets;
% positionVector4subplotScatter = [0.08, 0.57, 0.42, 0.32];
positionVector4subplotBoxplot = [0.1, 0.15, 0.42, 0.7];
% showTitle = 1; showXlabel = 0; showYlabel = 1;
% scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
showTitle = 1; showXlabel = 1; showYlabel = 1;
boxplotDisplacement4subplots(origins, targets, period, figID, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)

%----
%{
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
% the line below may take some time
totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams);
channelNum = size(spikeTrains{1},1);
orig_depVarTypes = ((360/orig_condNum):(360/orig_condNum):360) - (360/orig_condNum);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarByIDs);
diagComponent = 1;
weightMat = ((diagComponent - offDiag) * eye(channelNum)) + (offDiag * ones(channelNum));
totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
[~, mse_mixSpikernel, est_depVar_mixSpikernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMat, depVars, foldNum, reg, period, thinConditionsBy);
% RMSE_kernel = sqrt(mean(meanSquaredErrors));
%}
subplotTitle = 'OPRC Spikernel';
origins = test_depVar;
% origins4scatter = origins;
targets = est_depVar_mixSpikernel;
% targets4scatter = targets;
% positionVector4subplotScatter = [0.51, 0.57, 0.42, 0.32];
positionVector4subplotBoxplot = [0.53, 0.15, 0.42, 0.7];
% showTitle = 1; showXlabel = 0; showYlabel = 0;
% scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
showTitle = 1; showXlabel = 1; showYlabel = 0;
boxplotDisplacement4subplots(origins, targets, period, figID, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)

end

