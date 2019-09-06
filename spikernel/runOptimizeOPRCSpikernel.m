% by Taro Tezuka since 15.1.15
% 
function [RMSEs, kernelParams] = runOptimizeOPRCSpikernel(multiChannelSubtrains, orig_depVarTypes, timeLength, offDiags, regs, thinConditionsBy)

period = 360;
segmentNum = 1; % only one segment (length is 1 second) is used
foldNum = 0;
shorterSubtrains = divideByTimeLength(multiChannelSubtrains, timeLength, segmentNum);
nonEmptySubtrains = removeEmptySamples(shorterSubtrains);
[spikeTrains, depVarIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
depVar = indices2valuesByCellArray(orig_depVarTypes, depVarIDs);
spikeTrainNum4optimization = 0;
[RMSEs, kernelParams] = optimizeMixtureSpikernelByCrossValidation(spikeTrains, depVar, timeLength, offDiags, regs, foldNum, period, thinConditionsBy, spikeTrainNum4optimization);

end

