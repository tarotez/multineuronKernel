% Coded by Taro Tezuka since 15.1.15
% optimizes parameters for population rate spikernel with respect to kernel ridge regression by changing parameters.
% INPUT:
%   spikeTrains:  spike trains
%   depVar: dependent variables
%   offDiags: off-diagonal entries
%   regs: regularization parameters
%   foldNum: number of folds
%   period: for periodic variables.     
%   thinConditionsBy: thinning
%   spikeTrainNum4optimization: the number of spike trains used fo optimizing kernel parameters
% OUTPUT:
%   RMSEs: root mean square error
%   kernelParams: kernel parameters
% 
function [RMSEs, kernelParams] = optimizeMixtureSpikernelByCrossValidation(spikeTrains, depVar, timeLength, offDiags, regs, foldNum, period, thinConditionsBy, spikeTrainNum4optimization)

diagComponent = 1;
channelNum = length(spikeTrains{1});
ks = kernelFactory('spikernel', timeLength, 'Gaussian');

subsetSpikeTrains = [];
%{
origSpikeTrainNum = length(spikeTrains);
if spikeTrainNum4optimization == 0 || spikeTrainNum4optimization > origSpikeTrainNum
    spikeTrainNum4optimization = origSpikeTrainNum;
end
randIndices = randperm(spikeTrainNum4optimization);
subsetSpikeTrains = cell(spikeTrainNum4optimization,1);
for spikeTrainID = 1:spikeTrainNum4optimization    
    % if unitNum1 > 0
    %    disp(['in optimizeSpikernel, unitNum1 = ' num2str(unitNum1)]); 
    % end
    subsetSpikeTrains{spikeTrainID} = spikeTrains{randIndices(spikeTrainID)};
end
%}

kernelParams = ks.autoParam(ks, subsetSpikeTrains);

paramNum1 = size(kernelParams,1);
paramNum2 = length(offDiags);
paramNum3 = length(regs);
RMSEs = zeros(paramNum1,paramNum3,paramNum3);
    
for paramID1 = 1:paramNum1   
    disp(['paramID1 = ' num2str(paramID1) '/' num2str(paramNum1)])
    totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams{paramID1});

    for paramID2 = 1:paramNum2        
        % disp(['paramID2 = ' num2str(paramID2)])
        offDiagComponent = offDiags(paramID2);
        weightMat = ((diagComponent - offDiagComponent) * eye(channelNum)) + (offDiagComponent * ones(channelNum));
        totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);

        for paramID3 = 1:paramNum3
            [~, meanSquaredErrors] = crossValidateKernelWithThinning(totalKernelMat, depVar, foldNum, regs(paramID3), period, thinConditionsBy);                   
            RMSEs(paramID1,paramID2,paramID3) = sqrt(nanmean(meanSquaredErrors));
            % presentTime = fix(clock);
            % disp(['at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6)) ', RMSE for param = (' num2str(paramID1) ', ' num2str(paramID2) ') is ' num2str(RMSEs(paramID1,paramID2))]);
            % save res.optimizeSpikernelByCrossValidation.mat RMSEs kernelParams
        end
    end
    
end

end

