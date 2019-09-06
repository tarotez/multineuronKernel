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
stochRMSEtrialNum = 0;

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

allParamNum = 2;
% elemKernelParamVec = power(2, 1:10);
elemKernelParamVec = power(2, 3:10);
% elemKernelParamVec = 8:15;
% regCoeffVec = power(10, -5:1);
% regCoeffVec = power(10, -3);
regCoeffVec = 0.01;

gridPointNum = length(elemKernelParamVec);

allParamMat = zeros(allParamNum, gridPointNum);

allParamMat(1, :) = elemKernelParamVec;
allParamMat(2, :) = ones(1,gridPointNum) * regCoeffVec;

evalTypes = {'marginalized', 'leaveOneOut', 'RMSE'};
% evalTypes = {'RMSE'};
evalTypesNum = length(evalTypes);
evalResH = zeros(evalTypesNum, gridPointNum);
evalResV = zeros(evalTypesNum, gridPointNum);

for evalTypeID = 1:evalTypesNum
    evalResH(evalTypeID,:) = grid4sumKernel(evalTypes{evalTypeID}, ks, multiSpikeTrainsBySampleID4optimization, depVarH, allParamMat, stochRMSEtrialNum);
    evalResV(evalTypeID,:) = grid4sumKernel(evalTypes{evalTypeID}, ks, multiSpikeTrainsBySampleID4optimization, depVarV, allParamMat, stochRMSEtrialNum);
end


