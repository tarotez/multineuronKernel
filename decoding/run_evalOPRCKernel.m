% coded by Taro Tezuka since 16.9.8

mainLoopFoldNum = 50;
% mainLoopFoldNum = 2;

%----
visualize = 0;
kernelType = 'mci'; kernelSpecification = '';
% kernelType = 'wmci'; kernelSpecification = 'quadratic';
[allMultiSpikeTrains] = spikeTrainsFromPVC3();
timeLength = 1000;
% ratio4optimization = 1;   % for train = test
ratio4optimizingSumKernel = 1/3;
ratio4optimizingOPRCKernel = 1/2;

costType4sumKernel = 'min';
% origElemKernelParamVec = power(2, 3:10);
% origElemKernelParamVec = power(2, 3:8);
% origElemKernelParamVec = 80:20:120;
origElemKernelParamVec = 10:10:300;
% origLogRegCoeffVec = -3:-1;
origLogRegCoeffVec = -6:3;

stochRMSEtrialNum = 0;   % in case using all data (no stochasticity)
% stepNum = 3;
stepNum = 10;
% gridDivideNum = 3;
gridDivideNum = 7;

%----
% loopMax4OPRCKernel = 3;
loopMax4OPRCKernel = 50;
% saveIncrement4OPRCKernel = 3;
saveIncrement4OPRCKernel = 50;
learningRate = 0.1;

%----
period = 360;
thinConditionsBy = 1;

%----
condNum = size(allMultiSpikeTrains,1);
increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);

%----
nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);

%----
offDiags = zeros(mainLoopFoldNum,2);
elemKernelParams = zeros(mainLoopFoldNum,2);
regCoeffs = zeros(mainLoopFoldNum,2);
rmse_sumKernel = zeros(mainLoopFoldNum,1);
rmse_OPRCKernel = zeros(mainLoopFoldNum,1);

for mainLoopFoldID = 1:mainLoopFoldNum

    [multiSpikeTrainsBySampleID4sumKernel, multiSpikeTrainsBySampleID4other, sampleID4sumKernel, sampleID4other] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio4optimizingSumKernel);
    save params.for.optimizeSumKernel.mat kernelType timeLength sampleID4sumKernel sampleID4other period
    depVarID4sumKernel = depVarID(sampleID4sumKernel);
    theta4sumKernel = indices2valuesByCellArray(orig_depVarTypes, depVarID4sumKernel);
    [depVarH4sumKernel, depVarV4sumKernel] = angle2cartesian(theta4sumKernel, period);
    %-----------
    ks = kernelFactory(kernelType, timeLength, kernelSpecification);
    %-----------

    %----
    % optimize elemKernelParams and regCoeff for sum kernel
    [optimalParamsH] = minimizeRMSEbyGrid4sumKernel(ks, multiSpikeTrainsBySampleID4sumKernel, depVarH4sumKernel, costType4sumKernel, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);
    [optimalParamsV] = minimizeRMSEbyGrid4sumKernel(ks, multiSpikeTrainsBySampleID4sumKernel, depVarV4sumKernel, costType4sumKernel, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);

    elemKernelParamsH = optimalParamsH(1);
    regCoeffH = optimalParamsH(2);
    elemKernelParamsV = optimalParamsV(1);
    regCoeffV = optimalParamsV(2);
    origCoeffOfOneMat = 0;

    %----
    % optimize offDiag for OPRC kernel
    [multiSpikeTrainsBySampleID4OPRCKernel, multiSpikeTrainsBySampleID4testing, sampleID4OPRCKernel, sampleID4testing] = extractSamplesByRatio(multiSpikeTrainsBySampleID4other, ratio4optimizingOPRCKernel);
    depVarID4OPRCKernel = depVarID(sampleID4OPRCKernel);
    theta4OPRCKernel = indices2valuesByCellArray(orig_depVarTypes, depVarID4OPRCKernel);
    [depVarH4OPRCKernel, depVarV4OPRCKernel] = angle2cartesian(theta4OPRCKernel, period);

    likelihoodType = 'marginalized';
    [allParamVecH, logLikelihoodLOODynamicsH, allParamVecDynamicsH, safeLoopCntH] = gradDescentOPRCKernel(likelihoodType, ks, multiSpikeTrainsBySampleID4OPRCKernel, depVarH4OPRCKernel, elemKernelParamsH, regCoeffH, learningRate, loopMax4OPRCKernel, saveIncrement4OPRCKernel);
    [allParamVecV, logLikelihoodLOODynamicsV, allParamVecDynamicsV, safeLoopCntV] = gradDescentOPRCKernel(likelihoodType, ks, multiSpikeTrainsBySampleID4OPRCKernel, depVarV4OPRCKernel, elemKernelParamsV, regCoeffV, learningRate, loopMax4OPRCKernel, saveIncrement4OPRCKernel);

    %----
    % compare sum kernel and OPRC kernel using test data
    depVarID4testing = depVarID(sampleID4testing);
    offDiagH = allParamVecH(1);
    offDiagV = allParamVecV(1);
    offDiags(mainLoopFoldID,:) = [offDiagH, offDiagV];
    elemKernelParams(mainLoopFoldID,:) = [elemKernelParamsH, elemKernelParamsV];
    regCoeffs(mainLoopFoldID,:) = [regCoeffH, regCoeffV];

    [mse_sumKernel, mse_OPRCKernel, est_depVar_sumKernel, est_depVar_OPRCKernel, test_depVar] = compareSumAndOPRCByRMSE(ks, multiSpikeTrainsBySampleID4testing, depVarID4testing, offDiags(mainLoopFoldID,:), elemKernelParams(mainLoopFoldID,:), regCoeffs(mainLoopFoldID,:), period, thinConditionsBy);
       
    rmse_sumKernel(mainLoopFoldID) = sqrt(mean(mse_sumKernel));
    rmse_OPRCKernel(mainLoopFoldID) = sqrt(mean(mse_OPRCKernel));

    save res.evalOPRCKernel.mat offDiags elemKernelParams regCoeffs rmse_sumKernel rmse_OPRCKernel

end




