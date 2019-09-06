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

function [allParamVecDynamicsH, allParamVecDynamicsV, safeLoopCntH, safeLoopCntV] = optimizeKernelByGrid4spikernel(multiSpikeTrainsBySampleID4optimization, depVarID4optimization, op)

evalTargets = op.evalTargets;
ks = op.ks;
condNum = op.condNum;
learningRate = op.learningRate;
loopMax4oprcKernel = op.loopMax4oprcKernel;
saveIncrement4oprcKernel = op.saveIncrement4oprcKernel;
period = op.period;
origOffDiagElem = op.origOffDiagElem;
evalGridType = op.evalGridType;
stepNum = op.stepNum;
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

%-------
% grid search kernelELem and regCoeff
disp('now starting optimizeParamsByGrid4sumKernel() for H')
[optimalElemKernelParamsAfterGridH, optimalLogRegCoeffAfterGridH] = optimizeParamsByGrid4popSpikernel(ks, multiSpikeTrainsBySampleID4optimization, depVarH, evalGridType, stepNum, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum, op);

disp('now starting optimizeParamsByGrid4sumKernel() for V')
[optimalElemKernelParamsAfterGridV, optimalLogRegCoeffAfterGridV] = optimizeParamsByGrid4popSpikernel(ks, multiSpikeTrainsBySampleID4optimization, depVarV, evalGridType, stepNum, origLogRegCoeffVec, gridDivideNum, stochRMSEtrialNum, op);

optimalRegCoeffAfterGridH = exp(optimalLogRegCoeffAfterGridH);
optimalRegCoeffAfterGridV = exp(optimalLogRegCoeffAfterGridV);
    
elemKernelParamsAfterSumKernelH = optimalElemKernelParamsAfterGridH;
regCoeffAfterSumKernelH = optimalRegCoeffAfterGridH;
elemKernelParamsAfterSumKernelV = optimalElemKernelParamsAfterGridV;
regCoeffAfterSumKernelV = optimalRegCoeffAfterGridV;

if sum(strcmp(evalTargets, 'oprc'))
    disp('now starting optimizeOPRCkernelByLeaveOneOut for H')
    [~, ~, allParamVecDynamicsH, safeLoopCntH] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarH, origOffDiagElem, elemKernelParamsAfterSumKernelH, regCoeffAfterSumKernelH, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    %%% save dynamicsH.fa.mat logLikelihoodLOODynamicsH allParamVecDynamicsH safeLoopCntH    
    disp('now starting optimizeOPRCkernelByLeaveOneOut for V')
    [~, ~, allParamVecDynamicsV, safeLoopCntV] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVarV, origOffDiagElem, elemKernelParamsAfterSumKernelV, regCoeffAfterSumKernelV, learningRate, loopMax4oprcKernel, saveIncrement4oprcKernel);
    %%% save dynamicsV.fa.mat logLikelihoodLOODynamicsV allParamVecDynamicsV safeLoopCntV    
end


end

