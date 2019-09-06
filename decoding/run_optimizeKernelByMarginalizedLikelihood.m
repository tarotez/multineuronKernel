% coded by Taro Tezuka since 16.6.22
% runs optimizeROUFAkernelByLeaveOneOut.m
% origElemKernelParams = 11.3137;  % time constant of the elementary kernel
% origRegCoeff = 0.01;
% origRegCoeff = 0.001;
% origRegCoeff = 1;
% origRegCoeff = 10;
% origRegCoeff = 0.001;
% learningRate = 0.00001;
% learningRate = 0.001;
% kernelType = 'mci';
% kernelSpecification = '';
% kernelType = 'count';
% kernelSpecification = '';
% kernelType = 'i_exp_int';
% kernelSpecification = '';

nonEmptySubtrains = removeEmptySamples(allMultiSpikeTrains);
[multiSpikeTrainsBySampleID, depVarID] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
[multiSpikeTrainsBySampleID4optimization, multiSpikeTrainsBySampleID4bootstrap, sampleID4optimization, sampleID4bootstrap] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio4optimization);
totalSampleNum = length(multiSpikeTrainsBySampleID);
unitNum = length(multiSpikeTrainsBySampleID{1});
disp(['totalSumpleNum = ' num2str(totalSampleNum) ', unitNum = ' num2str(unitNum)]);
save params.for.optimizeKernelByMarginalizedLikelihood.mat evalTargets origElemKernelParams origRegCoeff rankNum coeff4lowRankMatVec coeff4diagMatVec learningRate kernelType timeLength sampleID4optimization sampleID4bootstrap loopMax4optimizeElemKernel loopMax4faKernel period
depVarID4optimization = depVarID(sampleID4optimization);
sampleNum = length(sampleID4optimization);
sgdRandomSampleNum = ceil(sampleNum * sgdRandomSampleRatio);
% orig_depVarTypes = 0:20:340;
% period = 360;
theta = indices2valuesByCellArray(orig_depVarTypes, depVarID4optimization);
[depVarH, depVarV] = angle2cartesian(theta, period);
%-----------
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%-----------

% first optimize elementary kernel parameters and regulazation coeff using sum kernel
[multiSpikeTrainsBySampleID4optimizationElemKernel, sampleID4optimizationElemKernel] = extractSamplesByRatio(multiSpikeTrainsBySampleID4optimization, ratio4optimizingElemKernel);
depVarID4optimizationElemKernel = depVarID(sampleID4optimizationElemKernel);
% orig_depVarTypes = 0:20:340;
% period = 360;
thetaElemKernel = indices2valuesByCellArray(orig_depVarTypes, depVarID4optimizationElemKernel);
[depVarHElemKernel, depVarVElemKernel] = angle2cartesian(thetaElemKernel, period);
[~, logLikelihoodLOODynamicsH, allParamVecDynamicsH, safeLoopCntH] = optimizeSumKernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimizationElemKernel, depVarHElemKernel, origElemKernelParams, origRegCoeff, learningRate, loopMax4optimizeElemKernel, saveIncrement4optimizeElemKernel);
save dynamicsH.sum.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH
[~, logLikelihoodLOODynamicsV, allParamVecDynamicsV, safeLoopCntV] = optimizeSumKernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimizationElemKernel, depVarVElemKernel, origElemKernelParams, origRegCoeff, learningRate, loopMax4optimizeElemKernel, saveIncrement4optimizeElemKernel);
save dynamicsV.sum.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV

allParamVecH = allParamVecDynamicsH(:,safeLoopCntH);
allParamVecV = allParamVecDynamicsV(:,safeLoopCntV);

origElemKernelParams = allParamVecH(1);
origRegCoeff = allParamVecH(end);

if sum(strcmp(evalTargets, 'roufa'))
    [allParamVecH, logMarginalizedLikelihoodDynamicsH, allParamVecDynamicsH, safeLoopCntH] = optimizeROUFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVarH, origCoeffOfOneMat, origElemKernelParams, origRegCoeff, sgdRandomSampleNum, learningRate,loopMax, saveIncrement);
    save dynamicsH.fa.mat logMarginalizedLikelihoodDynamicsH allParamVecDynamicsH safeLoopCntH
    [allParamVecV, logMarginalizedLikelihoodDynamicsV, allParamVecDynamicsV, safeLoopCntV] = optimizeROUFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVarV, origCoeffOfOneMat, origElemKernelParams, origRegCoeff, sgdRandomSampleNum, learningRate,loopMax, saveIncrement);
    save dynamicsV.fa.mat logMarginalizedLikelihoodDynamicsV allParamVecDynamicsV safeLoopCntV
    rankNum = 1;
end
if sum(strcmp(evalTargets, 'fa'))
    [allParamVecH, logMarginalizedLikelihoodDynamicsH, allParamVecDynamicsH, safeLoopCntH] = optimizeFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVarH, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, origElemKernelParams, origRegCoeff, sgdRandomSampleNum, learningRate,loopMax, saveIncrement);
    save dynamicsH.fa.mat logMarginalizedLikelihoodDynamicsH allParamVecDynamicsH safeLoopCntH    
    [allParamVecV, logMarginalizedLikelihoodDynamicsV, allParamVecDynamicsV, safeLoopCntV] = optimizeFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVarV, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, origElemKernelParams, origRegCoeff, sgdRandomSampleNum, learningRate,loopMax, saveIncrement);
    save dynamicsV.fa.mat logMarginalizedLikelihoodDynamicsV allParamVecDynamicsV safeLoopCntV
end

save dynamics.params.all.mat logMarginalizedLikelihoodDynamicsH allParamVecDynamicsH safeLoopCntH logMarginalizedLikelihoodDynamicsV allParamVecDynamicsV safeLoopCntV evalTargets origElemKernelParams origRegCoeff rankNum coeff4lowRankMatVec coeff4diagMatVec learningRate kernelType timeLength sampleID4optimization sampleID4bootstrap loopMax period

