% by Taro Tezuka since 14.12.29
% compares decoding methods
% INPUT:
%   multivariateSpikeTrains: condNum -> trialNum -> unitNum
%   timeLength: length of time
%   thinConditionsBy: ratio of thinning conditions
%   ksize: kernel size (in milliseconds)
%   offDiag: off diagonal entry for the mixture kernel
%   reg: regularization parameter for kernel ridge regresion
%   figID: ID for figure
% OUTPUT:
%   mse_popVec_orig:
%   mse_popVec_subt:
%   mse_maxLike_gaussian:
%   mse_maxLike_poisson:
%   mse_poissonRegression:
%   mse_kernel:

function plotOnly_compareDecodingByDisplacement(test_depVar, est_depVar_popVec_orig, est_depVar_popVec_subt, est_depVar_maxLike_gaussian, est_depVar_maxLike_poisson, est_depVar_poissonRegression, est_depVar_kernel, ksize, offDiag, reg, binSize4poissonRegression, thinConditionsBy, timeLength)

%{
orig_condNum = size(multivariateSpikeTrains,1);
segmentNum = 1;
shorterSubtrains = divideByTimeLength(multivariateSpikeTrains, timeLength, segmentNum);
targetChannels = [];
reducedChannelSubtrains = extractChannels(shorterSubtrains, targetChannels);
nonEmptySubtrains = removeEmptySamples(reducedChannelSubtrains);
[spikeTrains, depVarByIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
%}
% foldNum = 0;
period = 360;
% increment = period / orig_condNum;
figID = 1;

%----
method = 'popVector';
option = 'original';
% [~, mse_popVec_orig, est_depVar_popVec_orig, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_popVec_orig = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.08, 0.625, 0.3, 0.3];
positionVector4subplotBoxplot = [0.08, 0.65, 0.3, 0.275];
subplotTitle = 'pop. vec. (original)';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_popVec_orig;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 1;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%----
method = 'popVector';
option = 'subtractBaseline';
% [~, mse_popVec_subt, est_depVar_popVec_subt, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_popVec_subt = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.395, 0.625, 0.3, 0.3];
positionVector4subplotBoxplot = [0.395, 0.65, 0.3, 0.275];
subplotTitle = 'pop. vec. (subt. base.)';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_popVec_subt;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%----
method = 'maxLike';
option = 'gaussian';
% [~, mse_maxLike_gaussian, est_depVar_maxLike_gaussian, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_maxLike_gaussian = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.71, 0.625, 0.3, 0.3];
positionVector4subplotBoxplot = [0.71, 0.65, 0.3, 0.275];
subplotTitle = 'max. like. (Gaussian)';
origins = test_depVar;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_maxLike_gaussian;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%----
method = 'maxLike';
option = 'poisson';
% [~, mse_maxLike_poisson, est_depVar_maxLike_poisson, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_maxLike_poisson = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.08, 0.125, 0.3, 0.3];
positionVector4subplotBoxplot = [0.08, 0.15, 0.3, 0.275];
subplotTitle = 'max. like. (Poisson)';
origins = test_depVar;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_maxLike_poisson;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 1;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

method = 'poissonRegression';
% option = 'spline';
% option.binSize4poissonRegression = binSize4poissonRegression;
% [~, mse_poissonRegression, est_depVar_poissonRegression, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_poissonRegression = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.395, 0.125, 0.3, 0.3];
positionVector4subplotBoxplot = [0.395, 0.15, 0.3, 0.275];
subplotTitle = 'max. like. (spline)';
origins = test_depVar;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_poissonRegression;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%{
method = 'freeKnot';
% option = 'spline';
option.binSize4poissonRegression = binSize4poissonRegression;
[~, mse_freeKnot, est_depVar_freeKnot, test_depVars] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_poissonRegression = sqrt(mean(meanSquaredErrors));
positionVector4subplot = [0.375, 0.1, 0.3, 0.275];
subplotTitle = 'max. like. (free knot)';
origins = test_depVars;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_freeKnot;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVars, period, figID, positionVector4subplot, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplot, subplotTitle, showTitle, showXlabel, showYlabel);
%}

%----
kernelType = 'mci';
kernelSpecification = '';
%{
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
kernelParams = [ksize, 1];
% the line below may take some time
totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams);
channelNum = size(spikeTrains{1},1);
orig_depVarTypes = ((360/orig_condNum):(360/orig_condNum):360) - (360/orig_condNum);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarByIDs);
diagComponent = 1;
weightMat = ((diagComponent - offDiag) * eye(channelNum)) + (offDiag * ones(channelNum));
totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
foldNum = 0;
% [~, mse_kernel, est_depVar_kernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMat, depVars, foldNum, reg, period, thinConditionsBy);
% RMSE_kernel = sqrt(mean(meanSquaredErrors));
%}
positionVector4subplotScatter = [0.71, 0.125, 0.3, 0.3];
positionVector4subplotBoxplot = [0.71, 0.15, 0.3, 0.275];
subplotTitle = 'kernel ridge regression';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_kernel;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)

end

