%-----------------------------------------------
% conducts experiments using CRCNS-PVC3 data and evaluates the OPRC kernel
%-----------------------------------------------

%----
% setup data
%----
allMultiSpikeTrains = spikeTrainsFromPVC3();
nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
%----
% divide spike trains for optimization and testing
%----
ratio4optimization = 1/5;   % set it to 1 for train = test
% ratio4optimization = 1;   % set it to 1 for train = test
%----
% trialNum = 50;
% trialNum = 5;
% trialNum = 1;
trialNum = 100;
improvements = zeros(trialNum,1);
meanSum = zeros(trialNum,1);
meanOPRC = zeros(trialNum,1);
%----
cputimesArray = zeros(1,6,trialNum);
%----
for trialID = 1:trialNum
%----
[~, ~, sampleID4optimization, sampleID4test] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio4optimization);
%----
% setup kernel
%----
kernelType = 'mci';
kernelSpecification = '';
timeLength = 2000;
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%----
% parameter optimization
% op is for "optimization parameters"
%----
op.visualize = 0;
% op.visualize = 3;
op.condNum = size(allMultiSpikeTrains,1);
op.evalTargets = {'sum', 'oprc'};
op.rankNum = 1;    % used as the column number of A in M = AA^T + D for the FA kernel
% op.rankNum = 0;      % used as the column number of A in M = AA^T + D for the FA kernel
op.coeff4lowRankMatVec = 0.1;
op.coeff4diagMatVec = 1;
op.origOffDiagElem = 0;
op.learningRate = 0.01;
% op.learningRate = 0.0001; % when set to 0.0001, RMSE was about 16 for both sum and OPRC.
op.period = 360;
%----
% op.loopMax4sumKernel = 10;
op.loopMax4sumKernel = 100;
% op.loopMax4oprcKernel = 100;
op.loopMax4oprcKernel = 500;
op.saveIncrement4sumKernel = op.loopMax4sumKernel + 1;
op.saveIncrement4oprcKernel = op.loopMax4oprcKernel + 1;
%----
op.evalGridType = 'RMSE';
% op.evalGridType = 'leaveOneOut';
% op.evalGridType = 'marginalized';
op.origElemKernelParamVec = 10:10:300;
op.origLogRegCoeffVec = -9:6;
% op.origLogRegCoeffVec = -6:0;
op.stochRMSEtrialNum = 0;
op.stepNum = 3;
op.gridDivideNum = 7;
op.ratio4optimization = ratio4optimization;
op.ks = ks;
%----
multiSpikeTrainsBySampleID4optimization = multiSpikeTrainsBySampleID(sampleID4optimization);
depVarID4optimization = depVarID(sampleID4optimization);
[allParamVecDynamicsH, allParamVecDynamicsV, safeLoopCntH, safeLoopCntV] = optimizeKernelByLeaveOneOutAfterGrid(multiSpikeTrainsBySampleID4optimization, depVarID4optimization, op);
allParamVecH = allParamVecDynamicsH(:,safeLoopCntH);
allParamVecV = allParamVecDynamicsV(:,safeLoopCntV);
%----
% test and get the distribution of RMSE by subsampling
% sp is for "subsampling parameters"
%----
sp = copy2subsamplingParams(op, allParamVecH, allParamVecV, timeLength)
sp.binSize4poissonRegression = 10;
sp.subsampleTrialNum = 1;
% sp.subsampleRatio = 1/2;
sp.subsampleRatio = 1;
sp.saveSubsampleStep = sp.subsampleTrialNum + 1;
sp.thinConditionsBy = 2;
%----
multiSpikeTrainsBySampleID4test = multiSpikeTrainsBySampleID(sampleID4test);
depVarID4test = depVarID(sampleID4test);
[RMSEs,cputimesMat] = evalBySubsampleSpikeTrains(multiSpikeTrainsBySampleID4test, depVarID4test, sp);
cputimesArray(:,:,trialID) = cputimesMat;
improvements(trialID) = (mean(RMSEs.RMSE_sum_kernel) - mean(RMSEs.RMSE_oprc_kernel)) / mean(RMSEs.RMSE_sum_kernel);
showImprovements = improvements(1:trialID)
meanImprovements = sum(improvements) / trialID
%----
meanSum(trialID) = mean(RMSEs.RMSE_sum_kernel);
meanOPRC(trialID) = mean(RMSEs.RMSE_oprc_kernel);
%----
end
%----
mean(improvements)
boxplot([meanSum - meanOPRC])
save ../data.from.decoding/res.optimization.pvc3.1710292208.mat sampleID4optimization sampleID4test op allParamVecDynamicsH allParamVecDynamicsV safeLoopCntH safeLoopCntV allParamVecH allParamVecV timeLength
save ../data.from.decoding/res.subsampling.pvc3.1710292208.mat sampleID4optimization sampleID4test op sp RMSEs improvements meanSum meanOPRC
%----
% PVC3 data (thinned) testing phase
% takes about 10 minutes.
multiSpikeTrainsBySampleID4test = multiSpikeTrainsBySampleID(sampleID4test);
%----
evalTargets = {'popVector', 'maxLike', 'poissonRegression', 'sum'  'oprc'};
ks = op.ks
kernelParamsH = allParamVecH(2)
kernelParamsV = allParamVecV(2)
totalKernelTensorH = getKernelTensor(multiSpikeTrainsBySampleID4test, ks, kernelParamsH);
totalKernelTensorV = getKernelTensor(multiSpikeTrainsBySampleID4test, ks, kernelParamsV);
%----
sampleID2condID = depVarID(sampleID4test);
condNum = op.condNum
timeLength = 600;
thinConditionsBy = 2;
rankNum = op.rankNum
offDiagElemH = allParamVecH(1)
regCoeffH = allParamVecH(3)
offDiagElemV = allParamVecV(1)
regCoeffV = allParamVecV(3)
binSize4poissonRegression = 10;
period = op.period
visualize = op.visualize
[mses, test_depVar, est_depVars] = compareDecodingByDisplacement(evalTargets, multiSpikeTrainsBySampleID4test, totalKernelTensorH, totalKernelTensorV, sampleID2condID, condNum, timeLength, thinConditionsBy, rankNum, offDiagElemH, offDiagElemV, regCoeffH, regCoeffV, binSize4poissonRegression, period, visualize);
mses_pvc3 = mses;
%----
save ../data.from.decoding/res.compareDecodingByDisplacement.pvc3.1710292208.mat mses_pvc3 test_depVar est_depVars timeLength thinConditionsBy binSize4poissonRegression
%----
RMSE_popVec_orig = sqrt(mean(mses.popVec_orig))
RMSE_popVec_subt = sqrt(mean(mses.popVec_subt))
RMSE_maxLike_gaussian = sqrt(mean(mses.maxLike_gaussian))
RMSE_maxLike_poisson = sqrt(mean(mses.maxLike_poisson))
RMSE_poissonRegression = sqrt(mean(mses.poissonRegression))
RMSE_sum_kernel = sqrt(mean(mses.sum_kernel))
RMSE_oprc_kernel = sqrt(mean(mses.oprc_kernel))
%----
plotOnly_compareDecodingByDisplacement6boxes(test_depVar, est_depVars.popVec_orig, est_depVars.popVec_subt, est_depVars.maxLike_gaussian, est_depVars.maxLike_poisson, est_depVars.poissonRegression, est_depVars.sum_kernel, est_depVars.oprc_kernel)

