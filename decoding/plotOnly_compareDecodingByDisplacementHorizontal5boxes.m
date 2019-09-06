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

function plotOnly_compareDecodingByDisplacementHorizontal5boxes(test_depVar, est_depVar_popVec_orig, est_depVar_popVec_subt, est_depVar_maxLike_gaussian, est_depVar_maxLike_poisson, est_depVar_poissonRegression, est_depVar_sum_kernel, est_depVar_roufa_kernel)

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
% scatterBottomCoord = 0.125;
% scatterTopCoord = 1;
% boxplotBottomCoord = 0.1;
% boxplotTopCoord = 1;

%{
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
%}

%----
method = 'popVector';
option = 'subtractBaseline';
% [~, mse_popVec_subt, est_depVar_popVec_subt, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_popVec_subt = sqrt(mean(meanSquaredErrors));
% positionVector4subplotScatter = [0.025, 0.125, 0.175, 1];
% positionVector4subplotBoxplot = [0.025, 0.1, 0.175, 1];
positionVector4subplotScatter = [0.06, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.05, 0.1, 0.15, 1];
subplotTitle = 'population vector';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_popVec_subt;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 1;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%----
method = 'maxLike';
option = 'gaussian';
% [~, mse_maxLike_gaussian, est_depVar_maxLike_gaussian, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_maxLike_gaussian = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.255, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.255, 0.1, 0.14, 1];
subplotTitle = 'max. like. (const. rate)';
origins = test_depVar;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_maxLike_gaussian;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 

%{
%----
method = 'maxLike';
option = 'poisson';
% [~, mse_maxLike_poisson, est_depVar_maxLike_poisson, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_maxLike_poisson = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.255, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.255, 0.1, 0.14, 1];
subplotTitle = 'ML Poisson';
origins = test_depVar;
origins4scatter = origins + rand(size(origins)) * 4 - 2;
targets = est_depVar_maxLike_poisson;
targets4scatter = targets + rand(size(targets)) * 4 - 2;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel); 
%}

%----
method = 'poissonRegression';
% option = 'spline';
% option.binSize4poissonRegression = binSize4poissonRegression;
% [~, mse_poissonRegression, est_depVar_poissonRegression, test_depVar] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
% RMSE_poissonRegression = sqrt(mean(meanSquaredErrors));
positionVector4subplotScatter = [0.45, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.45, 0.1, 0.14, 1];
subplotTitle = 'max. like. (varying rate)';
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
% sum kernel
positionVector4subplotScatter = [0.65, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.65, 0.1, 0.14, 1];
subplotTitle = 'sum kernel';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_sum_kernel;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)

%----
% rank-1 uniform factor analysis kernel
positionVector4subplotScatter = [0.85, 0.125, 0.14, 1];
positionVector4subplotBoxplot = [0.85, 0.1, 0.14, 1];
subplotTitle = 'OPRC kernel';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_roufa_kernel;
targets4scatter = targets;
showTitle = 1; showXlabel = 1; showYlabel = 0;
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel)

end

