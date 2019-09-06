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

function [] = optimizeKernelByLeaveOneOutAfterGrid(sParams);

% totalSampleNum = length(multiSpikeTrainsBySampleID4optimization);
% unitNum = length(multiSpikeTrainsBySampleID4optimization{1});
% disp(['totalSumpleNum = ' num2str(totalSampleNum) ', unitNum = ' num2str(unitNum)]);
save params.for.optimizeKernelByLeaveOneOut.mat evalTargets rankNum coeff4lowRankMatVec coeff4diagMatVec learningRate kernelType timeLength sampleID4optimization sampleID4bootstrap loopMax4optimizeElemKernel loopMax4faKernel period
sampleNum = length(sampleID4optimization);
sgdRandomSampleNum = ceil(sampleNum * sgdRandomSampleRatio);
% orig_depVarTypes = 0:20:340;
% period = 360;
theta = indices2valuesByCellArray(orig_depVarTypes, depVarID4optimization);
[depVarH, depVarV] = angle2cartesian(theta, period);
%-----------
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
%-----------

%-------
%%%%%%
% grid search kernelELem and regCoeff
[optimalElemKernelParamsAfterGridH, optimalLogRegCoeffAfterGridH] = optimizeParamsByGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarH, evalGridType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);
[optimalElemKernelParamsAfterGridV, optimalLogRegCoeffAfterGridV] = optimizeParamsByGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarV, evalGridType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum);

optimalRegCoeffAfterGridH = exp(optimalLogRegCoeffAfterGridH);
oprimalRegCoeffAfterGridV = exp(optimalLogRegCoeffAfterGridV);

%-------
% refine kernelElem and regCoeff using gradient descent
[~, logLikelihoodLOODynamicsAfterSumKernelH, allParamVecDynamicsAfterSumKernelH, safeLoopCntAfterSumKernelH] = optimizeSumKernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, optimalElemKernelParamsAfterGridH, optimalRegCoeffAfterGridH, learningRate, loopMax4optimizeElemKernel, saveIncrement4optimizeElemKernel);
save dynamicsH.sum.mat logLikelihoodLOODynamicsAfterSumKernelH allParamVecDynamicsAfterSumKernelH safeLoopCntAfterSumKernelH
[~, logLikelihoodLOODynamicsAfterSumKernelV, allParamVecDynamicsAfterSumKernelV, safeLoopCntAfterSumKernelV] = optimizeSumKernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, optimalElemKernelParamsAfterGridV, oprimalRegCoeffAfterGridV, learningRate, loopMax4optimizeElemKernel, saveIncrement4optimizeElemKernel);
save dynamicsV.sum.mat logLikelihoodLOODynamicsAfterSumKernelV allParamVecDynamicsAfterSumKernelV safeLoopCntAfterSumKernelV

allParamVecAfterSumKernelH = allParamVecDynamicsAfterSumKernelH(:,safeLoopCntAfterSumKernelH);
allParamVecAfterSumKernelV = allParamVecDynamicsAfterSumKernelV(:,safeLoopCntAfterSumKernelV);

elemKernelParamsAfterSumKernelH = allParamVecAfterSumKernelH(1:end-1);
regCoeffAfterSumKernelH = allParamVecAfterSumKernelH(end);
elemKernelParamsAftersumKernelV = allParamVecAfterSumKernelV(1:end-1);
regCoeffAfterSumKernelV = allParamVecAfterSumKernelV(end);

if sum(strcmp(evalTargets, 'oprc'))
    [allParamVecH, logLikelihoodLOODynamicsH, allParamVecDynamicsH, safeLoopCntH] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, origOffDiagElem, elemKernelParamsAfterSumKernelH, regCoeffAfterSumKernelH, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    save dynamicsH.fa.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH
    [allParamVecV, logLikelihoodLOODynamicsV, allParamVecDynamicsV, safeLoopCntV] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, origOffDiagElem, elemKernelParamsAftersumKernelV, regCoeffAfterSumKernelV, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    save dynamicsV.fa.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV
    rankNum = 1;
end
if sum(strcmp(evalTargets, 'fa'))
    [allParamVecH, logLikelihoodLOODynamicsH, allParamVecDynamicsH, safeLoopCntH] = optimizeFAkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, elemKernelParamsAfterSumKernelH, regCoeffAfterSumKernelH, learningRate, loopMax4faKernel, saveIncrement4faKernel);
    save dynamicsH.fa.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH    
    [allParamVecV, logLikelihoodLOODynamicsV, allParamVecDynamicsV, safeLoopCntV] = optimizeFAkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, elemKernelParamsAftersumKernelV, regCoeffAfterSumKernelV, learningRate, loopMax4faKernel, saveIncrement4faKernel);
    save dynamicsV.fa.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV
end

save dynamics.params.all.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV evalTargets elemKernelParamsAfterSumKernelH regCoeffAfterSumKernelH elemKernelParamsAftersumKernelV regCoeffAfterSumKernelV rankNum coeff4lowRankMatVec coeff4diagMatVec learningRate kernelType timeLength sampleID4optimization sampleID4bootstrap loopMax4optimizeElemKernel loopMax4oprcKernel loopMax4faKernel period

