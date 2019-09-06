%----
visualize = 0;
% ROUFA for PVC8_tiltingbars, based on most promising (1608131148).
% parameter optmization
evalTargets = {'sum', 'roufa'};
% evalTargets = {'sum', 'fa'};
% rankNum = 2;
rankNum = 1;    % used as the column number of A in M = AA^T + D for the FA kernel
% rankNum = 0;      % used as the column number of A in M = AA^T + D for the FA kernel
coeff4lowRankMatVec = 0.1;
coeff4diagMatVec = 1;
origCoeffOfOneMat = 0;
% origElemKernelParams = 11.3137;  % time constant of the elementary kernel
origElemKernelParams = 20;  % time constant of the elementary kernel
origRegCoeff = 1;
sgdRandomSampleRatio = 1/2;
learningRate = 1;
kernelType = 'mci'; kernelSpecification = '';
[allMultiSpikeTrains] = spikeTrainsFromPVC3();
timeLength = 1000;
% ratio4optimization = 1;   % for train = test
ratio4optimization = 1/2;
ratio4optimizingElemKernel = 1;
period = 360;
condNum = size(allMultiSpikeTrains,1);
increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);
%----
%%% loopMax4sumKernel = 20;
%%% saveIncrement = 5;
loopMax4optimizeElemKernel = 2000;
saveIncrement4optimizeElemKernel = 50;
%%% loopMax4faKernel = 500;
%%% saveIncrement4faKernel = 100;
loopMax4faKernel = 50;
saveIncrement4faKernel = 50;
run_optimizeKernelByMarginalizedLikelihood
% run_optimizeKernelByLeaveOneOut
%----
load dynamics.params.all.mat
%----
% section below necessary if just testing.
[allMultiSpikeTrains] = spikeTrainsFromPVC3();
condNum = size(allMultiSpikeTrains,1);
nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%----
% subsample and evaluate RMSE
thinConditionsBy = 1;
allParamVecH = allParamVecDynamicsH(:,safeLoopCntH);
allParamVecV = allParamVecDynamicsV(:,safeLoopCntV);
ksize_H = allParamVecH(2);
ksize_V = allParamVecV(2);
regCoeffH = allParamVecH(end);
regCoeffV = allParamVecV(end);
binSize4poissonRegression = 10;
subsampleTrialNum = 100;
subsampleRatio = 1/2;
% spikeTrainsBySampleID4bootstrap = multiSpikeTrainsBySampleID(sampleID4optimization);   % in case where train = test
% depVarID4bootstrap = depVarID(sampleID4optimization);  % in case where train = test
spikeTrainsBySampleID4bootstrap = multiSpikeTrainsBySampleID(sampleID4bootstrap);
depVarID4bootstrap = depVarID(sampleID4bootstrap);
run_evalBySubsampleSpikeTrains
%----
