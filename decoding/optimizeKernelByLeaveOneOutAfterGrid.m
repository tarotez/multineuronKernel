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

function [allParamVecDynamicsH, allParamVecDynamicsV, safeLoopCntH, safeLoopCntV] = optimizeKernelByLeaveOneOutAfterGrid(multiSpikeTrainsBySampleID4optimization, depVarID4optimization, op)

evalTargets = op.evalTargets;
ks = op.ks;
condNum = op.condNum;
rankNum = op.rankNum;
learningRate = op.learningRate;
loopMax4sumKernel = op.loopMax4sumKernel;
loopMax4oprcKernel = op.loopMax4oprcKernel;
% loopMax4faKernel = op.loopMax4faKernel;
saveIncrement4sumKernel = op.saveIncrement4sumKernel;
saveIncrement4oprcKernel = op.saveIncrement4oprcKernel;
% saveIncrement4faKernel = op.saveIncrement4faKernel;
period = op.period;
origOffDiagElem = op.origOffDiagElem;
coeff4lowRankMatVec = op.coeff4lowRankMatVec;
coeff4diagMatVec = op.coeff4diagMatVec;
evalGridType = op.evalGridType;
stepNum = op.stepNum;
origElemKernelParamVec = op.origElemKernelParamVec;
origLogRegCoeffVec = op.origLogRegCoeffVec;
gridDivideNum = op.gridDivideNum;
stochRMSEtrialNum = op.stochRMSEtrialNum;

% totalSampleNum = length(multiSpikeTrainsBySampleID4optimization);
% unitNum = length(multiSpikeTrainsBySampleID4optimization{1});
% disp(['totalSumpleNum = ' num2str(totalSampleNum) ', unitNum = ' num2str(unitNum)]);
%%% save params.for.optimizeKernelByLeaveOneOut.mat evalTargets rankNum op learningRate loopMax4optimizeElemKernel loopMax4faKernel period
% sampleNum = length(sampleID4optimization);
% sgdRandomSampleNum = ceil(sampleNum * sgdRandomSampleRatio);
% orig_depVarTypes = 0:20:340;
% period = 360;
increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);
theta = indices2valuesByCellArray(orig_depVarTypes, depVarID4optimization);
[depVarH, depVarV] = angle2cartesian(theta, period);
%-----------

%-------
% grid search kernelELem and regCoeff
disp('now starting optimizeParamsByGrid4sumKernel() for H')
[optimalElemKernelParamsAfterGridH, optimalLogRegCoeffAfterGridH] = optimizeParamsByGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarH, evalGridType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum, op);
disp('now starting optimizeParamsByGrid4sumKernel() for V')
[optimalElemKernelParamsAfterGridV, optimalLogRegCoeffAfterGridV] = optimizeParamsByGrid4sumKernel(ks, multiSpikeTrainsBySampleID4optimization, depVarV, evalGridType, stepNum, origElemKernelParamVec, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum, op);

optimalRegCoeffAfterGridH = exp(optimalLogRegCoeffAfterGridH);
optimalRegCoeffAfterGridV = exp(optimalLogRegCoeffAfterGridV);

%-------
% refine kernelElem and regCoeff using gradient descent
if op.loopMax4sumKernel > 0
    disp('now starting optimizeSumKernelByLeaveOneOut')
    [~, ~, allParamVecDynamicsAfterSumKernelH, safeLoopCntAfterSumKernelH] = optimizeSumKernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, optimalElemKernelParamsAfterGridH, optimalRegCoeffAfterGridH, learningRate, loopMax4sumKernel, saveIncrement4sumKernel);
    %%% save dynamicsH.sum.mat logLikelihoodLOODynamicsAfterSumKernelH allParamVecDynamicsAfterSumKernelH safeLoopCntAfterSumKernelH
    [~, ~, allParamVecDynamicsAfterSumKernelV, safeLoopCntAfterSumKernelV] = optimizeSumKernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, optimalElemKernelParamsAfterGridV, optimalRegCoeffAfterGridV, learningRate, loopMax4sumKernel, saveIncrement4sumKernel);
    %%% save dynamicsV.sum.mat logLikelihoodLOODynamicsAfterSumKernelV allParamVecDynamicsAfterSumKernelV safeLoopCntAfterSumKernelV
    allParamVecAfterSumKernelH = allParamVecDynamicsAfterSumKernelH(:,safeLoopCntAfterSumKernelH);
    allParamVecAfterSumKernelV = allParamVecDynamicsAfterSumKernelV(:,safeLoopCntAfterSumKernelV);
    elemKernelParamsAfterSumKernelH = allParamVecAfterSumKernelH(1:end-1);
    regCoeffAfterSumKernelH = allParamVecAfterSumKernelH(end);
    elemKernelParamsAfterSumKernelV = allParamVecAfterSumKernelV(1:end-1);
    regCoeffAfterSumKernelV = allParamVecAfterSumKernelV(end);
else
    elemKernelParamsAfterSumKernelH = optimalElemKernelParamsAfterGridH;
    regCoeffAfterSumKernelH = optimalRegCoeffAfterGridH;
    elemKernelParamsAfterSumKernelV = optimalElemKernelParamsAfterGridV;
    regCoeffAfterSumKernelV = optimalRegCoeffAfterGridV;
end

if sum(strcmp(evalTargets, 'oprc'))
    disp('now starting optimizeOPRCkernelByLeaveOneOut for H')
    [~, ~, allParamVecDynamicsH, safeLoopCntH] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, origOffDiagElem, elemKernelParamsAfterSumKernelH, regCoeffAfterSumKernelH, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    %%% save dynamicsH.fa.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH
    disp('now starting optimizeOPRCkernelByLeaveOneOut for V')
    [~, ~, allParamVecDynamicsV, safeLoopCntV] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, origOffDiagElem, elemKernelParamsAfterSumKernelV, regCoeffAfterSumKernelV, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    %%% save dynamicsV.fa.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV
end

%{
if sum(strcmp(evalTargets, 'fa'))
    [~, ~, allParamVecDynamicsH, safeLoopCntH] = optimizeFAkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, elemKernelParamsAfterSumKernelH, regCoeffAfterSumKernelH, learningRate, loopMax4faKernel, saveIncrement4faKernel);
    %%% save dynamicsH.fa.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH    
    [~, ~, allParamVecDynamicsV, safeLoopCntV] = optimizeFAkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, elemKernelParamsAfterSumKernelV, regCoeffAfterSumKernelV, learningRate, loopMax4faKernel, saveIncrement4faKernel);
    %%% save dynamicsV.fa.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV
end
%}

end

