% coded by Taro Tezuka since 16.9.8

%----
visualize = 0;
kernelType = 'mci'; kernelSpecification = '';
% kernelType = 'wmci'; kernelSpecification = 'quadratic';
[allMultiSpikeTrains] = spikeTrainsFromPVC3();
timeLength = 1000;
% ratio4optimization = 1;   % for train = test
ratio4optimization = 1/2;
% ratio4optimizingElemKernel = 1;

costType = 'min';
% origElemKernelParamVec = power(2, 3:10);
% origElemKernelParamVec = power(2, 3:8);
% origElemKernelParamVec = 10:10:30;
% origLogRegCoeffVec = -5:-3;
origElemKernelParamVec = 10:10:300;
origLogRegCoeffVec = -6:3;

% stochRMSEtrialNum = 200;
stochRMSEtrialNum = 0;   % in case using all data (no stochasticity)
stepNum = 10;
% gridDivideNum = 3;
gridDivideNum = 7;

%----
period = 360;
condNum = size(allMultiSpikeTrains,1);
increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);

%----
nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
[multiSpikeTrainsBySampleID4optimization, otherMultiSpikeTrainsBySampleID, sampleID4optimization, sampleID4bootstrap] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio4optimization);
save params.for.optimizeSumKernel.mat kernelType timeLength sampleID4optimization sampleID4bootstrap period
depVarID4optimization = depVarID(sampleID4optimization);

theta = indices2valuesByCellArray(orig_depVarTypes, depVarID4optimization);
[depVarH, depVarV] = angle2cartesian(theta, period);
%-----------
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%-----------

[optimalElemKernelParamsH, optimalLogRegCoeffH] = minimizeRMSEbyGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarH, costType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);
[optimalElemKernelParamsV, optimalLogRegCoeffV] = minimizeRMSEbyGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarV, costType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);


