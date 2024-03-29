%-----------------------------------------------
% conducts experiments for comapring OPRC kernel with SpiKernel
%-----------------------------------------------

%----
% optimize hyperparameters for population Spikernel
allMultiSpikeTrains = spikeTrainsFromPVC3();
nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
ratio4optimization = 1/5;   % set it to 1 for train = test
[~, ~, sampleID4optimization, sampleID4test] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio4optimization);
multiSpikeTrainsBySampleID4optimization = multiSpikeTrainsBySampleID(sampleID4optimization);
depVarID4optimization = depVarID(sampleID4optimization);
kernelType = 'spikernel';
timeLength = 1000;
kernelSpecification = '';
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%----
thinConditionsBy = 2;
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
op.origLogRegCoeffVec = -6:0;
op.stochRMSEtrialNum = 0;
op.stepNum = 5;
op.gridDivideNum = 7;
op.ratio4optimization = ratio4optimization;
op.ks = ks;
%----
[allParamVecDynamicsH, allParamVecDynamicsV, safeLoopCntH, safeLoopCntV] = optimizeKernelByGrid4spikernel(multiSpikeTrainsBySampleID4optimization, depVarID4optimization, op);
allParamVecH = allParamVecDynamicsH(:,safeLoopCntH)
allParamVecV = allParamVecDynamicsV(:,safeLoopCntV)
%----
save ../data.from.decoding/res.optimization.pvc3.popSpikernel.1703070409.mat sampleID4optimization sampleID4test op allParamVecDynamicsH allParamVecDynamicsV safeLoopCntH safeLoopCntV allParamVecH allParamVecV timeLength

%----
% testing using learned hyperparameters
multiSpikeTrainsBySampleID4test = multiSpikeTrainsBySampleID(sampleID4test);
depVarID4test = depVarID(sampleID4test);
offDiagH = allParamVecH(1);
offDiagV = allParamVecV(1);
kernelParamsH = allParamVecH(2:end-1)
kernelParamsV = allParamVecV(2:end-1)
regCoeffH = allParamVecH(end);
regCoeffV = allParamVecV(end);
foldNum = 0;
period = 360;
figID = 100;
multiSpikeTrainsBySampleID4test = multiSpikeTrainsBySampleID(sampleID4test);
depVarID4test = depVarID(sampleID4test);
condNum = size(allMultiSpikeTrains,1);
[mses, test_depVar, est_depVars] = compareSpikernelByDisplacement(multiSpikeTrainsBySampleID4test, depVarID4test, condNum, timeLength, thinConditionsBy, kernelParamsH, kernelParamsV, offDiagH, offDiagV, regCoeffH, regCoeffV, period, foldNum, figID);
save ../data.from.decoding/res.compareSpikernelByDisplacement.1703070409.mat mses test_depVar est_depVars
%----
RMSE_popSpi = sqrt(mean(mses.popSpikernel))
RMSE_oprcSpi = sqrt(mean(mses.oprcSpikernel))
plotOnly_compareSpikernelByDisplacementHorizontal(test_depVar, est_depVars.popSpikernel, est_depVars.oprcSpikernel, figID);
