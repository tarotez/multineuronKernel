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
gridPointNum = 20;

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

elemKernelParam = 54.9243;
regCoeff = -32.5017;

channelNum = length(multiSpikeTrainsBySampleID4optimization{1});
offDiagVec = linspace(- 1/channelNum, 1/channelNum, gridPointNum);

allParamMat = offDiagVec;

evalTypes = {'marginalized', 'leaveOneOut', 'RMSE'};
% evalTypes = {'RMSE'};
evalTypesNum = length(evalTypes);
evalResH = zeros(evalTypesNum, gridPointNum);
evalResV = zeros(evalTypesNum, gridPointNum);

for evalTypeID = 1:evalTypesNum
    evalResH(evalTypeID,:) = grid4oprcKernel(evalTypes{evalTypeID}, ks, multiSpikeTrainsBySampleID4optimization, depVarH, allParamMat, elemKernelParam, regCoeff, stochRMSEtrialNum);        
    [~,minIdx] = min(evalResH(evalTypeID,:));
    disp(['for ' evalTypes{evalTypeID} '-H, minimum at ' num2str(allParamMat(minIdx))])
    % evalResV(evalTypeID,:) = grid4oprcKernel(evalTypes{evalTypeID}, ks, multiSpikeTrainsBySampleID4optimization, depVarV, allParamMat, elemKernelParam, regCoeff, stochRMSEtrialNum);
    % [~,minIdx] = min(evalResV(evalTypeID,:));
    % disp(['for ' evalTypes{evalTypeID} '-V, minimum at ' allParamMat(minIdx)]    
end
figure
plot(evalResH(1:2,:)')
figure
plot(evalResH(3,:)')
% figure
% plot(evalResV')




