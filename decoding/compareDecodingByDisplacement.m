% by Taro Tezuka since 14.12.29
% compares decoding methods
% INPUT:
%   spikeTrainsBySampleID: sampleID -> channelID
%   spikeID2condID:
%   condNum:
%   timeLength: length of time
%   thinConditionsBy: ratio of thinning conditions
%   ksize: kernel size (in milliseconds)
%   regCoeff: regularization parameter for kernel ridge regresion
%   figID: ID for figure
% OUTPUT:
%   mses: mse for different methods
%   test_depVar:
%   est_depVars:
%
function [mses, test_depVar, est_depVars, cputimes] = compareDecodingByDisplacement(evalTargets, spikeTrainsBySampleID, totalKernelTensorH, totalKernelTensorV, sampleID2condID, condNum, timeLength, thinConditionsBy, rankNum, offDiagElemH, offDiagElemV, regCoeffH, regCoeffV, binSize4poissonRegression, period, visualize)

figID = 100;
%{
segmentNum = 1;
shorterSubtrains = divideByTimeLength(multivariateSpikeTrains, timeLength, segmentNum);
% targetChannels = [];
reducedChannelSubtrains = extractChannels(shorterSubtrains, targetChannels);
nonEmptySubtrains = removeEmptySamples(reducedChannelSubtrains);
[spikeTrainsBySampleID, sampleID2condID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
%}
foldNum = 0;
increment = period / condNum;
orig_depVarTypes = ((360/condNum):(360/condNum):360) - (360/condNum);

cputimes = zeros(1,6);

%----
method = 'popVector';
if sum(strcmp(evalTargets, method))
option.type = 'original';
[~, mse_popVec_orig, est_depVar_popVec_orig, test_depVar] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
mses.popVec_orig = mse_popVec_orig;
est_depVars.popVec_orig = est_depVar_popVec_orig;
positionVector4subplotScatter = [0.05, 0.625, 0.3, 0.3];
positionVector4subplotBoxplot = [0.05, 0.65, 0.3, 0.275];
subplotTitle = 'pop. vec. (original)';
origins = test_depVar;
origins4scatter = origins;
targets = est_depVar_popVec_orig;
targets4scatter = targets;
showTitle = 1;
showXlabel = 1;
showYlabel = 1;
if visualize == 1
scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
end
end

%----
method = 'popVector';
if sum(strcmp(evalTargets, method))
    
    t = cputime;
    option.type = 'subtractBaseline';
    [~, mse_popVec_subt, est_depVar_popVec_subt, test_depVar] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
    mses.popVec_subt = mse_popVec_subt;
    est_depVars.popVec_subt = est_depVar_popVec_subt;
    cputimes(1,1) = cputime - t;

    positionVector4subplotScatter = [0.05, 0.625, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.05, 0.65, 0.3, 0.275];
    subplotTitle = 'pop. vec. (subt. base.)';
    origins = test_depVar;
    origins4scatter = origins;
    targets = est_depVar_popVec_subt;
    targets4scatter = targets;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

%----
method = 'maxLike';
if sum(strcmp(evalTargets, method))

    t = cputime;
    option.distribution = 'gaussian';
    [~, mse_maxLike_gaussian, est_depVar_maxLike_gaussian, test_depVar] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
    mses.maxLike_gaussian = mse_maxLike_gaussian;
    cputimes(1,2) = cputime - t;

    est_depVars.maxLike_gaussian = est_depVar_maxLike_gaussian;
    positionVector4subplotScatter = [0.375, 0.625, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.375, 0.65, 0.3, 0.275];
    subplotTitle = 'max. like. (Gaussian)';
    origins = test_depVar;
    origins4scatter = origins + rand(size(origins)) * 4 - 2;
    targets = est_depVar_maxLike_gaussian;
    targets4scatter = targets + rand(size(targets)) * 4 - 2;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

%----
method = 'maxLike';
if sum(strcmp(evalTargets, method))

    t = cputime;
    option.distribution = 'poisson';
    [~, mse_maxLike_poisson, est_depVar_maxLike_poisson, test_depVar] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
    mses.maxLike_poisson = mse_maxLike_poisson;
    est_depVars.maxLike_poisson = est_depVar_maxLike_poisson;
    cputimes(1,3) = cputime - t;

    positionVector4subplotScatter = [0.7, 0.625, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.7, 0.65, 0.3, 0.275];
    subplotTitle = 'max. like. (Poisson)';
    origins = test_depVar;
    origins4scatter = origins + rand(size(origins)) * 4 - 2;
    targets = est_depVar_maxLike_poisson;
    targets4scatter = targets + rand(size(targets)) * 4 - 2;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

method = 'poissonRegression';
if sum(strcmp(evalTargets, method))

    t = cputime;    
    option.binSize4poissonRegression = binSize4poissonRegression;
    [~, mse_poissonRegression, est_depVar_poissonRegression, test_depVar] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
    mses.poissonRegression = mse_poissonRegression;
    est_depVars.poissonRegression = est_depVar_poissonRegression;
    cputimes(1,4) = cputime - t;

    positionVector4subplotScatter = [0.05, 0.125, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.05, 0.15, 0.3, 0.275];
    subplotTitle = 'max. like. (spline)';
    origins = test_depVar;
    origins4scatter = origins + rand(size(origins)) * 4 - 2;
    targets = est_depVar_poissonRegression;
    targets4scatter = targets + rand(size(targets)) * 4 - 2;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel)
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

method = 'freeKnot';
if sum(strcmp(evalTargets, method))
    option.binSize4poissonRegression = binSize4poissonRegression;
    [~, mse_freeKnot, est_depVar_freeKnot, test_depVars] = crossValidateDecoding(spikeTrainsBySampleID, sampleID2condID, foldNum, method, option, increment, period, timeLength, thinConditionsBy);
    mses.freeKnot = mse_freeKnot;
    est_depVars.freeKnot = est_depVar_freeKnot;
    positionVector4subplotScatter = [0.375, 0.125, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.375, 0.15, 0.3, 0.275];
    subplotTitle = 'max. like. (free knot)';
    origins = test_depVars;
    origins4scatter = origins + rand(size(origins)) * 4 - 2;
    targets = est_depVar_freeKnot;
    targets4scatter = targets + rand(size(targets)) * 4 - 2;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVars, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel);
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

%----
% sum kernel
method = 'sum';
if sum(strcmp(evalTargets, method))

    % t = cputime;
    tic;
    channelNum = size(totalKernelTensorH,3);
    depVars = indices2valuesByCellArray(orig_depVarTypes, sampleID2condID);
    weightMat = eye(channelNum);
    totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMat);
    totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMat);
    foldNum = 0;
    [~, mse_sum_kernel, est_depVar_sum_kernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);
    mses.sum_kernel = mse_sum_kernel;
    est_depVars.sum_kernel = est_depVar_sum_kernel;
    % cputimes(1,5) = cputime - t;
    cputimes(1,5) = toc;

    positionVector4subplotScatter = [0.375, 0.125, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.375, 0.15, 0.3, 0.275];
    subplotTitle = 'sum kernel';
    origins = test_depVar;
    origins4scatter = origins;
    targets = est_depVar_sum_kernel;
    targets4scatter = targets;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel);
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

%----
% one parameter R-convolution kernel
method = 'oprc';
if sum(strcmp(evalTargets, method))
    
    % t = cputime;
    tic;
    channelNum = size(totalKernelTensorH,3);
    depVars = indices2valuesByCellArray(orig_depVarTypes, sampleID2condID);
    totalKernelMatH = offDiagElem2totalKernelMat(totalKernelTensorH, offDiagElemH, channelNum);
    totalKernelMatV = offDiagElem2totalKernelMat(totalKernelTensorV, offDiagElemV, channelNum);
    foldNum = 0;
    [~, mse_oprc_kernel, est_depVar_oprc_kernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);
    mses.oprc_kernel = mse_oprc_kernel;
    est_depVars.oprc_kernel = est_depVar_oprc_kernel;    
    % cputimes(1,6) = cputime - t;
    cputimes(1,6) = toc;

    positionVector4subplotScatter = [0.7, 0.125, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.7, 0.15, 0.3, 0.275];
    subplotTitle = 'OPRC kernel';
    origins = test_depVar;
    origins4scatter = origins;
    targets = est_depVar_oprc_kernel;
    targets4scatter = targets;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel);
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

%----
% fa kernel
method = 'fa';
if sum(strcmp(evalTargets, method))
    channelNum = size(totalKernelTensorH,3);
    depVars = indices2valuesByCellArray(orig_depVarTypes, sampleID2condID);
    totalKernelMatH = faKernelParamVec2totalKernelMat(lowRankMatVecH, logDiagMatVecH, totalKernelTensorH, rankNum, channelNum);
    totalKernelMatV = faKernelParamVec2totalKernelMat(lowRankMatVecV, logDiagMatVecV, totalKernelTensorV, rankNum, channelNum);
    foldNum = 0;
    [~, mse_fa_kernel, est_depVar_fa_kernel, test_depVar] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeff, period, thinConditionsBy);
    mses.fa_kernel = mse_fa_kernel;
    est_depVars.fa_kernel = est_depVar_fa_kernel;
    positionVector4subplotScatter = [0.7, 0.125, 0.3, 0.3];
    positionVector4subplotBoxplot = [0.7, 0.15, 0.3, 0.275];
    subplotTitle = 'FA kernel';
    origins = test_depVar;
    origins4scatter = origins;
    targets = est_depVar_fa_kernel;
    targets4scatter = targets;
    showTitle = 1;
    showXlabel = 1;
    showYlabel = 0;
    if visualize == 1
    scatterDisplacement4subplots(origins4scatter, targets4scatter, test_depVar, period, figID, positionVector4subplotScatter, subplotTitle, showTitle, showXlabel, showYlabel);
    boxplotDisplacement4subplots(origins, targets, period, figID + 1, positionVector4subplotBoxplot, subplotTitle, showTitle, showXlabel, showYlabel);
    end
end

end

