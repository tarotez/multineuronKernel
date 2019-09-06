% by Taro Tezuka since 15.1.15
% 
function [RMSEs, kernelParamsH, kernelParamsV] = runOptimizePopSpikernel(multiChannelSubtrains, orig_depVarTypes, timeLength, regs, thinConditionsBy)

period = 360;
segmentNum = 1; % only one segment (length is 1 second) is used
foldNum = 0;
shorterSubtrains = divideByTimeLength(multiChannelSubtrains, timeLength, segmentNum);
nonEmptySubtrains = removeEmptySamples(shorterSubtrains);
[spikeTrains, depVarIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarIDs);
[RMSEs, kernelParamsH, kernelParamsV] = optimizePopSpikernelByCrossValidation(spikeTrains, depVars, timeLength, regs, foldNum, period, thinConditionsBy);

end

